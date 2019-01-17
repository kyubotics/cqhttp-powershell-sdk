# $public = @(Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1")
# $private = @(Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1")

# @($public + $private) | ForEach-Object {
#     try
#     {
#         . $_.FullName
#     }
#     catch
#     {
#         Write-Error -Message "Failed to import function $($_.FullName): $_"
#     }
# }

# Export-ModuleMember -Function $public.BaseName

. "$PSScriptRoot\CQHttp.ps1"
