
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

  # Initialize an empty hashtable to store differences
  $differences = @{}
}

Describe "Compare SettingsCatalog Settings Files" -Tag 'SettingsCatalog' {
  It "Reference and compare files should be identical after filtering" {

    # Remove excluded properties
    $referenceobjectsettings = (Get-Content $referencefile -Raw | ConvertFrom-Json -Depth 100 | Select-Object settings).settings
    $compareobjectsettings = (Get-Content $comparefile -Raw | ConvertFrom-Json -Depth 100 | Select-Object settings).settings

    $differences = @{}

    Foreach ($setting in $referenceobjectsettings) {

      $compare = $compareobjectsettings | Where-Object { $_.id -eq $setting.id }


      # Comparing main setting values
      If ($compare.settingInstance.choiceSettingValue.value -ne $setting.settingInstance.choiceSettingValue.value) {

        Write-Verbose "Difference found for $($setting.id)"

        $difference = [PSCustomObject]@{
          id             = $setting.id
          referenceValue = $setting.settingInstance.choiceSettingValue.value
          compareValue   = $compare.settingInstance.choiceSettingValue.value
        }
        $differences.Add($setting.id, $difference)

      }
      Else {
        Write-Verbose "No difference for $($setting.id)"
      }

      #Comparing sub setting

      if ($setting.settingInstance.choiceSettingValue.children) {

        Write-Verbose "Children found for $($setting.id)"

        if ($($compare.settingInstance.choiceSettingValue.children).Count -ne $($setting.settingInstance.choiceSettingValue.children).Count) {
          Write-Verbose "Number of children differ for $($setting.id)"

          $difference = [PSCustomObject]@{
            id             = $setting.id
            referenceValue = $($setting.settingInstance.choiceSettingValue.children).Count
            compareValue   = $($compare.settingInstance.choiceSettingValue.children).Count
          }
        }
        else {
          Write-Verbose "Number of children match for $($setting.id)"
          Write-Verbose "Comparing children for $($setting.id)"
          foreach ($child in $setting.settingInstance.choiceSettingValue.children) {

            $compareChild = $compare.settingInstance.choiceSettingValue.children | Where-Object { $_.settingDefinitionId -eq $child.settingDefinitionId }

            if ($compareChild) {
              if ($compareChild.choiceSettingValue.value -ne $child.choiceSettingValue.value) {
                Write-Verbose "Difference found for child $($compareChild.settingDefinitionId)"

                $differenceChild = [PSCustomObject]@{
                  id             = $child.settingDefinitionId
                  referenceValue = $child.choiceSettingValue.value
                  compareValue   = $compareChild.choiceSettingValue.value
                }
                $differences.Add($child.settingDefinitionId, $differenceChild)
              }
              else {
                Write-Verbose "No difference for child $($compareChild.settingDefinitionId)"
              }
            }
            else {
              Write-Verbose "No matching child found in comparison for $($compareChild.settingDefinitionId)"

              $differenceChild = [PSCustomObject]@{
                id             = $child.settingDefinitionId
                referenceValue = $child.choiceSettingValue.value
                compareValue   = "Not found in comparison"
              }
              $differences.Add($child.settingDefinitionId, $differenceChild)
            }
          }
        }
      }
      else {
        Write-Verbose "No children found for $($setting.id)"
      }
    }

    if ($differences.Count -gt 0) {
      Write-Verbose "`nDifferences found:"
      $differences.Values | Format-Table -AutoSize | Out-String | Write-Host
    }

    $differences.Count | Should -Be 0 -Because "There should be no differences between the reference and compare files after filtering."

  }
}