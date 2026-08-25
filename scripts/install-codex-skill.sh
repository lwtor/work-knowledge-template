#!/usr/bin/env bash
set -euo pipefail
input="${1:-$(dirname "$0")/..}"
command -v cygpath >/dev/null 2>&1 && input="$(cygpath -u "$input")"
root="$(cd "$input" && pwd)"
for f in AGENTS.md AI/启动配置.md AI/AI-GUIDE.md; do [[ -f "$root/$f" ]] || { echo "错误：缺少 $f" >&2; exit 1; }; done
command -v cygpath >/dev/null 2>&1 && kb_path="$(cygpath -w "$root")" || kb_path="$root"
home="${CODEX_HOME:-$HOME/.codex}"
command -v cygpath >/dev/null 2>&1 && home="$(cygpath -u "$home")"
dir="$home/skills/work-knowledge"; marker="$dir/.managed-by-work-knowledge-template"
[[ ! -e "$dir" || -f "$marker" ]] || { echo "错误：存在非模板管理的 $dir，已停止" >&2; exit 1; }
mkdir -p "$dir"
cat > "$dir/SKILL.md" <<EOF
---
name: work-knowledge
description: Use the user's existing personal work knowledge base when asked to record, remember, save, summarize, organize, retrieve, search, or update work knowledge. Do not use its stored path for bootstrap, create, initialize, install, clone, or connect requests; those must follow BOOTSTRAP.md and the current request.
---

# Personal Work Knowledge Base

The canonical root for ordinary use of the existing knowledge base is \`$kb_path\`.

Bootstrap boundary: if the current request references \`BOOTSTRAP.md\` or asks to create, initialize, install, clone, or connect a knowledge base, do not use, reveal, or infer a local path from this skill. Stop applying this skill and follow \`BOOTSTRAP.md\`. A missing, empty, or unchanged placeholder path must be asked for once before any clone or local initialization begins.

For ordinary recording, retrieval, and organization of the existing knowledge base, use the canonical root without asking for it again. Read \`AGENTS.md\`, \`AI/启动配置.md\`, \`AI/AI-GUIDE.md\`, \`AI/LOCAL.md\`, and the relevant repository skill before operating. Use only conversation content visible in the current task and follow all repository safety and confirmation rules. Never upload or delete without separate authorization.
EOF
printf 'manager=work-knowledge-template\nknowledge_base=%s\n' "$kb_path" > "$marker"
echo "Codex skill 安装完成：$dir"
