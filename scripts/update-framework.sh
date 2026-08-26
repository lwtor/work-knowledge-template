#!/usr/bin/env bash
set -euo pipefail
usage() {
  cat <<'EOF'
用法：
  ./scripts/update-framework.sh [模板目录或 GitHub URL] [--target 个人仓库目录] --yes
只在用户明确要求更新框架并确认范围后执行。不会提交或推送。
EOF
}
source_ref=""; target_ref=""; confirmed="no"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes) confirmed="yes"; shift ;;
    --target) [[ $# -ge 2 ]] || { usage >&2; exit 1; }; target_ref="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) [[ -z "$source_ref" ]] || { echo "错误：只能指定一个模板来源。" >&2; exit 1; }; source_ref="$1"; shift ;;
  esac
done
[[ -n "$source_ref" && "$confirmed" == "yes" ]] || { usage >&2; exit 1; }
script_root="$(cd "$(dirname "$0")/.." && pwd)"
[[ -n "$target_ref" ]] && root="$(cd "$target_ref" && pwd)" || root="$script_root"
[[ -d "$root/.git" ]] || { echo "错误：目标不是 Git 仓库。" >&2; exit 1; }
[[ -f "$root/.kb-role" && "$(tr -d '[:space:]' < "$root/.kb-role")" == "personal" ]] || { echo "错误：目标不是个人知识库。" >&2; exit 1; }
[[ -z "$(git -C "$root" status --porcelain)" ]] || { echo "错误：个人仓库存在未提交修改。" >&2; exit 1; }
temp_dir=""
cleanup() { [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir"; }
trap cleanup EXIT
if [[ -d "$source_ref" ]]; then source_dir="$(cd "$source_ref" && pwd)"; else
  temp_dir="$(mktemp -d /tmp/kb-template-update.XXXXXX)"
  git clone --depth 1 "$source_ref" "$temp_dir/source" >/dev/null
  source_dir="$temp_dir/source"
fi
[[ -f "$source_dir/.kb-role" && "$(tr -d '[:space:]' < "$source_dir/.kb-role")" == "template" ]] || { echo "错误：来源不是模板仓库。" >&2; exit 1; }
source_version="$(tr -d '[:space:]' < "$source_dir/.kb-version")"
target_version="$(tr -d '[:space:]' < "$root/.kb-version")"
[[ "$source_version" != "$target_version" ]] || { echo "当前已是模板版本 $target_version，无需更新。"; exit 0; }
framework=("README.md" "AGENTS.md" "Home.md" "AI" "Templates" "scripts" "integrations" ".gitignore" ".kb-version")
for path in "${framework[@]}"; do [[ -e "$source_dir/$path" ]] || { echo "错误：模板缺少 $path。" >&2; exit 1; }; done
backup="$root/.kb-backups/framework-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"
for path in "${framework[@]}"; do
  if [[ -e "$root/$path" ]]; then mkdir -p "$backup/$(dirname "$path")"; cp -R "$root/$path" "$backup/$(dirname "$path")/"; fi
done
[[ ! -e "$root/skills" ]] || cp -R "$root/skills" "$backup/"
local_rules=""
if [[ -f "$root/AI/LOCAL.md" ]]; then local_rules="$(mktemp /tmp/kb-local-rules.XXXXXX)"; cp "$root/AI/LOCAL.md" "$local_rules"; fi
for path in "${framework[@]}"; do rm -rf "$root/$path"; cp -R "$source_dir/$path" "$root/$path"; done
[[ -z "$local_rules" ]] || { cp "$local_rules" "$root/AI/LOCAL.md"; rm -f "$local_rules"; }
for path in "AI/写入日志.md" "AI/写入日志"; do
  if [[ -e "$backup/$path" ]]; then rm -rf "$root/$path"; mkdir -p "$root/$(dirname "$path")"; cp -R "$backup/$path" "$root/$path"; fi
done
mkdir -p "$root/Archive/Knowledge" "$root/Archive/Projects"
[[ ! -e "$root/skills" ]] || rm -rf "$root/skills"
echo "框架已更新：$target_version -> $source_version"
echo "备份：$backup"
echo "个人数据、归档、个人规则和写入日志未被覆盖。提交和推送尚未执行。"
