#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path


MAPPING = {
    "Knowledge": "Vault/01-知识",
    "Projects": "Vault/02-项目",
    "Cases": "Vault/03-案例",
    "Inbox": "Vault/04-收集箱",
    "Daily": "Vault/05-工作记录",
    "Archive": "Vault/90-归档",
    "Attachments": "Vault/附件",
}
GENERATED = {"README.md", "INDEX.md", "TASKS.md", ".gitkeep"}
SKELETON = {
    "Vault/首页.md": "# 我的工作知识库\n\n- [[01-知识/INDEX|知识中心]]\n- [[02-项目/INDEX|项目中心]]\n- [[02-项目/需求中心|需求中心]]\n- [[03-案例/INDEX|案例中心]]\n- [[04-收集箱/README|收集箱]]\n- [[05-工作记录/README|工作记录]]\n- [[90-归档/README|归档]]\n",
    "Vault/01-知识/README.md": "# 知识\n\n保存跨项目可复用的知识。\n",
    "Vault/01-知识/INDEX.md": "# 知识中心\n",
    "Vault/02-项目/README.md": "# 项目\n\n每个项目通过项目主页进入，并区分项目知识、需求和项目问题。\n",
    "Vault/02-项目/INDEX.md": "# 项目中心\n",
    "Vault/02-项目/需求中心.md": "# 需求中心\n",
    "Vault/02-项目/TASKS.md": "# 跨项目待办\n",
    "Vault/03-案例/README.md": "# 案例\n\n保存值得复盘或分享的问题解决与 AI 协作过程。\n",
    "Vault/03-案例/INDEX.md": "# 案例中心\n",
    "Vault/04-收集箱/README.md": "# 收集箱\n",
    "Vault/05-工作记录/README.md": "# 工作记录\n",
    "Vault/90-归档/README.md": "# 归档\n",
}
OBSIDIAN_CSS = """/* Keep the everyday vault focused on knowledge, projects, cases and capture. */
.nav-folder:has(> .nav-folder-title[data-path="附件"]),
.nav-folder:has(> .nav-folder-title[data-path="模板"]),
.nav-file:has(> .nav-file-title[data-path$="/README.md"]),
.nav-file:has(> .nav-file-title[data-path$="/INDEX.md"]),
.nav-file:has(> .nav-file-title[data-path$="/TASKS.md"]) {
  display: none;
}

.workspace-leaf-content[data-type="markdown"] .view-content {
  --file-line-width: 860px;
}
"""


def fail(message: str) -> None:
    raise SystemExit(f"错误：{message}")


def files_under(path: Path) -> list[Path]:
    return sorted(item for item in path.rglob("*") if item.is_file()) if path.is_dir() else []


def current_layout(root: Path) -> int:
    marker = root / ".kb-layout-version"
    if not marker.is_file():
        return 1
    try:
        return int(marker.read_text(encoding="utf-8-sig").strip())
    except ValueError:
        fail(".kb-layout-version 不是有效数字。")


def plan(root: Path) -> list[tuple[Path, Path]]:
    moves: list[tuple[Path, Path]] = []
    for source_name, target_name in MAPPING.items():
        source_root = root / source_name
        target_root = root.joinpath(*target_name.split("/"))
        for source in files_under(source_root):
            if source.name in GENERATED:
                continue
            target = target_root / source.relative_to(source_root)
            if target.exists():
                fail(f"目标路径已经存在，未执行迁移：{target.relative_to(root).as_posix()}")
            moves.append((source, target))
    return moves


def git_clean(root: Path) -> bool:
    result = subprocess.run(["git", "-C", str(root), "status", "--porcelain"], capture_output=True, text=True, check=False)
    return result.returncode == 0 and not result.stdout.strip()


def report(root: Path, moves: list[tuple[Path, Path]]) -> None:
    counts = {name: 0 for name in MAPPING}
    for source, _ in moves:
        counts[source.relative_to(root).parts[0]] += 1
    print("目录迁移预览：布局 1 -> 布局 2")
    for name, target in MAPPING.items():
        print(f"- {name}/ -> {target}/：{counts[name]} 个个人文件")
    print(f"- 总计移动：{len(moves)} 个文件")
    print("- 不自动重新分类，不提交，不推送")
    print("当前旧目录仍可正常使用。")
    print("\n---\n\n## ⚠️ 需要你确认\n")
    print("### 1. 执行目录迁移\n")
    print("将移动预览中列出的文件，但不会创建 Git 提交或推送。\n")
    print("回复数字：`1`\n")
    print("或复制回复：`确认执行目录迁移，不提交、不推送。`")


