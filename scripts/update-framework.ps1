param(
    [string]$Source = 'https://github.com/lwtor/work-knowledge-template.git',
    [string]$TargetRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$Confirm
)
$ErrorActionPreference = 'Stop'
$target = (Resolve-Path -LiteralPath $TargetRoot).Path
if (-not (Test-Path -LiteralPath (Join-Path $target '.git') -PathType Container)) { throw '目标不是 Git 仓库。' }
if ((Get-Content -Raw -LiteralPath (Join-Path $target '.kb-role')).Trim() -ne 'personal') { throw '目标不是个人知识库。' }
if (git -C $target status --porcelain) { throw '个人仓库存在未提交修改，请先处理。' }
$temp = Join-Path ([IO.Path]::GetTempPath()) ('kb-framework-' + [guid]::NewGuid().ToString('N'))
try {
    if (Test-Path -LiteralPath $Source -PathType Container) { $sourceRoot = (Resolve-Path -LiteralPath $Source).Path } else {
        git clone --depth 1 $Source $temp | Out-Null
        if ($LASTEXITCODE -ne 0) { throw '无法获取模板仓库。' }
        $sourceRoot = $temp
    }
    if ((Get-Content -Raw -LiteralPath (Join-Path $sourceRoot '.kb-role')).Trim() -ne 'template') { throw '来源不是模板仓库。' }
    $sourceVersion = (Get-Content -Raw -LiteralPath (Join-Path $sourceRoot '.kb-version')).Trim()
    $targetVersion = (Get-Content -Raw -LiteralPath (Join-Path $target '.kb-version')).Trim()
    if ($sourceVersion -eq $targetVersion) { Write-Host "当前已是模板版本 $targetVersion，无需更新。"; return }
    $framework = @('README.md','AGENTS.md','Home.md','AI','Templates','scripts','integrations','.gitignore','.kb-version')
    $protected = @('Knowledge','Projects','Daily','Inbox','Attachments','Archive','AI\LOCAL.md','AI\写入日志.md','AI\写入日志','.kb-role')
    Write-Host "框架版本：$targetVersion -> $sourceVersion"
    Write-Host ('将更新：' + ($framework -join ', '))
    Write-Host ('将保护：' + ($protected -join ', '))
    if (-not $Confirm) { throw '尚未确认。检查以上范围后使用 -Confirm 执行。' }
    $backup = Join-Path $target ('.kb-backups\framework-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    New-Item -ItemType Directory -Force -Path $backup | Out-Null
    foreach ($relative in $framework) {
        $current = Join-Path $target $relative
        if (Test-Path -LiteralPath $current) {
            $destination = Join-Path $backup $relative
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
            Copy-Item -LiteralPath $current -Destination $destination -Recurse -Force
        }
    }
    $legacy = Join-Path $target 'skills'
    if (Test-Path -LiteralPath $legacy) { Copy-Item -LiteralPath $legacy -Destination (Join-Path $backup 'skills') -Recurse -Force }
    $localRules = Join-Path $target 'AI\LOCAL.md'
    $localCopy = Join-Path $backup 'LOCAL.md.preserved'
    if (Test-Path -LiteralPath $localRules -PathType Leaf) { Copy-Item -LiteralPath $localRules -Destination $localCopy -Force }
    foreach ($relative in $framework) {
        $incoming = Join-Path $sourceRoot $relative
        if (-not (Test-Path -LiteralPath $incoming)) { throw "模板缺少框架路径：$relative" }
        $current = Join-Path $target $relative
        if (Test-Path -LiteralPath $current) { Remove-Item -LiteralPath $current -Recurse -Force }
        Copy-Item -LiteralPath $incoming -Destination $current -Recurse -Force
    }
    if (Test-Path -LiteralPath $localCopy -PathType Leaf) { Copy-Item -LiteralPath $localCopy -Destination (Join-Path $target 'AI\LOCAL.md') -Force }
    foreach ($relative in @('AI\写入日志.md','AI\写入日志')) {
        $saved = Join-Path $backup $relative
        if (Test-Path -LiteralPath $saved) {
            $destination = Join-Path $target $relative
            if (Test-Path -LiteralPath $destination) { Remove-Item -LiteralPath $destination -Recurse -Force }
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
            Copy-Item -LiteralPath $saved -Destination $destination -Recurse -Force
        }
    }
    foreach ($relative in @('Archive\Knowledge','Archive\Projects')) { New-Item -ItemType Directory -Force -Path (Join-Path $target $relative) | Out-Null }
    if (Test-Path -LiteralPath $legacy) { Remove-Item -LiteralPath $legacy -Recurse -Force }
    Write-Host "框架已更新到 $sourceVersion"
    Write-Host "备份：$backup"
    Write-Host '个人数据、归档、个人规则和写入日志未被覆盖。提交和推送尚未执行。'
} finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
