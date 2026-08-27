param(
    [string]$Source = 'https://github.com/lwtor/work-knowledge-template.git',
    [string]$TargetRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$Confirm,
    [switch]$ResumeFrameworkUpdate
)
$ErrorActionPreference = 'Stop'
$target = (Resolve-Path -LiteralPath $TargetRoot).Path
if (-not (Test-Path -LiteralPath (Join-Path $target '.git') -PathType Container)) { throw '目标不是 Git 仓库。' }
if ((Get-Content -Raw -LiteralPath (Join-Path $target '.kb-role')).Trim() -ne 'personal') { throw '目标不是个人知识库。' }
$temp = Join-Path ([IO.Path]::GetTempPath()) ('kb-framework-' + [guid]::NewGuid().ToString('N'))
try {
    if (Test-Path -LiteralPath $Source -PathType Container) { $sourceRoot = (Resolve-Path -LiteralPath $Source).Path } else {
        git clone --depth 1 $Source $temp | Out-Null
        if ($LASTEXITCODE -ne 0) { throw '无法获取模板仓库。' }
        $sourceRoot = $temp
    }
    if ((Get-Content -Raw -LiteralPath (Join-Path $sourceRoot '.kb-role')).Trim() -ne 'template') { throw '来源不是模板仓库。' }
    $dirty = @(git -c core.quotepath=false -C $target status --porcelain)
    if ($dirty.Count -gt 0) {
        if (-not $ResumeFrameworkUpdate) { throw '个人仓库存在未提交修改，请先处理；仅在恢复已中断的框架更新时使用 -ResumeFrameworkUpdate。' }
        $staged = @(git -c core.quotepath=false -C $target diff --cached --name-only)
        if ($staged.Count -gt 0) { throw '续跑已停止：存在暂存区修改。' }
        $changed = @(
            git -c core.quotepath=false -C $target diff --name-only
            git -c core.quotepath=false -C $target ls-files --others --exclude-standard
        ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique
        $rootFiles = @('README.md','AGENTS.md','Home.md','.gitignore','.gitattributes','.kb-version')
        foreach ($item in $changed) {
            $path = $item.Replace('\','/')
            $allowed = $rootFiles -contains $path -or $path.StartsWith('Templates/') -or $path.StartsWith('scripts/') -or $path.StartsWith('integrations/') -or $path.StartsWith('AI/')
            if ($path -eq 'AI/LOCAL.md' -or $path -eq 'AI/写入日志.md' -or ($path.StartsWith('AI/写入日志/') -and $path -ne 'AI/写入日志/README.md')) { $allowed = $false }
            if (-not $allowed) { throw "续跑已停止：发现框架白名单之外的修改：$path" }
        }
        Write-Host '续跑检查通过：未发现暂存修改或个人数据差异。'
    }
    $sourceVersion = (Get-Content -Raw -LiteralPath (Join-Path $sourceRoot '.kb-version')).Trim()
    $targetVersion = (Get-Content -Raw -LiteralPath (Join-Path $target '.kb-version')).Trim()
    if ($sourceVersion -eq $targetVersion -and -not $ResumeFrameworkUpdate) { Write-Host "当前已是模板版本 $targetVersion，无需更新。"; return }
    if ($sourceVersion -eq $targetVersion) { Write-Host "框架版本均为 $targetVersion；正在续跑此前中断的同版本更新。" }
    $framework = @('README.md','AGENTS.md','Home.md','AI','Templates','scripts','integrations','.gitignore','.gitattributes','.kb-version')
    $additive = @('Archive\README.md','Knowledge\README.md','Knowledge\INDEX.md','Projects\README.md','Projects\INDEX.md','Projects\TASKS.md','Inbox\README.md','Daily\README.md')
    $protected = @('Knowledge','Projects','Daily','Inbox','Attachments','Archive','AI\LOCAL.md','AI\写入日志.md','AI\写入日志','.kb-role')
    Write-Host "框架版本：$targetVersion -> $sourceVersion"
    Write-Host ('将更新：' + ($framework -join ', '))
    Write-Host ('将保护：' + ($protected -join ', '))
    Write-Host ('仅缺失时补充且绝不覆盖：' + ($additive -join ', '))
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
    foreach ($relative in $additive) {
        $destination = Join-Path $target $relative
        if (-not (Test-Path -LiteralPath $destination)) {
            $incoming = Join-Path $sourceRoot $relative
            if (-not (Test-Path -LiteralPath $incoming -PathType Leaf)) { throw "模板缺少增量框架文件：$relative" }
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
            Copy-Item -LiteralPath $incoming -Destination $destination -Force
        }
    }
    if (Test-Path -LiteralPath $legacy) { Remove-Item -LiteralPath $legacy -Recurse -Force }
    Write-Host "框架已更新到 $sourceVersion"
    Write-Host "备份：$backup"
    Write-Host '个人数据、归档、个人规则和写入日志未被覆盖。提交和推送尚未执行。'
} finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
