. "$PSScriptRoot\Logging.ps1"
. "$PSScriptRoot\Json.ps1"
. "$PSScriptRoot\DeepCopy.ps1"

function Invoke-CQHttpBot
{
    param (
        [string]$ApiRoot = "http://127.0.0.1:5700",
        [string]$Address = "127.0.0.1:8080",

        # Expected value: @( @("message", callbackBlock1), @("request.friend", callbackBlock2) )
        [Alias("EventHandlers")]
        [array[]]$EventCallbacks = @()
    )

    $url = "http://$Address/"
    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add($url)
    $listener.Start()

    if ($listener.IsListening)
    {
        Write-FormattedLog "CQHTTP bot is running on $url..." -Level Info
    }
    else
    {
        Write-FormattedLog "Failed to start HTTP listener" -Level Fatal
    }

    $bot = @{
        ApiRoot  = $ApiRoot.TrimEnd("/")
        Address  = $Address
        Listener = $listener
    }

    $bot.CallAction = {
        param (
            [Parameter(Mandatory = $true)]
            [string]$Action,
            [hashtable]$Params = @{ }
        )
        return Invoke-CQHttpAction -Bot $bot -Action $Action -Params $Params
    }

    $bot.Send = {
        param (
            [Parameter(Mandatory = $true)]
            [hashtable]$Context,
            [Parameter(Mandatory = $true)]
            $Message
        )

        $ctx = Copy-ObjectDeeply $Context
        $ctx.message = $Message
        return & $bot.CallAction -Action "send_msg" -Params $ctx
    }

    while ($bot.Listener.IsListening)
    {
        $event = Receive-Event -Bot $bot
        Write-FormattedLog "Received event: $($event.Name)" -Level Info

        $EventCallbacks | ForEach-Object {
            if (([string]$event.Name).StartsWith($_[0]))
            {
                try
                {
                    & $_[1] $bot $event.Data
                }
                catch
                {
                    Write-FormattedLog "An error occurred while running event callback" -Level Error
                    Write-FormattedLog "Error: $_" -Level Error
                }
            }
        }
    }
}

function Receive-Event
{
    param (
        [hashtable]$Bot
    )

    $listner = $Bot.Listener
    while ($listner.IsListening)
    {
        $context = $listner.GetContext()  # Accept request
        $method = $context.Request.HttpMethod
        $path = $context.Request.RawUrl
        $body = ""

        if ($method -ne "POST")
        {
            $statusCode = 405
        }
        elseif ($path -ne "/")
        {
            $statusCode = 404
        }
        else
        {
            $statusCode = 204
            $body = [System.IO.StreamReader]::new($context.Request.InputStream).ReadToEnd()
        }

        Write-AccessLog -Method $method -Path $path -StatusCode $statusCode
        $context.Response.StatusCode = $statusCode
        $context.Response.OutputStream.Close()

        if (-not $body)
        {
            continue
        }

        Write-FormattedLog "Received body: $body" -Level Debug

        try
        {
            [hashtable]$payload = $body | ConvertFrom-Json | Convert-PSObjectToHashtable
        }
        catch
        {
            continue
        }

        $postType = $payload.post_type
        if (-not $postType)
        {
            continue
        }

        $detailType = $payload."${postType}_type"
        $eventName = "${postType}.${detailType}"

        if ($payload.sub_type)
        {
            $eventName += ".$($payload.sub_type)"
        }

        return @{Name = [string]$eventName; Data = [hashtable]$payload }
    }
}

function Invoke-CQHttpAction
{
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Bot,

        [Parameter(Mandatory = $true)]
        [string]$Action,

        [hashtable]$Params = @{ }
    )

    $url = "$($Bot.ApiRoot)/$Action"
    $body = [System.Text.Encoding]::UTF8.GetBytes(($Params | ConvertTo-Json))
    return Invoke-RestMethod `
        -Method Post -Uri $url `
        -ContentType "application/json; charset=utf-8" `
        -Body $body | Convert-PSObjectToHashtable
}
