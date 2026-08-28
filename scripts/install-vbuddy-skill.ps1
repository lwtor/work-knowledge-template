param([string]$KnowledgeBaseRoot = (Split-Path -Parent $PSScriptRoot), [string]$VbuddyHome = '')
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $KnowledgeBaseRoot).Path
$source = Join-Path $root 'integrations\vbuddy\work-knowledge'
$required = @('AGENTS.md','AI\启动配置.md','AI\AI-GUIDE.md','AI\知识维护.md','integrations\vbuddy\work-knowledge\SKILL.md','integrations\vbuddy\work-knowledge\references\ingest.md','integrations\vbuddy\work-knowledge\references\query.md','integrations\vbuddy\work-knowledge\references\project.md','integrations\vbuddy\work-knowledge\references\maintenance.md','integrations\vbuddy\work-knowledge\references\update.md')
foreach ($relative in $required) { if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) { throw "缺少文件：$relative" } }
$configuredHome = $VbuddyHome
if ([string]::IsNullOrWhiteSpace($configuredHome)) { $configuredHome = [Environment]::GetEnvironmentVariable('VBUDDY_HOME') }
if ([string]::IsNullOrWhiteSpace($configuredHome)) { $configuredHome = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.vbuddy' }
$target = Join-Path $configuredHome 'skills\work-knowledge'
$marker = Join-Path $target '.managed-by-work-knowledge-template'
if ((Test-Path -LiteralPath $target) -and -not (Test-Path -LiteralPath $marker -PathType Leaf)) { throw "存在非本模板管理的 vBuddy Skill：$target" }
New-Item -ItemType Directory -Force -Path $target | Out-Null
Get-ChildItem -Force -LiteralPath $target | Where-Object { $_.Name -ne '.managed-by-work-knowledge-template' } | Remove-Item -Recurse -Force
Copy-Item -Path (Join-Path $source '*') -Destination $target -Recurse -Force
$lines = @('manager=work-knowledge-template',"knowledge_base=$root")
[IO.File]::WriteAllText($marker,(($lines -join [char]10)+[char]10),(New-Object System.Text.UTF8Encoding($false)))
Write-Host "vBuddy Skill 安装完成：$target"
Write-Host "知识库路径：$root"
Write-Host "请开启新的 vBuddy 会话使 Skill 生效（vBuddy 在每个会话启动时加载全局 Skill，无需重启进程）。"
