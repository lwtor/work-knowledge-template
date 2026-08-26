#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
required=(
  "README.md" "Home.md" "AGENTS.md"
  "AI/启动配置.md" "AI/AI-GUIDE.md"
  "Knowledge/README.md" "Projects/README.md" "Inbox/README.md" "Daily/README.md"
  "Templates/知识笔记.md" "Templates/项目总览.md" "Templates/问题解决.md" "Templates/日常记录.md"
  "scripts/install-codex-skill.ps1"
  "scripts/install-codex-skill.sh"
  "scripts/verify.ps1"
  "integrations/codex/work-knowledge/SKILL.md"
  "integrations/codex/work-knowledge/references/ingest.md"
  "integrations/codex/work-knowledge/references/query.md"
  "integrations/codex/work-knowledge/references/project.md"
  ".gitignore"
)
[[ -f "$root/BOOTSTRAP.md" || -f "$root/.kb-role" ]] || { echo "缺少 BOOTSTRAP.md 或 .kb-role" >&2; exit 1; }
for path in "${required[@]}"; do [[ -f "$root/$path" ]] || { echo "缺少文件：$path" >&2; exit 1; }; done
[[ ! -e "$root/skills" ]] || { echo "发现旧的通用 skills/ 目录；当前只支持 integrations/codex。" >&2; exit 1; }
if rg -n '小V Copilot|发送按钮|WebSocket|示例-Git|code_analysis|xiaoV' "$root/Knowledge" "$root/Projects" --glob '*.md' >/dev/null 2>&1; then
  echo "发现不应出现在空白模板中的业务或示例资料。" >&2
  exit 1
fi
echo "知识库框架检查通过：$root"
if [[ -f "$root/.kb-role" ]] && [[ "$(tr -d '\r\n' < "$root/.kb-role")" == "personal" ]]; then
  home="${CODEX_HOME:-$HOME/.codex}"
  command -v cygpath >/dev/null 2>&1 && home="$(cygpath -u "$home")"
  skill="$home/skills/work-knowledge/SKILL.md"
  marker="$home/skills/work-knowledge/.managed-by-work-knowledge-template"
  [[ -f "$skill" && -f "$marker" ]] || { echo "缺少 Codex skill；请执行 ./scripts/install-codex-skill.sh" >&2; exit 1; }
  command -v cygpath >/dev/null 2>&1 && expected="$(cygpath -w "$root")" || expected="$root"
  grep -Fq "knowledge_base=$expected" "$marker" || { echo "Codex skill 路径不匹配；请重新安装" >&2; exit 1; }
  echo "Codex 全局知识库 skill 检查通过：$skill"
fi
