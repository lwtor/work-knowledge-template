#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
用法：
  ./scripts/update-framework.sh [模板目录或 GitHub URL] --yes

说明：
  只更新知识库框架文件，不修改个人数据目录。
  必须显式提供 --yes；目标仓库存在未提交修改时会停止。
EOF
}

source_ref=""
confirmed="no"
for arg in "$@"; do
  case "$arg" in
    --yes) confirmed="yes" ;;
    -h|--help) usage; exit 0 ;;
    *)
      if [[ -n "$source_ref" ]]; then
        echo "错误：只能指定一个模板目录或 URL。" >&2
        exit 1
      fi
      source_ref="$arg"
      ;;
  esac
done

if [[ -z "$source_ref" || "$confirmed" != "yes" ]]; then
  usage >&2
  exit 1
fi

root="$(cd "$(dirname "$0")/.." && pwd)"
command -v git >/dev/null 2>&1 || { echo "错误：需要 Git。" >&2; exit 1; }

if [[ ! -d "$root/.git" ]]; then
  echo "错误：当前知识库不是 Git 仓库，请先初始化或克隆个人知识库。" >&2
  exit 1
fi

[[ -f "$root/.kb-role" && "$(tr -d '[:space:]' < "$root/.kb-role")" == "personal" ]] || {
  echo "错误：当前目录不是个人知识库仓库，拒绝执行框架更新。" >&2
  exit 1
}

if [[ -n "$(git -C "$root" status --porcelain)" ]]; then
  echo "错误：当前知识库有未提交修改。请先提交或保存后再更新框架。" >&2
  exit 1
fi

temp_dir=""
cleanup() {
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir"
}
trap cleanup EXIT

local_rules_backup=""
if [[ -f "$root/AI/LOCAL.md" ]]; then
  local_rules_backup="$(mktemp /tmp/kb-local-rules.XXXXXX)"
  cp "$root/AI/LOCAL.md" "$local_rules_backup"
fi

if [[ -d "$source_ref" ]]; then
  source_dir="$(cd "$source_ref" && pwd)"
else
  temp_dir="$(mktemp -d /tmp/kb-template-update.XXXXXX)"
  git clone --depth 1 "$source_ref" "$temp_dir/source" >/dev/null
  source_dir="$temp_dir/source"
fi

required=("README.md" "AGENTS.md" "Home.md" "AI" "Templates" "scripts" "integrations" ".gitignore" ".kb-version")
for path in "${required[@]}"; do
  [[ -e "$source_dir/$path" ]] || { echo "错误：模板缺少 $path。" >&2; exit 1; }
done

[[ -f "$source_dir/.kb-role" && "$(tr -d '[:space:]' < "$source_dir/.kb-role")" == "template" ]] || {
  echo "错误：来源不是模板仓库，拒绝更新。" >&2
  exit 1
}

backup_dir="$root/.kb-backups/framework-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"

if [[ -e "$root/skills" ]]; then
  [[ -f "$root/skills/README.md" ]] && grep -Fq '# Agent Skills' "$root/skills/README.md" || {
    echo "错误：发现非旧版知识库框架管理的 skills/，拒绝自动删除。" >&2
    exit 1
  }
  cp -R "$root/skills" "$backup_dir/"
fi

framework_paths=("README.md" "AGENTS.md" "Home.md" "AI" "Templates" "scripts" "integrations" ".gitignore" ".kb-version")
for path in "${framework_paths[@]}"; do
  if [[ -e "$root/$path" ]]; then
    mkdir -p "$backup_dir/$(dirname "$path")"
    cp -R "$root/$path" "$backup_dir/$(dirname "$path")/"
  fi
done

for path in "${framework_paths[@]}"; do
  rm -rf "$root/$path"
  cp -R "$source_dir/$path" "$root/$path"
done

if [[ -e "$root/skills" ]]; then
  rm -rf "$root/skills"
  echo "已迁移并移除旧通用 skills/；备份保存在框架备份目录。"
fi

if [[ -n "$local_rules_backup" ]]; then
  cp "$local_rules_backup" "$root/AI/LOCAL.md"
  rm -f "$local_rules_backup"
fi

echo "框架更新完成。"
echo "个人数据目录未被操作：Knowledge Projects Daily Inbox Attachments"
echo "框架备份：$backup_dir"
echo "请运行：./scripts/verify.sh"
