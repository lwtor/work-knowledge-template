#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

from kb_layout import detect_layout, layout_path


AREA_ATTRS = {
    "knowledge": "knowledge",
    "project": "projects",
    "case": "cases",
    "inbox": "inbox",
    "daily": "daily",
}


def resolved(path: Path) -> Path:
    return Path(os.path.realpath(os.path.abspath(path)))


def validate_target(root: Path, target: Path, area: str) -> tuple[Path, Path]:
    root = resolved(root)
    if not (root / ".git").is_dir():
        raise ValueError("知识库根目录不是 Git 仓库")
    role = root / ".kb-role"
    if not role.is_file() or role.read_text(encoding="utf-8-sig").strip() != "personal":
        raise ValueError("知识库根目录不是 personal 仓库")

    layout = detect_layout(root)
    area_root_value = getattr(layout, AREA_ATTRS[area])
    if not area_root_value:
        raise ValueError(f"当前布局不支持区域：{area}")
    area_root = resolved(layout_path(root, area_root_value))
    candidate = resolved(target if target.is_absolute() else root / target)

    try:
        candidate.relative_to(root)
    except ValueError as exc:
        raise ValueError("目标路径越出知识库根目录") from exc
    try:
        candidate.relative_to(area_root)
    except ValueError as exc:
        raise ValueError(f"目标路径不属于知识库的 {area} 区域") from exc
    return root, candidate


def main() -> int:
    parser = argparse.ArgumentParser(description="只读验证知识库拟写入目标是否位于合法内容区域。")
    parser.add_argument("--vault", required=True, type=Path, help="私人知识库根目录")
    parser.add_argument("--target", required=True, type=Path, help="拟写入目标；可为绝对或相对路径")
    parser.add_argument("--area", required=True, choices=sorted(AREA_ATTRS))
    args = parser.parse_args()
    try:
        root, candidate = validate_target(args.vault, args.target, args.area)
    except (OSError, RuntimeError, ValueError) as exc:
        print(f"拒绝：{exc}", file=sys.stderr)
        return 2
    print(f"通过：{candidate.relative_to(root).as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
