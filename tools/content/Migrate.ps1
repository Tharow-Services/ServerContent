<#
.SYNOPSIS
  Mirgates a block or item to new id.
.DESCRIPTION
  Moves assoc'd files when --confirm is used
.EXAMPLE
  .\tools\wiki\Build-Wiki.ps1
  .\tools\wiki\Build-Wiki.ps1 -Serve        # also opens http://localhost:8080/ to preview
#>
# Warning this file was writen for linux.
param(
  [string]$PackRoot     = '',   # folder holding the 'almura' dir; default <repo>\3.0\fs_2\assets
  [string]$MigrationFile = '',
  [string]$type        = 'block',
  [string]$IF          = '',
  [string]$OF       = '',   # default tools\wiki\dist
  [switch]$MoveFiles
)
$ErrorActionPreference = 'Stop'

##Helper Funtions
function Get-JsonContent {
  param ($Path)
  return ConvertFrom-Json -InputObject (Get-Content -Path $Path -Raw -Encoding UTF-8)
}
function Set-JsonContent {
  param ($Path, $InputObject)
  Set-Content -Path $Path -Value (ConvertTo-Json -InputObject $InputObject -Depth 99)
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = [IO.Path]::GetFullPath((Join-Path $here '../..'))
if (-not $PackRoot)  { $PackRoot  = Join-Path $repo '3.0/fs_2/assets/almura' }
if (-not $MigrationFile) { $MigrationFile = Join-Path $repo '3.0/fs_2/migrations.json'}
Write-Host "Creating Migration"
$Migrations = Get-JsonContent -Path $MigrationFile
Add-Member -InputObject $Migrations.migrations -Name "almura:$IF" -Value "almura:$OF" -MemberType NoteProperty -Force
Set-JsonContent -Path $MigrationFile -InputObject $Migrations


if ($MoveFiles) {
  Write-Host "Begin File Move"
  $ContentFilePathOld = "$PackRoot/content/$type/$IF.json"
  Set-Content -Path "$PackRoot/content/$type/$OF.json" -Value ((Get-Content -Path $ContentFilePathOld -Raw).Replace("almura:$IF", "almura:$OF"))
  Remove-Item -Path $ContentFilePathOld
  Write-Host "Moved Content File"
  $BlockStatesPathOld = "$PackRoot/blockstates/$IF.json"
  $BlockStates = Get-JsonContent -Path $BlockStatesPathOld
  Remove-Item -Path $BlockStatesPathOld
  $ModelPath = "$PackRoot/models/$type/$($BlockStates.defaults.model.Replace('almura:', ''))"
  $BlockStates.defaults.model = "almura:$OF" + (Split-Path -Path $ModelPath -Extension); # Add the extension back if it had one.
  Set-JsonContent -Path "$PackRoot/blockstates/$OF.json" -InputObject $BlockStates
  if (-not (Test-Path -Path $ModelPath)) {
    $ModelPath = $ModelPath + ".json"
  } else {
    Move-Item -Path "$ModelPath.mtl" -Destination "$PackRoot/models/$type/$OF.mtl"
  }
  #Move-Item -Path $ModelPath -Destination "$PackRoot/models/$type/$OF$(Split-Path -Path $ModelPath -Extension)"
  Write-Host "Moved Model Updated blockstates"
  $translationsFile = Join-Path -Path "$PackRoot/content/$type/$IF" '../' '_translations/en_us.json'
  Set-Content -Path $translationsFile -Value (Get-Content -Path $translationsFile -Raw).Replace((Split-Path -Leaf -Path "$IF")+'.name', (Split-Path -Leaf -Path "$OF")+'.name')
  Write-Host "Updated Translation, warning may need to move translation";
}
