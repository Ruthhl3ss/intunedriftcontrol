
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][string]$referencefile,
    [Parameter(Mandatory = $true)][string]$comparefile,
    [Parameter(Mandatory = $true)][ValidateSet('SettingsCatalog', 'DeviceCompliance','DeviceConfiguration')][string]$type
)

switch ($type) {
  SettingsCatalog {
    $testfile = "tests/settingscatalog-compare.tests.ps1"
  }
  DeviceCompliance {
    $testfile = "tests/devicecompliance-compare.tests.ps1"
  }
  DeviceConfiguration {
    $testfile = "tests/deviceconfiguration-compare.tests.ps1"
  }
}

$pesterContainer = New-PesterContainer -Path $testfile -Data @{ referencefile = $referencefile; comparefile = $comparefile }

Write-Output "Running Intune Drift Control tests for $type comparison between $referencefile and $comparefile"

Invoke-Pester -Container $pesterContainer
