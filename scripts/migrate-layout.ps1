param([Parameter(Mandatory=$true)][string]$Root, [switch]$Apply, [switch]$Confirm)
$arguments = @((Join-Path $PSScriptRoot 'kb-migrate-layout.py'), '--root', $Root)
if ($Apply) { $arguments += '--apply' }
if ($Confirm) { $arguments += '--confirm' }
python @arguments
exit $LASTEXITCODE
