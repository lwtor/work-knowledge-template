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
  "Knowledge/README.md" "Knowledge/INDEX.md" "Projects/README.md" "Projects/INDEX.md" "Projects/TASKS.md" "Cases/README.md" "Cases/INDEX.md" "Inbox/README.md" "Daily/README.md" "AI/待复核清单.md"
  "Templates/知识笔记.md" "Templates/项目总览.md" "Templates/问题解决.md" "Templates/日常记录.md"
  "Templates/需求主页.md" "Templates/案例复盘.md" "Templates/案例原始对话.md" "Templates/快速记录.md" "Templates/文档学习笔记.md"
  "scripts/install-codex-skill.ps1"
  "scripts/install-codex-skill.sh"
  "scripts/install-bluecode-skill.ps1"
  "scripts/install-bluecode-skill.sh"
  "scripts/install-vbuddy-skill.ps1"
  "scripts/install-vbuddy-skill.sh"
  "scripts/verify.ps1"
  "scripts/update-framework.ps1"
  "scripts/kb_common.py" "scripts/kb-index.py" "scripts/kb-lint.py" "scripts/kb-secret-scan.py" "scripts/kb-target-check.py" "scripts/kb-skill-info.py"
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
  ".obsidian/appearance.json" ".obsidian/app.json" ".obsidian/snippets/work-knowledge-navigation.css"
  ".gitignore" ".gitattributes"
)
required+=(
  ".kb-layout-version" "MIGRATION.md" "Vault/首页.md"
  "Vault/01-知识/INDEX.md" "Vault/02-项目/INDEX.md" "Vault/02-项目/需求中心.md" "Vault/03-案例/INDEX.md"
  "Vault/.obsidian/app.json" "scripts/kb_layout.py" "scripts/kb-migrate-layout.py" "scripts/migrate-layout.ps1" "scripts/migrate-layout.sh"
  "Vault/.obsidian/appearance.json" "Vault/.obsidian/snippets/work-knowledge-vault.css"
  "integrations/shared/work-knowledge/references/interaction.md" "integrations/shared/work-knowledge/references/content-routing.md" "scripts/sync-agent-interaction.py"
)
for agent_name in codex bluecode vbuddy; do
  required+=("integrations/$agent_name/work-knowledge/references/layout.md" "integrations/$agent_name/work-knowledge/references/migration.md" "integrations/$agent_name/work-knowledge/references/interaction.md" "integrations/$agent_name/work-knowledge/references/content-routing.md" "integrations/$agent_name/work-knowledge/.skill-version")
done
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
  framework_version="$(tr -d '\r\n' < "$root/.kb-version")"
  for marker in "framework-v$framework_version" "当前框架版本：**$framework_version**"; do
    grep -Fq "$marker" "$root/README.md" || { echo "README.md 显示版本与 .kb-version 不一致：$marker" >&2; exit 1; }
  done
  for marker in '查看知识库状态' '我现在该去哪里' 'work-knowledge-navigation'; do
    grep -Fq "$marker" "$root/Home.md" || { echo "Home.md 缺少日常入口：$marker" >&2; exit 1; }
  done
  for agent_name in codex bluecode vbuddy; do
    for marker in 'name: work-knowledge' 'description:' 'references/layout.md' 'references/interaction.md' 'references/content-routing.md' '.skill-version' 'references/ingest.md' 'references/query.md' 'references/project.md' 'references/maintenance.md' 'references/update.md' 'references/migration.md'; do
      grep -Fq "$marker" "$root/integrations/$agent_name/work-knowledge/SKILL.md" || { echo "$agent_name Skill 入口缺少契约：$marker" >&2; exit 1; }
    done
    cmp -s "$root/integrations/shared/work-knowledge/references/interaction.md" "$root/integrations/$agent_name/work-knowledge/references/interaction.md" || { echo "$agent_name 交互规则与共享权威文件不一致；请运行 python scripts/sync-agent-interaction.py" >&2; exit 1; }
    cmp -s "$root/integrations/shared/work-knowledge/references/content-routing.md" "$root/integrations/$agent_name/work-knowledge/references/content-routing.md" || { echo "$agent_name 内容分类规则与共享权威文件不一致；请运行 python scripts/sync-agent-interaction.py" >&2; exit 1; }
    for marker in '## Destination gate' 'kb-target-check.py' 'AI 使用案例' 'Do not ask them to reconfirm' 'Do not split every case by default' '原始记录' 'one shared case_id' '记录类型' 'KSP'; do
      grep -Fq "$marker" "$root/integrations/$agent_name/work-knowledge/references/content-routing.md" || { echo "$agent_name 内容分类规则缺少契约：$marker" >&2; exit 1; }
    done
    for marker in '## ⚠️ 需要你确认' '## ➡️ 可选的下一步' 'Reply `0`' '回复数字' 'most recent action block' 'recompute all currently applicable actions' 'Choosing one item does not dismiss the others' '确认按上述预览写入知识库，不提交、不推送' '确认将上述本地提交推送到已显示的远程分支'; do
      grep -Fq "$marker" "$root/integrations/$agent_name/work-knowledge/references/interaction.md" || { echo "$agent_name 强提示规则缺少契约：$marker" >&2; exit 1; }
    done
    for marker in 'recursively enumerate' 'skill_version' 'skill_rules_sha256' '重新安装当前 Agent 的知识库 Skill' '.kb-version' 'raw.githubusercontent.com/lwtor/work-knowledge-template/main/.kb-version' 'Do not inspect only the first directory level' 'current branch' 'knowledge health' '查看知识库状态' 'Recompute the pending-action queue' 'Choosing one item does not dismiss the others'; do
      grep -Fq "$marker" "$root/integrations/$agent_name/work-knowledge/references/query.md" || { echo "$agent_name 查询规则缺少状态契约：$marker" >&2; exit 1; }
    done
    for marker in 'references/content-routing.md' 'kb-target-check.py' '知识库根目录' 'Templates/' 'complete frontmatter' 'confidence: unverified' '记录类型' '目标位置' '记录重点' 'explicitly requested linked case transcript' 'existing Git working-tree changes' 'numbered required-confirmation block' '确认按上述预览写入知识库，不提交、不推送' 'recomputed optional-action queue' 'Include every other still-applicable action too' '确认展示本次知识库变更并创建本地提交，不推送' 'separate explicit authorization'; do
      grep -Fq "$marker" "$root/integrations/$agent_name/work-knowledge/references/ingest.md" || { echo "$agent_name 写入规则缺少收尾契约：$marker" >&2; exit 1; }
    done
    for marker in '确认按上述预览归档指定笔记，不提交、不推送' '确认删除上述指定文件，不提交、不推送' '确认按上述预览合并指定笔记，不提交、不推送' '确认按上述预览移动指定文件，不提交、不推送'; do
      grep -Fq "$marker" "$root/integrations/$agent_name/work-knowledge/references/maintenance.md" || { echo "$agent_name 维护规则缺少确认契约：$marker" >&2; exit 1; }
    done
    for marker in 'raw.githubusercontent.com/lwtor/work-knowledge-template/main/UPDATE.md' 'temporary authority' 'preserve their union' 'Never use an old updater' 'no staged changes' 'framework allowlist' 'framework update has not started' 'numbered optional-action block' 'Choosing the commit does not dismiss migration' 'include item 0' '确认展示阻塞更新的现有修改' '确认提交已展示的现有修改' '## ➡️ 可选的下一步' '确认展示框架变更并创建本地提交，不推送' '确认生成目录迁移预览'; do
      grep -Fq "$marker" "$root/integrations/$agent_name/work-knowledge/references/update.md" || { echo "$agent_name 更新规则缺少跨版本契约：$marker" >&2; exit 1; }
    done
  done
  for marker in 'resume-framework-update' 'Knowledge/INDEX.md' '续跑检查通过' 'work-knowledge-navigation' '已保留现有 Obsidian 外观设置'; do
    grep -Fq "$marker" "$root/scripts/update-framework.sh" || { echo "Bash 更新器缺少兼容迁移契约：$marker" >&2; exit 1; }
  done
