<#
    
    CVC SETUP

#>

[CmdletBinding()]
Param()

# Configuration file, containing functions and documents
. C:\Users\ac00418\Documents\CVC\scripts\CVC-Config.ps1

$fnCount = 0

# Load functions
$cvcFunctions = CVC-Config -configType Functions
Write-Verbose "CVC-Setup`tLoad CVC functions"
foreach ( $func in $cvcFunctions.GetEnumerator() )
{
    Write-Verbose "CVC-Setup`t`tLoad $($func.Name)"
    Invoke-Expression '. ($func.Value)'
    $fnCount++
}
Write-Verbose "CVC-Setup`tCVC functions loaded [$($fnCount)]"

# Load documents
$cvcDocuments = CVC-Config -configType Documents
Write-Verbose "CVC-Setup`tLoad CVC documents"
# ... Asset Library
Write-Verbose "CVC-Setup`t`tAsset Library $($cvcDocuments['AssetLibrary'])"
Invoke-Expression '$assetLibrary = ($cvcDocuments["AssetLibrary"])'
# ... ProjectRegister
Write-Verbose "CVC-Setup`t`tProject Register $($cvcDocuments['ProjectRegister'])"
Invoke-Expression '$projectRegister = ($cvcDocuments["ProjectRegister"])'
# ...ProjectsRoot
Write-Verbose "CVC-Setup`t`tProjects Root $($cvcDocuments['ProjectsRoot'])"
Invoke-Expression '$projectsRoot = ($cvcDocuments["ProjectsRoot"])'

Write-Verbose "CVC-Setup`tCVC documents assigned"

# Create-Asset -assetName "aa" -assetAuthor "aa" -assetComment "AA" -assetDescription "aa" -assetLocation "C:\Users\ac00418\Documents\CVC\projects\Glengyle\blank_header.ps1" -Project CVC -Verbose


Write-Output $cvcFunctions


