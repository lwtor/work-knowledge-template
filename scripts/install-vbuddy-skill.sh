#!/usr/bin/env bash
set -euo pipefail
input="${1:-$(dirname "$0")/..}"
command -v cygpath >/dev/null 2>&1 && input="$(cygpath -u "$input")"
root="$(cd "$input" && pwd)"
[[ -f "$root/.kb-role" && "$(tr -d '[:space:]' < "$root/.kb-role")" == "personal" ]] || { echo "错误：只能从 personal 知识库安装 Skill。" >&2; exit 1; }
source_dir="$root/integrations/vbuddy/work-knowledge"
for f in AGENTS.md AI/启动配置.md AI/AI-GUIDE.md AI/知识维护.md "$source_dir/SKILL.md" "$source_dir/.skill-version" "$root/scripts/kb-skill-info.py" "$source_dir/references/ingest.md" "$source_dir/references/query.md" "$source_dir/references/project.md" "$source_dir/references/maintenance.md" "$source_dir/references/update.md"; do
  [[ -f "$f" ]] || { echo "错误：缺少 $f" >&2; exit 1; }
done
command -v cygpath >/dev/null 2>&1 && kb_path="$(cygpath -w "$root")" || kb_path="$root"
home="${VBUDDY_HOME:-$HOME/.vbuddy}"
command -v cygpath >/dev/null 2>&1 && home="$(cygpath -u "$home")"
dir="$home/skills/work-knowledge"
marker="$dir/.managed-by-work-knowledge-template"
[[ ! -e "$dir" || -f "$marker" ]] || { echo "错误：存在非模板管理的 $dir，已停止" >&2; exit 1; }
parent="$(dirname "$dir")"
mkdir -p "$parent"
staging="$(mktemp -d "$parent/work-knowledge.installing.XXXXXX")"
cleanup() { [[ ! -d "$staging" ]] || rm -rf "$staging"; }
trap cleanup EXIT
cp -R "$source_dir/." "$staging/"
skill_info="$(python "$root/scripts/kb-skill-info.py" --root "$root" --agent vbuddy)"
printf 'manager=work-knowledge-template\nknowledge_base=%s\n%s\ninstalled_at=%s\n' "$kb_path" "$skill_info" "$(date -Iseconds)" > "$staging/.managed-by-work-knowledge-template"
rm -rf "$dir"
mv "$staging" "$dir"
trap - EXIT
echo "vBuddy skill 安装完成：$dir"
echo "请新开一个 vBuddy 会话使 Skill 生效（vBuddy 在每个会话启动时加载全局 Skill，无需重启进程）。"
