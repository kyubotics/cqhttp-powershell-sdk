Import-Module ./CQHttp

function MessageCallback
{
    param (
        [hashtable]$Bot,
        [hashtable]$Context
    )

    Write-Host "Received message: $($Context.message)"
}

function PrivateMessageCallback
{
    param (
        [hashtable]$Bot,
        [hashtable]$Context
    )

    $result = (& $Bot.Send -Context $Context -Message $Context.message)
    if ($result.data.message_id)
    {
        Write-Host "Succeeded to repeat, message id: $($result.data.message_id)"
    }
}

$callbacks = @(
    , @("message", $Function:MessageCallback)
    , @("message.private", $Function:PrivateMessageCallback)
    , @("request.friend", {
            param ($Bot, $Context)
            & $Bot.CallAction `
                -Action "set_friend_add_request" `
                -Params @{flag = $Context.flag; approve = $true}
        })
)

Invoke-CQHttpBot `
    -ApiRoot "http://192.168.69.128:5700" `
    -Address "+:8080" `
    -EventCallbacks $callbacks
