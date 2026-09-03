param([string]$KnowledgeBaseRoot = (Split-Path -Parent $PSScriptRoot), [string]$BlueCodeHome = '')
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $KnowledgeBaseRoot).Path
if (-not (Test-Path -LiteralPath (Join-Path $root '.kb-role') -PathType Leaf) -or (Get-Content -Raw -LiteralPath (Join-Path $root '.kb-role')).Trim() -ne 'personal') { throw '只能从 personal 知识库安装 Skill。' }
$source = Join-Path $root 'integrations\bluecode\work-knowledge'
$required = @('AGENTS.md','AI\启动配置.md','AI\AI-GUIDE.md','AI\知识维护.md','integrations\bluecode\work-knowledge\SKILL.md','integrations\bluecode\work-knowledge\.skill-version','scripts\kb-skill-info.py','integrations\bluecode\work-knowledge\references\ingest.md','integrations\bluecode\work-knowledge\references\query.md','integrations\bluecode\work-knowledge\references\project.md','integrations\bluecode\work-knowledge\references\maintenance.md','integrations\bluecode\work-knowledge\references\update.md')
foreach ($relative in $required) { if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) { throw "缺少文件：$relative" } }
$configuredHome = $BlueCodeHome
if ([string]::IsNullOrWhiteSpace($configuredHome)) { $configuredHome = [Environment]::GetEnvironmentVariable('BLUECODE_HOME') }
if ([string]::IsNullOrWhiteSpace($configuredHome)) { $configuredHome = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.bluecode' }
$target = Join-Path $configuredHome 'skills\work-knowledge'
$marker = Join-Path $target '.managed-by-work-knowledge-template'
if ((Test-Path -LiteralPath $target) -and -not (Test-Path -LiteralPath $marker -PathType Leaf)) { throw "存在非本模板管理的 BlueCode Skill：$target" }
$targetParent = Split-Path -Parent $target
New-Item -ItemType Directory -Force -Path $targetParent | Out-Null
$staging = Join-Path $targetParent ('work-knowledge.installing-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Force -Path $staging | Out-Null
    Copy-Item -Path (Join-Path $source '*') -Destination $staging -Recurse -Force
    Copy-Item -LiteralPath (Join-Path $source '.skill-version') -Destination (Join-Path $staging '.skill-version') -Force
    $skillInfo = @(python (Join-Path $root 'scripts\kb-skill-info.py') --root $root --agent bluecode)
    if ($LASTEXITCODE -ne 0) { throw '无法生成 Skill 版本信息。' }
    $lines = @('manager=work-knowledge-template',"knowledge_base=$root") + $skillInfo + @('installed_at=' + (Get-Date -Format o))
    [IO.File]::WriteAllText((Join-Path $staging '.managed-by-work-knowledge-template'),(($lines -join [char]10)+[char]10),(New-Object System.Text.UTF8Encoding($false)))
    if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
    Move-Item -LiteralPath $staging -Destination $target
} finally {
    if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
}
Write-Host "BlueCode Skill 安装完成：$target"
Write-Host "知识库路径：$root"
Write-Host "请重启 BlueCode 使 Skill 生效（BlueCode 在进程启动时加载一次全局 Skill）。"
