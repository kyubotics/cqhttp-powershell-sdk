Import-Module ./CQHttp

function MessageCallback
{
    param (
        [hashtable]$Bot,
        [hashtable]$Context
    )

    if ($Context.user_id -eq 1002647525)
    {
        $result = (& $Bot.Send -Context $Context -Message $Context.message)
        Write-Host "Result: $($result.data)"
    }
}

function PrivateMessageCallback
{
    param (
        [hashtable]$Bot,
        [hashtable]$Context
    )

    Write-Host "wooooow"
}

$callbacks = @(
    , @("message", $Function:MessageCallback)
    , @("message.private", $Function:PrivateMessageCallback)
)

Invoke-CQHttpBot `
    -ApiRoot "http://192.168.69.128:5700" `
    -Address "+:8080" `
    -EventCallbacks $callbacks
