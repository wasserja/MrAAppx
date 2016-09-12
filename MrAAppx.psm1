# Source all ps1 scripts in current directory.
Get-ChildItem (Join-Path $PSScriptRoot *.ps1) | foreach {. $_.FullName}
