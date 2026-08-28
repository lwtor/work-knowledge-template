#!/usr/bin/env bash
set -euo pipefail
agent="codex"
if [[ "${1:-}" == "--agent" ]]; then [[ $# -eq 2 ]] || { echo "用法：$0 [--agent codex|bluecode|vbuddy|all|framework]" >&2; exit 1; }; agent="$2"; fi
case "$agent" in codex|bluecode|vbuddy|all|framework) ;; *) echo "未知 Agent：$agent" >&2; exit 1 ;; esac
root="$(cd "$(dirname "$0")/.." && pwd)"
required=(
  "README.md" "Home.md" "AGENTS.md"
  "AI/启动配置.md" "AI/AI-GUIDE.md"
  "AI/知识维护.md" "AI/写入日志/README.md" "Archive/README.md"
  "Knowledge/README.md" "Knowledge/INDEX.md" "Projects/README.md" "Projects/INDEX.md" "Projects/TASKS.md" "Inbox/README.md" "Daily/README.md" "AI/待复核清单.md"
  "Templates/知识笔记.md" "Templates/项目总览.md" "Templates/问题解决.md" "Templates/日常记录.md"
  "scripts/install-codex-skill.ps1"
  "scripts/install-codex-skill.sh"
  "scripts/install-bluecode-skill.ps1"
  "scripts/install-bluecode-skill.sh"
  "scripts/install-vbuddy-skill.ps1"
  "scripts/install-vbuddy-skill.sh"
  "scripts/verify.ps1"
  "scripts/update-framework.ps1"
  "scripts/kb_common.py" "scripts/kb-index.py" "scripts/kb-lint.py" "scripts/kb-secret-scan.py"
  "AI/框架更新.md"
  "integrations/codex/work-knowledge/SKILL.md"
  "integrations/codex/work-knowledge/references/ingest.md"
  "integrations/codex/work-knowledge/references/query.md"
  "integrations/codex/work-knowledge/references/project.md"
  "integrations/codex/work-knowledge/references/maintenance.md"
  "integrations/codex/work-knowledge/references/update.md"
  "integrations/bluecode/work-knowledge/SKILL.md"
  "integrations/bluecode/work-knowledge/references/ingest.md"
  "integrations/bluecode/work-knowledge/references/query.md"
  "integrations/bluecode/work-knowledge/references/project.md"
  "integrations/bluecode/work-knowledge/references/maintenance.md"
  "integrations/bluecode/work-knowledge/references/update.md"
  "integrations/vbuddy/work-knowledge/SKILL.md"
  "integrations/vbuddy/work-knowledge/references/ingest.md"
  "integrations/vbuddy/work-knowledge/references/query.md"
  "integrations/vbuddy/work-knowledge/references/project.md"
  "integrations/vbuddy/work-knowledge/references/maintenance.md"
  "integrations/vbuddy/work-knowledge/references/update.md"
  ".gitignore" ".gitattributes"
)
[[ -f "$root/BOOTSTRAP.md" || -f "$root/.kb-role" ]] || { echo "缺少 BOOTSTRAP.md 或 .kb-role" >&2; exit 1; }
for path in "${required[@]}"; do [[ -f "$root/$path" ]] || { echo "缺少文件：$path" >&2; exit 1; }; done
[[ ! -e "$root/skills" ]] || { echo "发现旧的通用 skills/ 目录；当前只支持 integrations/codex、integrations/bluecode 与 integrations/vbuddy。" >&2; exit 1; }
if rg -n '小V Copilot|发送按钮|WebSocket|示例-Git|code_analysis|xiaoV' "$root/Knowledge" "$root/Projects" --glob '*.md' >/dev/null 2>&1; then
  echo "发现不应出现在空白模板中的业务或示例资料。" >&2
  exit 1
fi
if [[ -f "$root/.kb-role" ]] && [[ "$(tr -d '\r\n' < "$root/.kb-role")" == "template" ]] && [[ ! -f "$root/UPDATE.md" ]]; then
  echo "模板仓库缺少 UPDATE.md" >&2
  exit 1
