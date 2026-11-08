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
  [string]$Name = ''
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
if (-not $PackRoot)  { $PackRoot  = Join-Path $repo "3.0/fs_2/assets/almura/models/block/horizontal/flooring/$name.json" }
Set-Content -Path $PackRoot -Value @"
{
    "parent": "block/cube_all",
    "textures": {
        "all": "almura:block/flooring/$name"
    }
}
"@