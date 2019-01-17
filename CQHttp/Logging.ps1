function Write-FormattedLog
{
    param (
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent")]
        [string]$Message,

        [ValidateSet("Fatal", "Error", "Warning", "Info", "Debug")]
        $Level = "Debug"
    )

    $date = Get-Date -Format "o"

    switch ($Level)
    {
        "Fatal"
        {
            throw $Message
        }
        "Error"
        {
            Write-Host "$date [E] $Message" -ForegroundColor Red
        }
        "Warning"
        {
            Write-Host "$date [W] $Message" -ForegroundColor Yellow
        }
        "Info"
        {
            Write-Host "$date [I] $Message" -ForegroundColor Blue
        }
        "Debug"
        {
            Write-Host "$date [D] $Message" -ForegroundColor White
        }
    }
}

function Write-AccessLog
{
    param (
        [string]$Method,
        [string]$Path,
        [int]$StatusCode = 200
    )

    Write-FormattedLog -Message "$Method $Path $StatusCode" -Level Info
}