fi
if [[ -f "$root/.kb-role" ]] && [[ "$(tr -d '\r\n' < "$root/.kb-role")" == "template" ]]; then
  for marker in '.kb-version' '当前框架版本' '模板最新版本' '更新状态'; do
    grep -Fq "$marker" "$root/BOOTSTRAP.md" || { echo "BOOTSTRAP.md 缺少版本报告要求：$marker" >&2; exit 1; }
  done
  for agent_name in codex bluecode vbuddy; do
    for marker in 'name: work-knowledge' 'description:' 'references/ingest.md' 'references/query.md' 'references/project.md' 'references/maintenance.md' 'references/update.md'; do
      grep -Fq "$marker" "$root/integrations/$agent_name/work-knowledge/SKILL.md" || { echo "$agent_name Skill 入口缺少契约：$marker" >&2; exit 1; }
    done
    for marker in 'Recursively enumerate' '.kb-version' 'raw.githubusercontent.com/lwtor/work-knowledge-template/main/.kb-version' 'Do not inspect only the first directory level'; do
      grep -Fq "$marker" "$root/integrations/$agent_name/work-knowledge/references/query.md" || { echo "$agent_name 查询规则缺少概览契约：$marker" >&2; exit 1; }
    done
    for marker in 'Templates/' 'complete frontmatter' 'confidence: unverified'; do
      grep -Fq "$marker" "$root/integrations/$agent_name/work-knowledge/references/ingest.md" || { echo "$agent_name 写入规则缺少模板契约：$marker" >&2; exit 1; }
    done
    for marker in 'raw.githubusercontent.com/lwtor/work-knowledge-template/main/UPDATE.md' 'temporary authority' 'preserve their union' 'Never use an old updater' 'no staged changes' 'framework allowlist'; do
      grep -Fq "$marker" "$root/integrations/$agent_name/work-knowledge/references/update.md" || { echo "$agent_name 更新规则缺少跨版本契约：$marker" >&2; exit 1; }
    done
  done
  for marker in 'resume-framework-update' 'Knowledge/INDEX.md' '续跑检查通过'; do
    grep -Fq "$marker" "$root/scripts/update-framework.sh" || { echo "Bash 更新器缺少兼容迁移契约：$marker" >&2; exit 1; }
  done
fi
echo "知识库框架检查通过：$root"
if [[ -f "$root/.kb-role" ]] && [[ "$(tr -d '\r\n' < "$root/.kb-role")" == "personal" ]]; then
 command -v cygpath >/dev/null 2>&1 && expected="$(cygpath -w "$root")" || expected="$root"
 if [[ "$agent" == "codex" || "$agent" == "all" ]]; then
  home="${CODEX_HOME:-$HOME/.codex}"
  command -v cygpath >/dev/null 2>&1 && home="$(cygpath -u "$home")"
  skill="$home/skills/work-knowledge/SKILL.md"
  marker="$home/skills/work-knowledge/.managed-by-work-knowledge-template"
  [[ -f "$skill" && -f "$marker" ]] || { echo "缺少 Codex skill；请执行 ./scripts/install-codex-skill.sh" >&2; exit 1; }
  grep -Fq "knowledge_base=$expected" "$marker" || { echo "Codex skill 路径不匹配；请重新安装" >&2; exit 1; }
  echo "Codex 全局知识库 skill 检查通过：$skill"
 fi
 if [[ "$agent" == "bluecode" || "$agent" == "all" ]]; then
  bhome="${BLUECODE_HOME:-$HOME/.bluecode}"
  command -v cygpath >/dev/null 2>&1 && bhome="$(cygpath -u "$bhome")"
  bdir="$bhome/skills/work-knowledge"
  bmarker="$bdir/.managed-by-work-knowledge-template"
  if [[ -e "$bdir" ]]; then
    [[ -f "$bdir/SKILL.md" && -f "$bmarker" ]] || { echo "存在非模板管理的 BlueCode skill：$bdir" >&2; exit 1; }
    grep -Fq "knowledge_base=$expected" "$bmarker" || { echo "BlueCode skill 路径不匹配；请重新安装" >&2; exit 1; }
    for relative in SKILL.md references/ingest.md references/query.md references/project.md references/maintenance.md references/update.md; do cmp -s "$root/integrations/bluecode/work-knowledge/$relative" "$bdir/$relative" || { echo "BlueCode skill 与仓库版本不一致：$relative" >&2; exit 1; }; done
    echo "BlueCode 全局知识库 skill 检查通过：$bdir/SKILL.md"
  else
    echo "缺少 BlueCode skill；请执行 ./scripts/install-bluecode-skill.sh" >&2; exit 1
  fi
 fi
 if [[ "$agent" == "vbuddy" || "$agent" == "all" ]]; then
  vhome="${VBUDDY_HOME:-$HOME/.vbuddy}"
  command -v cygpath >/dev/null 2>&1 && vhome="$(cygpath -u "$vhome")"
  vdir="$vhome/skills/work-knowledge"
  vmarker="$vdir/.managed-by-work-knowledge-template"
  if [[ -e "$vdir" ]]; then
    [[ -f "$vdir/SKILL.md" && -f "$vmarker" ]] || { echo "存在非模板管理的 vBuddy skill：$vdir" >&2; exit 1; }
    grep -Fq "knowledge_base=$expected" "$vmarker" || { echo "vBuddy skill 路径不匹配；请重新安装" >&2; exit 1; }
    for relative in SKILL.md references/ingest.md references/query.md references/project.md references/maintenance.md references/update.md; do cmp -s "$root/integrations/vbuddy/work-knowledge/$relative" "$vdir/$relative" || { echo "vBuddy skill 与仓库版本不一致：$relative" >&2; exit 1; }; done
    echo "vBuddy 全局知识库 skill 检查通过：$vdir/SKILL.md"
  else
    echo "缺少 vBuddy skill；请执行 ./scripts/install-vbuddy-skill.sh" >&2; exit 1
  fi
 fi
fi