fi
echo "知识库框架检查通过：$root"
assert_skill_marker() {
  local agent_name="$1" marker_path="$2" expected_line
  while IFS= read -r expected_line; do
    grep -Fqx "$expected_line" "$marker_path" || { echo "$agent_name Skill marker 版本或规则哈希不一致：$expected_line" >&2; exit 1; }
  done < <(python "$root/scripts/kb-skill-info.py" --root "$root" --agent "$agent_name")
  grep -Fq 'installed_at=' "$marker_path" || { echo "$agent_name Skill marker 缺少 installed_at" >&2; exit 1; }
}
if [[ -f "$root/.kb-role" ]] && [[ "$(tr -d '\r\n' < "$root/.kb-role")" == "personal" ]]; then
 command -v cygpath >/dev/null 2>&1 && expected="$(cygpath -w "$root")" || expected="$root"
 if [[ "$agent" == "codex" || "$agent" == "all" ]]; then
  home="${CODEX_HOME:-$HOME/.codex}"
  command -v cygpath >/dev/null 2>&1 && home="$(cygpath -u "$home")"
  skill="$home/skills/work-knowledge/SKILL.md"
  marker="$home/skills/work-knowledge/.managed-by-work-knowledge-template"
  [[ -f "$skill" && -f "$marker" ]] || { echo "缺少 Codex skill；请执行 ./scripts/install-codex-skill.sh" >&2; exit 1; }
  grep -Fq "knowledge_base=$expected" "$marker" || { echo "Codex skill 路径不匹配；请重新安装" >&2; exit 1; }
  assert_skill_marker codex "$marker"
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
    assert_skill_marker bluecode "$bmarker"
    for relative in SKILL.md .skill-version references/layout.md references/interaction.md references/content-routing.md references/ingest.md references/query.md references/project.md references/maintenance.md references/update.md references/migration.md; do cmp -s "$root/integrations/bluecode/work-knowledge/$relative" "$bdir/$relative" || { echo "BlueCode skill 与仓库版本不一致：$relative" >&2; exit 1; }; done
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
    assert_skill_marker vbuddy "$vmarker"
    for relative in SKILL.md .skill-version references/layout.md references/interaction.md references/content-routing.md references/ingest.md references/query.md references/project.md references/maintenance.md references/update.md references/migration.md; do cmp -s "$root/integrations/vbuddy/work-knowledge/$relative" "$vdir/$relative" || { echo "vBuddy skill 与仓库版本不一致：$relative" >&2; exit 1; }; done
    echo "vBuddy 全局知识库 skill 检查通过：$vdir/SKILL.md"
  else
    echo "缺少 vBuddy skill；请执行 ./scripts/install-vbuddy-skill.sh" >&2; exit 1
  fi
 fi
fi
