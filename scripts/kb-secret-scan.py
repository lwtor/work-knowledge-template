#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
from pathlib import Path

from kb_common import relative, vault_root
from kb_layout import detect_layout, layout_path

RULES = {
    "private-key": re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
    "github-token": re.compile(r"\b(?:ghp|github_pat)_[A-Za-z0-9_]{20,}\b"),
    "aws-access-key": re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
    "generic-secret": re.compile(r"(?i)\b(?:api[_-]?key|access[_-]?token|client[_-]?secret|password)\b\s*[:=]\s*['\"]?[A-Za-z0-9_./+\-=]{12,}"),
}
TEXT_SUFFIXES = {".md", ".txt", ".json", ".yaml", ".yml", ".xml", ".csv", ".ini", ".conf", ".properties", ".env"}


def text_files(root: Path):
    layout = detect_layout(root)
    for name in (*layout.content_roots, layout.archive, layout.attachments):
        base = layout_path(root, name)
        if not base.is_dir():
            continue
        for path in base.rglob("*"):
            if path.is_file() and (path.suffix.lower() in TEXT_SUFFIXES or path.name.startswith(".env")) and path.stat().st_size <= 5 * 1024 * 1024:
                yield path


def main() -> int:
    parser = argparse.ArgumentParser(description="扫描疑似秘密；只报告文件、行号和规则名。")
    parser.add_argument("--vault")
    args = parser.parse_args()
    root = vault_root(args.vault)
    findings = []
    for path in text_files(root):
        try:
            lines = path.read_text(encoding="utf-8-sig").splitlines()
        except UnicodeDecodeError:
            continue
        for number, line in enumerate(lines, 1):
            for name, pattern in RULES.items():
                if pattern.search(line):
                    findings.append((relative(root, path), number, name))
    for path, number, name in findings:
        print(f"ERROR secret {path}:{number} rule={name}")
    if findings:
        print(f"发现 {len(findings)} 个疑似秘密；未显示内容，也未修改文件。")
        return 2
    print("未发现匹配已知规则的疑似秘密。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
