#!/usr/bin/env bash
set -euo pipefail
root="${1:?用法：migrate-layout.sh 知识库根目录 [--apply --confirm]}"
shift
python3 "$(cd "$(dirname "$0")" && pwd)/kb-migrate-layout.py" --root "$root" "$@"
