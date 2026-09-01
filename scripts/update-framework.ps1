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
        if (-not $ResumeFrameworkUpdate) { throw "框架尚未开始更新：个人仓库存在未提交修改。`n`n---`n`n## ➡️ 可选的下一步`n`n### 1. 展示并处理现有修改`n`n只展示阻塞更新的差异，不会立即提交、丢弃或推送。`n`n回复数字：``1```n`n或复制回复：``确认展示阻塞更新的现有修改。```n`n### 2. 取消本次更新`n`n不会修改知识库。`n`n回复数字：``2```n`n或复制回复：``取消本次框架更新。```n`n### 0. 暂不处理以上操作`n`n回复数字：``0``" }
        $staged = @(git -c core.quotepath=false -C $target diff --cached --name-only)
        if ($staged.Count -gt 0) { throw '续跑已停止：存在暂存区修改。' }
        $changed = @(
            git -c core.quotepath=false -C $target diff --name-only
            git -c core.quotepath=false -C $target ls-files --others --exclude-standard
        ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique
        $rootFiles = @('README.md','AGENTS.md','Home.md','MIGRATION.md','.gitignore','.gitattributes','.kb-version','.kb-layout-version','.obsidian/appearance.json','.obsidian/app.json','.obsidian/snippets/work-knowledge-navigation.css')
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
    $framework = @('README.md','AGENTS.md','Home.md','AI','Templates','scripts','integrations','MIGRATION.md','.gitignore','.gitattributes','.kb-version')
    $additive = @('Archive\README.md','Knowledge\README.md','Knowledge\INDEX.md','Projects\README.md','Projects\INDEX.md','Projects\TASKS.md','Inbox\README.md','Daily\README.md')
    $protected = @('Knowledge','Projects','Daily','Inbox','Attachments','Archive','Vault','AI\LOCAL.md','AI\写入日志.md','AI\写入日志','.kb-role','.kb-layout-version')
    $obsidianSourceFiles = @('.obsidian\appearance.json','.obsidian\app.json','.obsidian\snippets\work-knowledge-navigation.css')
    foreach ($relative in $obsidianSourceFiles) { if (-not (Test-Path -LiteralPath (Join-Path $sourceRoot $relative) -PathType Leaf)) { throw "模板缺少 Obsidian 配置：$relative" } }
    Write-Host "框架版本：$targetVersion -> $sourceVersion"
    Write-Host ('将更新：' + ($framework -join ', '))
    Write-Host ('将保护：' + ($protected -join ', '))
    Write-Host ('仅缺失时补充且绝不覆盖：' + ($additive -join ', '))
    Write-Host 'Obsidian：更新模板侧栏 CSS；appearance.json 和 app.json 仅在缺失或空配置时补充。'
    if (-not $Confirm) { throw "尚未确认，框架更新尚未开始。`n`n---`n`n## ⚠️ 需要你确认`n`n### 1. 执行框架更新`n`n不会创建 Git 提交、推送或迁移个人目录。`n`n回复数字：``1```n`n或复制回复：``确认执行框架更新，不提交、不推送。``" }
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
    foreach ($relative in $obsidianSourceFiles) {
        $current = Join-Path $target $relative
        if (Test-Path -LiteralPath $current -PathType Leaf) {
            $saved = Join-Path $backup $relative
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $saved) | Out-Null
            Copy-Item -LiteralPath $current -Destination $saved -Force
        }
    }
    $snippetTarget = Join-Path $target '.obsidian\snippets\work-knowledge-navigation.css'
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $snippetTarget) | Out-Null
    Copy-Item -LiteralPath (Join-Path $sourceRoot '.obsidian\snippets\work-knowledge-navigation.css') -Destination $snippetTarget -Force
    foreach ($name in @('appearance.json','app.json')) {
        $destination = Join-Path $target ('.obsidian\' + $name)
        $useTemplate = -not (Test-Path -LiteralPath $destination -PathType Leaf)
        if (-not $useTemplate) { $existing = (Get-Content -Raw -LiteralPath $destination).Trim(); $useTemplate = [string]::IsNullOrWhiteSpace($existing) -or $existing -eq '{}' }
        if ($useTemplate) { New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null; Copy-Item -LiteralPath (Join-Path $sourceRoot ('.obsidian\' + $name)) -Destination $destination -Force }
    }
    $appearancePath = Join-Path $target '.obsidian\appearance.json'
    if (-not (Select-String -LiteralPath $appearancePath -SimpleMatch 'work-knowledge-navigation' -Quiet)) { Write-Host '提示：已保留现有 Obsidian 外观设置；请在“设置 → 外观 → CSS 代码片段”中启用 work-knowledge-navigation。' }
    if (Test-Path -LiteralPath $legacy) { Remove-Item -LiteralPath $legacy -Recurse -Force }
    Write-Host "框架已更新到 $sourceVersion"
    Write-Host "备份：$backup"
    Write-Host '个人数据、归档、个人规则和写入日志未被覆盖。'
    $layoutMarker = Join-Path $target '.kb-layout-version'
    if (-not (Test-Path -LiteralPath $layoutMarker -PathType Leaf)) { [IO.File]::WriteAllText($layoutMarker, "1`n", [Text.UTF8Encoding]::new($false)) }
    $layoutVersion = (Get-Content -Raw -LiteralPath $layoutMarker).Trim()
    if ($layoutVersion -eq '1') { Write-Host '目录结构 1 正常可用。' }
    Write-Host '框架已经更新完成，但这些变更尚未创建 Git 提交。'
    Write-Host "`n---`n`n## ➡️ 可选的下一步`n"
    Write-Host "### 1. 创建框架更新的本地提交`n`n先展示框架变更，再创建本地提交；不会推送。`n`n回复数字：``1```n`n或复制回复：``确认展示框架变更并创建本地提交，不推送。``"
    if ($layoutVersion -eq '1') { Write-Host "`n### 2. 生成目录迁移预览`n`n只生成预览，不移动文件、不提交、不推送。`n`n回复数字：``2```n`n或复制回复：``确认生成目录迁移预览。``" }
    Write-Host "`n### 0. 暂不处理以上操作`n`n回复数字：``0``"
} finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
