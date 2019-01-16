function Write-AccessLog
{
    param (
        [string]$Method,
        [string]$Path,
        [int]$StatusCode = 200
    )

    Write-Log -Message "$Method $Path $StatusCode" -Level Info
}
