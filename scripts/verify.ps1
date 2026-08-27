param([string]$KnowledgeBaseRoot = (Split-Path -Parent $PSScriptRoot), [string]$CodexHome = '')
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $KnowledgeBaseRoot).Path
$required = @('README.md','Home.md','AGENTS.md','AI\启动配置.md','AI\AI-GUIDE.md','AI\知识维护.md','AI\写入日志\README.md','AI\待复核清单.md','Archive\README.md','Knowledge\README.md','Knowledge\INDEX.md','Projects\README.md','Projects\INDEX.md','Projects\TASKS.md','Inbox\README.md','Daily\README.md','Templates\知识笔记.md','Templates\项目总览.md','Templates\问题解决.md','Templates\日常记录.md','scripts\install-codex-skill.ps1','scripts\install-codex-skill.sh','scripts\verify.ps1','scripts\verify.sh','scripts\update-framework.ps1','scripts\kb_common.py','scripts\kb-index.py','scripts\kb-lint.py','scripts\kb-secret-scan.py','AI\框架更新.md','integrations\codex\work-knowledge\SKILL.md','integrations\codex\work-knowledge\references\ingest.md','integrations\codex\work-knowledge\references\query.md','integrations\codex\work-knowledge\references\project.md','integrations\codex\work-knowledge\references\maintenance.md','.gitignore')
if (-not (Test-Path -LiteralPath (Join-Path $root 'BOOTSTRAP.md') -PathType Leaf) -and -not (Test-Path -LiteralPath (Join-Path $root '.kb-role') -PathType Leaf)) { throw '缺少 BOOTSTRAP.md 或 .kb-role' }
foreach ($relative in $required) { if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) { throw "缺少文件：$relative" } }
if (Test-Path -LiteralPath (Join-Path $root 'skills')) { throw '发现旧的通用 skills 目录；当前只支持 integrations\codex。' }
$writeTest = Join-Path $root ('.kb-write-test-' + [guid]::NewGuid().ToString('N'))
try { [IO.File]::WriteAllText($writeTest,'ok',(New-Object System.Text.UTF8Encoding($false))) } finally { if (Test-Path -LiteralPath $writeTest) { Remove-Item -LiteralPath $writeTest -Force } }
$repoRole = if (Test-Path -LiteralPath (Join-Path $root '.kb-role')) { (Get-Content -Raw -LiteralPath (Join-Path $root '.kb-role')).Trim() } else { '' }
if ($repoRole -eq 'template') {
  if (-not (Test-Path -LiteralPath (Join-Path $root 'UPDATE.md') -PathType Leaf)) { throw '模板仓库缺少 UPDATE.md' }
  $bootstrap = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'BOOTSTRAP.md')
  foreach ($marker in @('.kb-version','当前框架版本','模板最新版本','更新状态')) { if (-not $bootstrap.Contains($marker)) { throw "BOOTSTRAP.md 缺少版本报告要求：$marker" } }
}
$roleFile = Join-Path $root '.kb-role'
if ((Test-Path -LiteralPath $roleFile -PathType Leaf) -and ((Get-Content -Raw -LiteralPath $roleFile).Trim() -eq 'personal')) {
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
  foreach ($relative in @('SKILL.md','references\ingest.md','references\query.md','references\project.md','references\maintenance.md')) {
    $sourceFile = Join-Path $root ('integrations\codex\work-knowledge\' + $relative)
    $installedFile = Join-Path $installed $relative
    if (-not (Test-Path -LiteralPath $installedFile -PathType Leaf)) { throw "已安装 Codex Skill 缺少文件：$relative" }
    if ((Get-FileHash -LiteralPath $sourceFile).Hash -ne (Get-FileHash -LiteralPath $installedFile).Hash) { throw "已安装 Codex Skill 与仓库版本不一致：$relative" }
  }
  Write-Host "Codex 全局 Skill 检查通过：$installed"
}
Write-Host "知识库框架、读写能力和 Codex 接入检查通过：$root"
