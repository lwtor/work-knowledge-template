#!/usr/bin/env bash
set -euo pipefail
input="${1:-$(dirname "$0")/..}"
command -v cygpath >/dev/null 2>&1 && input="$(cygpath -u "$input")"
root="$(cd "$input" && pwd)"
source_dir="$root/integrations/codex/work-knowledge"
for f in AGENTS.md AI/启动配置.md AI/AI-GUIDE.md "$source_dir/SKILL.md" "$source_dir/references/ingest.md" "$source_dir/references/query.md" "$source_dir/references/project.md"; do
  [[ -f "$f" ]] || { echo "错误：缺少 $f" >&2; exit 1; }
done
command -v cygpath >/dev/null 2>&1 && kb_path="$(cygpath -w "$root")" || kb_path="$root"
home="${CODEX_HOME:-$HOME/.codex}"
command -v cygpath >/dev/null 2>&1 && home="$(cygpath -u "$home")"
dir="$home/skills/work-knowledge"
marker="$dir/.managed-by-work-knowledge-template"
[[ ! -e "$dir" || -f "$marker" ]] || { echo "错误：存在非模板管理的 $dir，已停止" >&2; exit 1; }
mkdir -p "$dir"
find "$dir" -mindepth 1 -maxdepth 1 ! -name '.managed-by-work-knowledge-template' -exec rm -rf {} +
cp -R "$source_dir/." "$dir/"
printf 'manager=work-knowledge-template\nknowledge_base=%s\n' "$kb_path" > "$marker"
echo "Codex skill 安装完成：$dir"
