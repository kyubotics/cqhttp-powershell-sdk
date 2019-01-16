function New-CQHttp
{
    param (
        [string]$ApiRoot
    )

    $instance = New-Object CQHttp -Property @{ApiRoot = $ApiRoot.TrimEnd("/")}
    return [CQHttp]$instance
}
