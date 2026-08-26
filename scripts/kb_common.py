#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path

CONTENT_ROOTS = ("Knowledge", "Projects", "Inbox", "Daily")
NOTE_ROOTS = ("Knowledge", "Projects")
VALID_STATUS = {"active", "draft", "deprecated", "archived"}
VALID_CONFIDENCE = {"unverified", "confirmed"}
VALID_CONFIDENTIALITY = {"public", "internal", "restricted"}


def vault_root(value: str | None = None) -> Path:
    return Path(value).expanduser().resolve() if value else Path(__file__).resolve().parent.parent


def markdown_files(root: Path, roots=CONTENT_ROOTS):
    for name in roots:
        base = root / name
        if base.is_dir():
            yield from sorted(p for p in base.rglob("*.md") if p.name not in {"README.md", "INDEX.md", "TASKS.md"})


def frontmatter(path: Path) -> tuple[dict[str, object], str]:
    text = path.read_text(encoding="utf-8-sig")
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, text
    result: dict[str, object] = {}
    current_list = ""
    for line in lines[1:]:
        if line.strip() == "---":
            return result, text
        item = re.match(r"^\s+-\s+(.+?)\s*$", line)
        if item and current_list:
            result.setdefault(current_list, []).append(item.group(1).strip(" '\""))
            continue
        match = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*):\s*(.*?)\s*$", line)
        if not match:
            current_list = ""
            continue
        key, raw = match.groups()
        current_list = key if raw == "" else ""
        if raw == "[]":
            result[key] = []
        elif raw.startswith("[") and raw.endswith("]"):
            result[key] = [part.strip(" '\"") for part in raw[1:-1].split(",") if part.strip()]
        else:
            result[key] = raw.strip(" '\"")
    return {}, text


def relative(root: Path, path: Path) -> str:
    return path.relative_to(root).as_posix()
