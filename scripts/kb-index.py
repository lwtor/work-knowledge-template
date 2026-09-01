#!/usr/bin/env python3
from __future__ import annotations

import argparse
from collections import defaultdict
from datetime import date
from pathlib import Path

from kb_common import frontmatter, markdown_files, relative, vault_root
from kb_layout import detect_layout, layout_path


def link(from_dir: Path, target: Path, root: Path) -> str:
    return Path(__import__("os").path.relpath(target, from_dir)).as_posix()


def render_index(root: Path, area: str, notes: list[tuple[Path, dict]], index_dir: Path) -> str:
    groups: dict[str, list[tuple[Path, dict]]] = defaultdict(list)
    for path, meta in notes:
        groups[str(meta.get("type") or "unknown")].append((path, meta))
    lines = [f"# {area} 索引", "", "此文件由 `scripts/kb-index.py` 生成，可随时重建；笔记正文才是事实来源。", ""]
    for kind in sorted(groups):
        lines += [f"## {kind}", ""]
        for path, meta in sorted(groups[kind], key=lambda item: str(item[1].get("title") or item[0].stem).lower()):
            title = str(meta.get("title") or path.stem)
            status = str(meta.get("status") or "unknown")
            confidence = str(meta.get("confidence") or "unknown")
            lines.append(f"- [{title}]({link(index_dir, path, root)}) — {status} / {confidence}")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="重建知识、项目、待复核和跨项目待办索引。")
    parser.add_argument("--vault")
    args = parser.parse_args()
    root = vault_root(args.vault)
    layout = detect_layout(root)
    today = date.today().isoformat()
    by_area: dict[str, list[tuple[Path, dict]]] = {layout.knowledge: [], layout.projects: []}
    if layout.cases:
        by_area[layout.cases] = []
    review: list[tuple[Path, dict]] = []
    tasks: list[tuple[Path, str]] = []
    requirements: list[tuple[Path, dict]] = []
    for path in markdown_files(root, layout.note_roots):
        meta, text = frontmatter(path)
        area = next(name for name in layout.note_roots if path.is_relative_to(layout_path(root, name)))
        by_area[area].append((path, meta))
        if area == layout.projects and str(meta.get("type") or "") == "requirement" and str(meta.get("status") or "") not in {"archived", "deprecated"}:
            requirements.append((path, meta))
        due = str(meta.get("review_after") or "")
        if due and due <= today:
            review.append((path, meta))
        if area == layout.projects:
            for line in text.splitlines():
                if line.lstrip().startswith("- [ ] "):
                    tasks.append((path, line.strip()[6:].strip()))
    for area, notes in by_area.items():
        directory = layout_path(root, area)
        directory.mkdir(parents=True, exist_ok=True)
        (directory / "INDEX.md").write_text(render_index(root, area, notes, directory), encoding="utf-8", newline="\n")
    review_lines = ["# 待复核清单", "", "此文件由 `scripts/kb-index.py` 生成。到期只表示需要复核，不会自动改变状态。", ""]
    for path, meta in sorted(review, key=lambda item: str(item[1].get("review_after"))):
        review_lines.append(f"- {meta.get('review_after')} [{meta.get('title') or path.stem}](../{relative(root, path)})")
    if not review:
        review_lines.append("- 当前没有到期内容。")
    (root / "AI" / "待复核清单.md").write_text("\n".join(review_lines) + "\n", encoding="utf-8", newline="\n")
    task_lines = ["# 跨项目待办", "", "此文件由 `scripts/kb-index.py` 生成，只汇总未完成的 Markdown checkbox。", ""]
    for path, task in tasks:
        task_lines.append(f"- [ ] {task} — [{relative(root, path)}]({link(root / 'Projects', path, root)})")
    if not tasks:
        task_lines.append("- 当前没有未完成的项目待办。")
    project_dir = layout_path(root, layout.projects)
    (project_dir / "TASKS.md").write_text("\n".join(task_lines) + "\n", encoding="utf-8", newline="\n")
    if layout.version == 2:
        requirement_lines = ["# 需求中心", "", "此文件由 `scripts/kb-index.py` 生成，汇总所有项目中尚未归档的需求。", ""]
        for path, meta in sorted(requirements, key=lambda item: str(item[1].get("delivery_date") or "9999-12-31")):
            title = str(meta.get("title") or path.stem)
            project = str(meta.get("project") or "未关联项目")
            delivery = str(meta.get("delivery_date") or "未设置交付时间")
            requirement_lines.append(f"- [{title}]({link(project_dir, path, root)}) — {project} / {delivery}")
        if not requirements:
            requirement_lines.append("- 当前没有进行中的需求。")
        (project_dir / "需求中心.md").write_text("\n".join(requirement_lines) + "\n", encoding="utf-8", newline="\n")
    print(f"索引已重建：Knowledge={len(by_area[layout.knowledge])}, Projects={len(by_area[layout.projects])}, 待复核={len(review)}, 待办={len(tasks)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
