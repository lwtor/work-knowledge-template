#!/usr/bin/env bash
set -euo pipefail
usage() {
  cat <<'EOF'
用法：
  ./scripts/update-framework.sh [模板目录或 GitHub URL] [--target 个人仓库目录] [--resume-framework-update] --yes
只在用户明确要求更新框架并确认范围后执行。不会提交或推送。
EOF
}
source_ref=""; target_ref=""; confirmed="no"; resume="no"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes) confirmed="yes"; shift ;;
    --resume-framework-update) resume="yes"; shift ;;
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
temp_dir=""
cleanup() { [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir"; }
trap cleanup EXIT
if [[ -d "$source_ref" ]]; then source_dir="$(cd "$source_ref" && pwd)"; else
  temp_dir="$(mktemp -d /tmp/kb-template-update.XXXXXX)"
  git clone --depth 1 "$source_ref" "$temp_dir/source" >/dev/null
  source_dir="$temp_dir/source"
fi
[[ -f "$source_dir/.kb-role" && "$(tr -d '[:space:]' < "$source_dir/.kb-role")" == "template" ]] || { echo "错误：来源不是模板仓库。" >&2; exit 1; }
if [[ -n "$(git -C "$root" status --porcelain)" ]]; then
  [[ "$resume" == "yes" ]] || { echo "错误：个人仓库存在未提交修改；仅在恢复已中断的框架更新时使用 --resume-framework-update。" >&2; exit 1; }
  [[ -z "$(git -C "$root" diff --cached --name-only)" ]] || { echo "错误：续跑已停止，存在暂存区修改。" >&2; exit 1; }
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    case "$path" in
      README.md|AGENTS.md|Home.md|.gitignore|.gitattributes|.kb-version|Templates/*|scripts/*|integrations/*|AI/*) ;;
      *) echo "错误：续跑已停止，发现框架白名单之外的修改：$path" >&2; exit 1 ;;
    esac
    case "$path" in
      AI/LOCAL.md|AI/写入日志.md|AI/写入日志/*) [[ "$path" == "AI/写入日志/README.md" ]] || { echo "错误：续跑已停止，发现受保护数据修改：$path" >&2; exit 1; } ;;
    esac
  done < <({ git -c core.quotepath=false -C "$root" diff --name-only; git -c core.quotepath=false -C "$root" ls-files --others --exclude-standard; } | sort -u)
  echo "续跑检查通过：未发现暂存修改或个人数据差异。"
fi
source_version="$(tr -d '[:space:]' < "$source_dir/.kb-version")"
target_version="$(tr -d '[:space:]' < "$root/.kb-version")"
if [[ "$source_version" == "$target_version" && "$resume" != "yes" ]]; then echo "当前已是模板版本 $target_version，无需更新。"; exit 0; fi
[[ "$source_version" != "$target_version" ]] || echo "框架版本均为 $target_version；正在续跑此前中断的同版本更新。"
framework=("README.md" "AGENTS.md" "Home.md" "AI" "Templates" "scripts" "integrations" ".gitignore" ".gitattributes" ".kb-version")
additive=("Archive/README.md" "Knowledge/README.md" "Knowledge/INDEX.md" "Projects/README.md" "Projects/INDEX.md" "Projects/TASKS.md" "Inbox/README.md" "Daily/README.md")
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
for path in "${additive[@]}"; do
  if [[ ! -e "$root/$path" ]]; then
    [[ -f "$source_dir/$path" ]] || { echo "错误：模板缺少增量框架文件：$path" >&2; exit 1; }
    mkdir -p "$root/$(dirname "$path")"
    cp "$source_dir/$path" "$root/$path"
  fi
done
[[ ! -e "$root/skills" ]] || rm -rf "$root/skills"
echo "框架已更新：$target_version -> $source_version"
echo "备份：$backup"
echo "个人数据、归档、个人规则和写入日志未被覆盖。提交和推送尚未执行。"
