#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
用法：
  ./scripts/setup.sh /path/to/local-knowledge-base

说明：
  将当前 GitHub 模板安全复制到新的本地知识库目录。
  目标目录不存在时会创建；目标目录存在且非空时会停止，不会覆盖内容。
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -eq 0 ]]; then
  usage
  [[ $# -eq 0 ]] && exit 1 || exit 0
fi

source_dir="$(cd "$(dirname "$0")/.." && pwd)"
target_dir="$1"

if [[ -e "$target_dir" && ! -d "$target_dir" ]]; then
  echo "错误：目标路径不是目录：$target_dir" >&2
  exit 1
fi

if [[ -d "$target_dir" ]] && [[ -n "$(find "$target_dir" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
  echo "错误：目标目录非空，为避免覆盖已停止：$target_dir" >&2
  echo "请指定一个新的空目录，或由你先确认如何处理已有内容。" >&2
  exit 1
fi

mkdir -p "$target_dir"

if command -v rsync >/dev/null 2>&1; then
  rsync -a \
    --exclude '.git/' \
    --exclude '.obsidian/workspace.json' \
    --exclude '.obsidian/workspace-mobile.json' \
    "$source_dir/" "$target_dir/"
else
  cp -R "$source_dir/." "$target_dir/"
  rm -f "$target_dir/.obsidian/workspace.json" "$target_dir/.obsidian/workspace-mobile.json"
  rm -rf "$target_dir/.git"
fi

if [[ -f "$target_dir/.kb-role" ]]; then
  printf 'personal\n' > "$target_dir/.kb-role"
fi

cat <<EOF
知识库模板初始化完成。

本地路径：$target_dir
仓库角色：personal

下一步：
1. 用 Obsidian 打开这个目录；
2. 让 AI Agent 读取 AI/启动配置.md 和 AI/AI-GUIDE.md；
3. 先执行读取和搜索测试，再开始写入内容。
EOF
