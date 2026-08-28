param([string]$KnowledgeBaseRoot = (Split-Path -Parent $PSScriptRoot), [string]$CodexHome = '', [string]$BlueCodeHome = '', [string]$VbuddyHome = '', [ValidateSet('Codex','BlueCode','Vbuddy','All','Framework')][string]$Agent = 'Codex')
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $KnowledgeBaseRoot).Path
$required = @('README.md','Home.md','AGENTS.md','AI\启动配置.md','AI\AI-GUIDE.md','AI\知识维护.md','AI\写入日志\README.md','AI\待复核清单.md','Archive\README.md','Knowledge\README.md','Knowledge\INDEX.md','Projects\README.md','Projects\INDEX.md','Projects\TASKS.md','Inbox\README.md','Daily\README.md','Templates\知识笔记.md','Templates\项目总览.md','Templates\问题解决.md','Templates\日常记录.md','scripts\install-codex-skill.ps1','scripts\install-codex-skill.sh','scripts\install-bluecode-skill.ps1','scripts\install-bluecode-skill.sh','scripts\install-vbuddy-skill.ps1','scripts\install-vbuddy-skill.sh','scripts\verify.ps1','scripts\verify.sh','scripts\update-framework.ps1','scripts\kb_common.py','scripts\kb-index.py','scripts\kb-lint.py','scripts\kb-secret-scan.py','AI\框架更新.md','integrations\codex\work-knowledge\SKILL.md','integrations\codex\work-knowledge\references\ingest.md','integrations\codex\work-knowledge\references\query.md','integrations\codex\work-knowledge\references\project.md','integrations\codex\work-knowledge\references\maintenance.md','integrations\codex\work-knowledge\references\update.md','integrations\bluecode\work-knowledge\SKILL.md','integrations\bluecode\work-knowledge\references\ingest.md','integrations\bluecode\work-knowledge\references\query.md','integrations\bluecode\work-knowledge\references\project.md','integrations\bluecode\work-knowledge\references\maintenance.md','integrations\bluecode\work-knowledge\references\update.md','integrations\vbuddy\work-knowledge\SKILL.md','integrations\vbuddy\work-knowledge\references\ingest.md','integrations\vbuddy\work-knowledge\references\query.md','integrations\vbuddy\work-knowledge\references\project.md','integrations\vbuddy\work-knowledge\references\maintenance.md','integrations\vbuddy\work-knowledge\references\update.md','.obsidian\appearance.json','.obsidian\app.json','.obsidian\snippets\work-knowledge-navigation.css','.gitignore')
if (-not (Test-Path -LiteralPath (Join-Path $root 'BOOTSTRAP.md') -PathType Leaf) -and -not (Test-Path -LiteralPath (Join-Path $root '.kb-role') -PathType Leaf)) { throw '缺少 BOOTSTRAP.md 或 .kb-role' }
foreach ($relative in $required) { if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) { throw "缺少文件：$relative" } }
if (Test-Path -LiteralPath (Join-Path $root 'skills')) { throw '发现旧的通用 skills 目录；当前只支持 integrations\codex、integrations\bluecode 与 integrations\vbuddy。' }
$writeTest = Join-Path $root ('.kb-write-test-' + [guid]::NewGuid().ToString('N'))
try { [IO.File]::WriteAllText($writeTest,'ok',(New-Object System.Text.UTF8Encoding($false))) } finally { if (Test-Path -LiteralPath $writeTest) { Remove-Item -LiteralPath $writeTest -Force } }
$repoRole = if (Test-Path -LiteralPath (Join-Path $root '.kb-role')) { (Get-Content -Raw -LiteralPath (Join-Path $root '.kb-role')).Trim() } else { '' }
if ($repoRole -eq 'template') {
  if (-not (Test-Path -LiteralPath (Join-Path $root 'UPDATE.md') -PathType Leaf)) { throw '模板仓库缺少 UPDATE.md' }
  $bootstrap = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'BOOTSTRAP.md')
  foreach ($marker in @('.kb-version','当前框架版本','模板最新版本','更新状态')) { if (-not $bootstrap.Contains($marker)) { throw "BOOTSTRAP.md 缺少版本报告要求：$marker" } }
  $frameworkVersion = (Get-Content -Raw -LiteralPath (Join-Path $root '.kb-version')).Trim()
  $readme = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'README.md')
  foreach ($marker in @("framework-v$frameworkVersion","当前框架版本：**$frameworkVersion**")) { if (-not $readme.Contains($marker)) { throw "README.md 显示版本与 .kb-version 不一致：$marker" } }
  $homePage = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'Home.md')
  foreach ($marker in @('查看知识库状态','我现在该去哪里','work-knowledge-navigation')) { if (-not $homePage.Contains($marker)) { throw "Home.md 缺少日常入口：$marker" } }
  foreach ($agentName in @('codex','bluecode','vbuddy')) {
    $skillRules = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root "integrations\$agentName\work-knowledge\SKILL.md")
    foreach ($marker in @('name: work-knowledge','description:','references/ingest.md','references/query.md','references/project.md','references/maintenance.md','references/update.md')) { if (-not $skillRules.Contains($marker)) { throw "$agentName Skill 入口缺少契约：$marker" } }
    $queryRules = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root "integrations\$agentName\work-knowledge\references\query.md")
    foreach ($marker in @('Recursively enumerate','.kb-version','raw.githubusercontent.com/lwtor/work-knowledge-template/main/.kb-version','Do not inspect only the first directory level','current branch','knowledge health','查看知识库状态')) { if (-not $queryRules.Contains($marker)) { throw "$agentName 查询规则缺少状态契约：$marker" } }
    $ingestRules = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root "integrations\$agentName\work-knowledge\references\ingest.md")
    foreach ($marker in @('Templates/','complete frontmatter','confidence: unverified','existing Git working-tree changes','创建本地 Git 提交','separate explicit authorization')) { if (-not $ingestRules.Contains($marker)) { throw "$agentName 写入规则缺少收尾契约：$marker" } }
    $updateRules = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root "integrations\$agentName\work-knowledge\references\update.md")
    foreach ($marker in @('raw.githubusercontent.com/lwtor/work-knowledge-template/main/UPDATE.md','temporary authority','preserve their union','Never use an old updater','no staged changes','framework allowlist','framework update has not started','Do not default to stashing','Git has not recorded it')) { if (-not $updateRules.Contains($marker)) { throw "$agentName 更新规则缺少跨版本契约：$marker" } }
  }
  $updater = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'scripts\update-framework.ps1')
  foreach ($marker in @('ResumeFrameworkUpdate','仅缺失时补充且绝不覆盖','Knowledge\INDEX.md','续跑检查通过','work-knowledge-navigation','appearance.json 和 app.json 仅在缺失或空配置时补充')) { if (-not $updater.Contains($marker)) { throw "Windows 更新器缺少兼容迁移契约：$marker" } }
}
$roleFile = Join-Path $root '.kb-role'
if ((Test-Path -LiteralPath $roleFile -PathType Leaf) -and ((Get-Content -Raw -LiteralPath $roleFile).Trim() -eq 'personal')) {
 if ($Agent -in @('Codex','All')) {
  $configuredHome = $CodexHome
  if ([string]::IsNullOrWhiteSpace($configuredHome)) { $configuredHome = [Environment]::GetEnvironmentVariable('CODEX_HOME') }
  if ([string]::IsNullOrWhiteSpace($configuredHome)) { $configuredHome = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex' }
  $installed = Join-Path $configuredHome 'skills\work-knowledge'
  $marker = Join-Path $installed '.managed-by-work-knowledge-template'
  if (-not (Test-Path -LiteralPath (Join-Path $installed 'SKILL.md') -PathType Leaf) -or -not (Test-Path -LiteralPath $marker -PathType Leaf)) { throw '缺少 Codex Skill；请执行 scripts\install-codex-skill.ps1' }
  $pathLine = Get-Content -LiteralPath $marker | Where-Object { $_.StartsWith('knowledge_base=') } | Select-Object -First 1
  if ([string]::IsNullOrWhiteSpace($pathLine)) { throw 'Codex Skill 路径标记缺失。' }
  $actualRoot = [IO.Path]::GetFullPath($pathLine.Substring('knowledge_base='.Length)).TrimEnd('\')
  $expectedRoot = [IO.Path]::GetFullPath($root).TrimEnd('\')
  if (-not $actualRoot.Equals($expectedRoot,[StringComparison]::OrdinalIgnoreCase)) { throw "Codex Skill 路径不匹配：$actualRoot" }
  foreach ($relative in @('SKILL.md','references\ingest.md','references\query.md','references\project.md','references\maintenance.md','references\update.md')) {
    $sourceFile = Join-Path $root ('integrations\codex\work-knowledge\' + $relative)
    $installedFile = Join-Path $installed $relative
    if (-not (Test-Path -LiteralPath $installedFile -PathType Leaf)) { throw "已安装 Codex Skill 缺少文件：$relative" }
    if ((Get-FileHash -LiteralPath $sourceFile).Hash -ne (Get-FileHash -LiteralPath $installedFile).Hash) { throw "已安装 Codex Skill 与仓库版本不一致：$relative" }
  }
  Write-Host "Codex 全局 Skill 检查通过：$installed"
 }
 if ($Agent -in @('BlueCode','All')) {
  $bluecodeConfiguredHome = $BlueCodeHome
  if ([string]::IsNullOrWhiteSpace($bluecodeConfiguredHome)) { $bluecodeConfiguredHome = [Environment]::GetEnvironmentVariable('BLUECODE_HOME') }
  if ([string]::IsNullOrWhiteSpace($bluecodeConfiguredHome)) { $bluecodeConfiguredHome = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.bluecode' }
  $bluecodeInstalled = Join-Path $bluecodeConfiguredHome 'skills\work-knowledge'
  $bluecodeMarker = Join-Path $bluecodeInstalled '.managed-by-work-knowledge-template'
  if (Test-Path -LiteralPath $bluecodeInstalled) {
    if (-not (Test-Path -LiteralPath (Join-Path $bluecodeInstalled 'SKILL.md') -PathType Leaf) -or -not (Test-Path -LiteralPath $bluecodeMarker -PathType Leaf)) { throw "存在非本模板管理的 BlueCode Skill：$bluecodeInstalled" }
    $bluecodePathLine = Get-Content -LiteralPath $bluecodeMarker | Where-Object { $_.StartsWith('knowledge_base=') } | Select-Object -First 1
    if ([string]::IsNullOrWhiteSpace($bluecodePathLine)) { throw 'BlueCode Skill 路径标记缺失。' }
    $bluecodeActualRoot = [IO.Path]::GetFullPath($bluecodePathLine.Substring('knowledge_base='.Length)).TrimEnd('\')
    $expectedRoot = [IO.Path]::GetFullPath($root).TrimEnd('\')
    if (-not $bluecodeActualRoot.Equals($expectedRoot,[StringComparison]::OrdinalIgnoreCase)) { throw "BlueCode Skill 路径不匹配：$bluecodeActualRoot" }
    foreach ($relative in @('SKILL.md','references\ingest.md','references\query.md','references\project.md','references\maintenance.md','references\update.md')) {
      $sourceFile = Join-Path $root ('integrations\bluecode\work-knowledge\' + $relative)
      $installedFile = Join-Path $bluecodeInstalled $relative
      if (-not (Test-Path -LiteralPath $installedFile -PathType Leaf)) { throw "已安装 BlueCode Skill 缺少文件：$relative" }
      if ((Get-FileHash -LiteralPath $sourceFile).Hash -ne (Get-FileHash -LiteralPath $installedFile).Hash) { throw "已安装 BlueCode Skill 与仓库版本不一致：$relative" }
    }
    Write-Host "BlueCode 全局 Skill 检查通过：$bluecodeInstalled"
  } else { throw '缺少 BlueCode Skill；请执行 scripts\install-bluecode-skill.ps1' }
 }
 if ($Agent -in @('Vbuddy','All')) {
  $vbuddyConfiguredHome = $VbuddyHome
  if ([string]::IsNullOrWhiteSpace($vbuddyConfiguredHome)) { $vbuddyConfiguredHome = [Environment]::GetEnvironmentVariable('VBUDDY_HOME') }
  if ([string]::IsNullOrWhiteSpace($vbuddyConfiguredHome)) { $vbuddyConfiguredHome = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.vbuddy' }
  $vbuddyInstalled = Join-Path $vbuddyConfiguredHome 'skills\work-knowledge'
  $vbuddyMarker = Join-Path $vbuddyInstalled '.managed-by-work-knowledge-template'
  if (Test-Path -LiteralPath $vbuddyInstalled) {
    if (-not (Test-Path -LiteralPath (Join-Path $vbuddyInstalled 'SKILL.md') -PathType Leaf) -or -not (Test-Path -LiteralPath $vbuddyMarker -PathType Leaf)) { throw "存在非本模板管理的 vBuddy Skill：$vbuddyInstalled" }
    $vbuddyPathLine = Get-Content -LiteralPath $vbuddyMarker | Where-Object { $_.StartsWith('knowledge_base=') } | Select-Object -First 1
    if ([string]::IsNullOrWhiteSpace($vbuddyPathLine)) { throw 'vBuddy Skill 路径标记缺失。' }
    $vbuddyActualRoot = [IO.Path]::GetFullPath($vbuddyPathLine.Substring('knowledge_base='.Length)).TrimEnd('\')
    $expectedRoot = [IO.Path]::GetFullPath($root).TrimEnd('\')
    if (-not $vbuddyActualRoot.Equals($expectedRoot,[StringComparison]::OrdinalIgnoreCase)) { throw "vBuddy Skill 路径不匹配：$vbuddyActualRoot" }
    foreach ($relative in @('SKILL.md','references\ingest.md','references\query.md','references\project.md','references\maintenance.md','references\update.md')) {
      $sourceFile = Join-Path $root ('integrations\vbuddy\work-knowledge\' + $relative)
      $installedFile = Join-Path $vbuddyInstalled $relative
      if (-not (Test-Path -LiteralPath $installedFile -PathType Leaf)) { throw "已安装 vBuddy Skill 缺少文件：$relative" }
      if ((Get-FileHash -LiteralPath $sourceFile).Hash -ne (Get-FileHash -LiteralPath $installedFile).Hash) { throw "已安装 vBuddy Skill 与仓库版本不一致：$relative" }
    }
    Write-Host "vBuddy 全局 Skill 检查通过：$vbuddyInstalled"
  } else { throw '缺少 vBuddy Skill；请执行 scripts\install-vbuddy-skill.ps1' }
 }
}
Write-Host "知识库框架、读写能力和 Agent 接入检查通过：$root"