def install_skeleton(root: Path) -> None:
    for relative, content in SKELETON.items():
        target = root.joinpath(*relative.split("/"))
        target.parent.mkdir(parents=True, exist_ok=True)
        if not target.exists():
            target.write_text(content, encoding="utf-8", newline="\n")
    source_templates = root / "Templates"
    target_templates = root / "Vault" / "模板"
    if source_templates.is_dir():
        target_templates.mkdir(parents=True, exist_ok=True)
        for source in source_templates.glob("*.md"):
            target = target_templates / source.name
            if not target.exists():
                shutil.copy2(source, target)
    target_attachments = root / "Vault" / "附件"
    target_attachments.mkdir(parents=True, exist_ok=True)
    old_obsidian = root / ".obsidian"
    new_obsidian = root / "Vault" / ".obsidian"
    if old_obsidian.is_dir() and not new_obsidian.exists():
        shutil.copytree(old_obsidian, new_obsidian)
    new_obsidian.mkdir(parents=True, exist_ok=True)
    app_path = new_obsidian / "app.json"
    app = {}
    if app_path.is_file():
        try:
            app = json.loads(app_path.read_text(encoding="utf-8-sig"))
        except json.JSONDecodeError:
            fail(f"Obsidian 配置不是有效 JSON，未覆盖：{app_path}")
    app.update({"alwaysUpdateLinks": True, "newLinkFormat": "relative", "attachmentFolderPath": "附件"})
    app_path.write_text(json.dumps(app, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    snippets = new_obsidian / "snippets"
    snippets.mkdir(parents=True, exist_ok=True)
    (snippets / "work-knowledge-vault.css").write_text(OBSIDIAN_CSS, encoding="utf-8", newline="\n")
    appearance_path = new_obsidian / "appearance.json"
    appearance = {}
    if appearance_path.is_file():
        try:
            appearance = json.loads(appearance_path.read_text(encoding="utf-8-sig"))
        except json.JSONDecodeError:
            fail(f"Obsidian 外观配置不是有效 JSON，未覆盖：{appearance_path}")
    enabled = appearance.get("enabledCssSnippets", [])
    if not isinstance(enabled, list):
        fail(f"Obsidian enabledCssSnippets 不是列表，未覆盖：{appearance_path}")
    if "work-knowledge-vault" not in enabled:
        enabled.append("work-knowledge-vault")
    appearance["enabledCssSnippets"] = enabled
    appearance_path.write_text(json.dumps(appearance, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")


def rewrite_explicit_links(root: Path) -> int:
    changed = 0
    replacements = {f"{source}/": f"{target.removeprefix('Vault/')}/" for source, target in MAPPING.items()}
    for path in (root / "Vault").rglob("*.md"):
        text = path.read_text(encoding="utf-8-sig")
        updated = text
        for source, target in replacements.items():
            updated = updated.replace(source, target)
        if updated != text:
            path.write_text(updated, encoding="utf-8", newline="\n")
            changed += 1
    return changed


def migrate(root: Path, moves: list[tuple[Path, Path]]) -> None:
    if not git_clean(root):
        fail("框架尚未开始迁移：Git 工作区存在修改。请先让 Agent 展示并处理现有修改，再重新生成迁移预览。")
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup = root / ".kb-backups" / f"layout-v1-to-v2-{stamp}"
    state_dir = root / ".kb-migration"
    state = state_dir / "state.json"
    if state.exists():
        fail(f"发现未完成迁移：{state}")
    backup.mkdir(parents=True)
    for source_name in MAPPING:
        source = root / source_name
        if source.exists():
            shutil.copytree(source, backup / source_name)
    state_dir.mkdir(parents=True)
    state.write_text(json.dumps({"from": 1, "to": 2, "backup": str(backup), "planned": len(moves)}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    try:
        for source, target in moves:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(source), str(target))
        install_skeleton(root)
        rewritten = rewrite_explicit_links(root)
        (root / ".kb-layout-version").write_text("2\n", encoding="utf-8", newline="\n")
        state.unlink()
        state_dir.rmdir()
    except Exception:
        fail(f"迁移中断。不要继续普通写入；备份位于 {backup}，状态位于 {state}。")
    print(f"目录迁移完成：布局 2；移动 {len(moves)} 个文件；修复 {rewritten} 个含旧路径的 Markdown 文件；备份：{backup}")
    print(f"以后请用 Obsidian 打开：{root / 'Vault'}")
    print("目录迁移已完成，但 Git 尚未记录这些变化。")
    print("\n---\n\n## ➡️ 可选的下一步\n")
    print("### 1. 创建目录迁移的本地提交\n")
    print("先展示迁移差异，再创建本地提交；不会推送。\n")
    print("回复数字：`1`\n")
    print("或复制回复：`确认展示目录迁移差异并创建本地提交，不推送。`\n")
    print("### 0. 暂不处理以上操作\n")
    print("回复数字：`0`")


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser(description="预览或执行个人知识库布局 1 到布局 2 的迁移。")
    parser.add_argument("--root", required=True)
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--confirm", action="store_true")
    args = parser.parse_args()
    root = Path(args.root).expanduser().resolve()
    if not (root / ".git").is_dir() or not (root / ".kb-role").is_file():
        fail("目标不是个人知识库 Git 仓库。")
    if (root / ".kb-role").read_text(encoding="utf-8-sig").strip() != "personal":
        fail("目标仓库角色不是 personal。")
    layout = current_layout(root)
    if layout == 2:
        print("当前已经是目录结构 2，无需迁移。")
        return 0
    if layout != 1:
        fail(f"不支持从目录结构 {layout} 迁移。")
    moves = plan(root)
    report(root, moves)
    if args.apply:
        if not args.confirm:
            fail("尚未确认。请先展示预览并获得用户明确确认。")
        migrate(root, moves)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
