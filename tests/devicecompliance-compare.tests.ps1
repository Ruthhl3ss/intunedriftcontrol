[CmdletBinding()]
param (
  [Parameter(Mandatory = $true)][string]$referencefile,
  [Parameter(Mandatory = $true)][string]$comparefile
)

beforeAll {
  # Ensure the files exist
  if (-not (Test-Path $referencefile)) {
    throw "Reference file not found: $referencefile"
    break
  }
  if (-not (Test-Path $comparefile)) {
    throw "Compare file not found: $comparefile"
    break
  }
  # Initialize an empty array to store differences
  $differences = @()
}


Describe "Compare DeviceConfiguration Settings Files" -Tag 'DeviceConfiguration' {
  It "Reference and compare files should be identical after filtering" {

    # Exclude properties that are not relevant for comparison
    $excludedproperties = @(
        'windows10CompliancePolicyReferenceUrl',
        'deviceCompliancePolicyODataType',
        'deviceCompliancePolicyId',
        '@odata.type',
        'id',
        'lastModifiedDateTime',
        'createdDateTime',
        'displayName',
        'description',
        'version'
    )

    # Load and clean objects
    $referenceobject = Get-Content $referencefile -Raw | ConvertFrom-Json -Depth 100 | Select-Object -ExcludeProperty $excludedproperties
    $compareobject = Get-Content $comparefile -Raw | ConvertFrom-Json -Depth 100 | Select-Object -ExcludeProperty $excludedproperties

    $differences = @()

    foreach ($setting in $referenceobject.PSObject.Properties) {

      $compare = $compareobject.PSObject.Properties | Where-Object { $_.Name -eq $setting.Name }

      # Comparing main setting values
      if ($compare.value -ne $setting.value) {
          Write-Verbose "Difference found for $($setting.name)"

          $difference = [PSCustomObject]@{
              id             = $setting.name
              referenceValue = $setting.value
              compareValue   = $compare.value
          }
          $differences += $difference
      }
      else {
          Write-Verbose "No difference for $($setting.name)"
      }
    }

    if ($differences.Count -gt 0) {
      Write-Host "Differences found:"
      $differences | Format-Table -AutoSize | Out-String | Write-Host
    }

    $differences.Count | Should -Be 0 -Because "There should be no differences between the reference and compare files after filtering."

  }

}
