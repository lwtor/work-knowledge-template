#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
from pathlib import Path


def skill_hash(skill_dir: Path) -> str:
    digest = hashlib.sha256()
    files = sorted(path for path in skill_dir.rglob("*") if path.is_file() and path.name != ".managed-by-work-knowledge-template")
    for path in files:
        relative = path.relative_to(skill_dir).as_posix().encode("utf-8")
        digest.update(relative + b"\0" + path.read_bytes() + b"\0")
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description="输出 work-knowledge Skill 的版本与规则哈希。")
    parser.add_argument("--root", required=True, type=Path, help="知识库根目录")
    parser.add_argument("--agent", required=True, choices=("codex", "bluecode", "vbuddy"))
    args = parser.parse_args()
    root = args.root.resolve()
    skill_dir = root / "integrations" / args.agent / "work-knowledge"
    version_file = skill_dir / ".skill-version"
    framework_file = root / ".kb-version"
    if not version_file.is_file() or not framework_file.is_file():
        parser.error("缺少 .skill-version 或 .kb-version")
    print(f"framework_version={framework_file.read_text(encoding='utf-8-sig').strip()}")
    print(f"skill_version={version_file.read_text(encoding='utf-8-sig').strip()}")
    print(f"skill_rules_sha256={skill_hash(skill_dir)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
