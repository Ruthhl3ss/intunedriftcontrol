
# [CmdletBinding()]
# param (
#   [Parameter(Mandatory = $true)][string]$referencefile,
#   [Parameter(Mandatory = $true)][string]$comparefile
# )





Describe "Compare filtered JSON objects" {
  It "Reference and compare files should be identical after filtering" {

    $referencefile = "/Users/nko/VSCodeWorkspaces/IntuneDriftControl/intunedriftcontrol/sources/Bitlocker.json"
    $comparefile = "/Users/nko/VSCodeWorkspaces/IntuneDriftControl/intunedriftcontrol/sources/Bitlockerv2.json"
    # Load and convert JSON files to PSObjects

    # Properties to exclude from comparison
    $excludeProps = @('createdDateTime', 'lastModifiedDateTime', 'id', 'description')

    # Remove excluded properties
    $refObj = Get-Content $referencefile -Raw | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty $excludeProps
    $cmpObj = Get-Content $comparefile -Raw | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty $excludeProps

    $compare = $refObj -eq $cmpObj
    $compare | Should -Be $true
  }
}