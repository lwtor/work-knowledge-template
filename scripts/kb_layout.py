#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Layout:
    version: int
    home: str
    knowledge: str
    projects: str
    cases: str | None
    inbox: str
    daily: str
    archive: str
    attachments: str
    templates: str

    @property
    def content_roots(self) -> tuple[str, ...]:
        return tuple(value for value in (self.knowledge, self.projects, self.cases, self.inbox, self.daily) if value)

    @property
    def note_roots(self) -> tuple[str, ...]:
        return tuple(value for value in (self.knowledge, self.projects, self.cases) if value)


LAYOUTS = {
    1: Layout(1, "Home.md", "Knowledge", "Projects", "Cases", "Inbox", "Daily", "Archive", "Attachments", "Templates"),
    2: Layout(2, "Vault/首页.md", "Vault/01-知识", "Vault/02-项目", "Vault/03-案例", "Vault/04-收集箱", "Vault/05-工作记录", "Vault/90-归档", "Vault/附件", "Vault/模板"),
}


def detect_layout(root: Path) -> Layout:
    marker = root / ".kb-layout-version"
    if not marker.is_file():
        return LAYOUTS[1]
    raw = marker.read_text(encoding="utf-8-sig").strip()
    try:
        version = int(raw)
    except ValueError as exc:
        raise ValueError(f"目录结构版本无效：{raw!r}") from exc
    if version not in LAYOUTS:
        raise ValueError(f"不支持的目录结构版本：{version}")
    migration = root / ".kb-migration" / "state.json"
    if migration.is_file():
        raise RuntimeError(f"目录迁移尚未完成：{migration}")
    return LAYOUTS[version]


def layout_path(root: Path, value: str) -> Path:
    return root.joinpath(*value.split("/"))
