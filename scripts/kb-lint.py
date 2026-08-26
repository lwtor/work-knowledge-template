#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
from collections import defaultdict
from datetime import date, datetime, timedelta
from pathlib import Path

from kb_common import VALID_CONFIDENCE, VALID_CONFIDENTIALITY, VALID_STATUS, frontmatter, markdown_files, relative, vault_root

REQUIRED = {"id", "type", "status", "title", "created", "updated", "confidence", "confidentiality", "tags", "aliases"}


def main() -> int:
    parser = argparse.ArgumentParser(description="只读检查知识库健康度。")
    parser.add_argument("--vault")
    parser.add_argument("--inbox-days", type=int, default=30)
    parser.add_argument("--attachment-mb", type=int, default=10)
    args = parser.parse_args()
    root = vault_root(args.vault)
    issues: list[tuple[str, str]] = []
    titles: dict[str, list[str]] = defaultdict(list)
    ids: dict[str, list[str]] = defaultdict(list)
    referenced: set[Path] = set()
    today = date.today()
    all_md = list(root.rglob("*.md"))
    for path in markdown_files(root, ("Knowledge", "Projects")):
        meta, text = frontmatter(path)
        rel = relative(root, path)
        missing = sorted(REQUIRED - set(meta))
        if missing:
            issues.append(("WARNING", f"metadata {rel}: 缺少 {', '.join(missing)}"))
        for field, allowed in (("status", VALID_STATUS), ("confidence", VALID_CONFIDENCE), ("confidentiality", VALID_CONFIDENTIALITY)):
            if meta.get(field) and meta[field] not in allowed:
                issues.append(("ERROR", f"metadata {rel}: {field}={meta[field]} 非法"))
        if meta.get("id"):
            ids[str(meta["id"]).lower()].append(rel)
        if meta.get("title"):
            titles[str(meta["title"]).strip().lower()].append(rel)
        due = str(meta.get("review_after") or "")
        if due:
            try:
                if date.fromisoformat(due) <= today:
                    issues.append(("INFO", f"review {rel}: 已到复核日期 {due}"))
            except ValueError:
                issues.append(("ERROR", f"metadata {rel}: review_after 不是 YYYY-MM-DD"))
    for kind, values in (("id", ids), ("title", titles)):
        for key, paths in values.items():
            if len(paths) > 1:
                issues.append(("WARNING", f"duplicate {kind}={key}: {', '.join(paths)}"))
    cutoff = datetime.now().timestamp() - timedelta(days=args.inbox_days).total_seconds()
    inbox = root / "Inbox"
    if inbox.is_dir():
        for path in inbox.rglob("*.md"):
            if path.name != "README.md" and path.stat().st_mtime < cutoff:
                issues.append(("INFO", f"inbox {relative(root, path)}: 超过 {args.inbox_days} 天"))
    link_pattern = re.compile(r"!?\[\[[^\]|#]+|!?\[[^\]]*\]\(([^)#]+)")
    for path in all_md:
        text = path.read_text(encoding="utf-8-sig")
        for raw in re.findall(r"!?\[\[([^\]|#]+)", text):
            name = raw.strip()
            matches = list(root.rglob(name if Path(name).suffix else name + ".md"))
            if not matches:
                issues.append(("WARNING", f"link {relative(root, path)}: 找不到 [[{name}]]"))
            referenced.update(p.resolve() for p in matches)
        for raw in re.findall(r"!?\[[^\]]*\]\(([^)#]+)", text):
            if "://" in raw or raw.startswith("mailto:"):
                continue
            target = (path.parent / raw.replace("%20", " ")).resolve()
            referenced.add(target)
            if not target.exists():
                issues.append(("WARNING", f"link {relative(root, path)}: 找不到 {raw}"))
    attachments = root / "Attachments"
    if attachments.is_dir():
        limit = args.attachment_mb * 1024 * 1024
        for path in (p for p in attachments.rglob("*") if p.is_file()):
            if path.resolve() not in referenced:
                issues.append(("WARNING", f"attachment {relative(root, path)}: 未被引用"))
            if path.stat().st_size > limit:
                issues.append(("WARNING", f"attachment {relative(root, path)}: 超过 {args.attachment_mb} MB"))
    order = {"ERROR": 0, "WARNING": 1, "INFO": 2}
    for level, message in sorted(issues, key=lambda item: (order[item[0]], item[1])):
        print(f"{level} {message}")
    counts = {level: sum(1 for actual, _ in issues if actual == level) for level in order}
    print(f"检查完成：ERROR={counts['ERROR']} WARNING={counts['WARNING']} INFO={counts['INFO']}；未修改文件。")
    return 2 if counts["ERROR"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
