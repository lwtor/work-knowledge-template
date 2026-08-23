#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
required=(
  "README.md"
  "Home.md"
  "AGENTS.md"
  "AI/启动配置.md"
  "AI/AI-GUIDE.md"
  "Knowledge/README.md"
  "Projects/README.md"
  "Inbox/README.md"
  "Daily/README.md"
  "Templates/知识笔记.md"
  "Templates/项目总览.md"
  "Templates/问题解决.md"
  "Templates/日常记录.md"
  ".gitignore"
)

for path in "${required[@]}"; do
  [[ -f "$root/$path" ]] || { echo "缺少文件：$path" >&2; exit 1; }
done

if rg -n '小V Copilot|发送按钮|WebSocket|示例-Git|code_analysis|xiaoV' \
  "$root/Knowledge" "$root/Projects" --glob '*.md' >/dev/null 2>&1; then
  echo "发现不应出现在空白模板中的业务或示例资料。" >&2
  exit 1
fi

echo "知识库模板检查通过：$root"
