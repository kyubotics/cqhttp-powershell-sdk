Import-Module ./CQHttp

function MessageCallback
{
    param (
        [hashtable]$Bot,
        [hashtable]$Ctx
    )

    if ($Ctx.user_id -eq 1002647525)
    {
        & $Bot.Send -Context $Ctx -Message $Ctx.message
    }

    Write-Host "Received message: $($Ctx.message)"
}

Invoke-CQHttpBot `
    -ApiRoot "http://127.0.0.1:5700" `
    -Address "127.0.0.1:8080" `
    -EventCallbacks @(, @("message", $Function:MessageCallback))
