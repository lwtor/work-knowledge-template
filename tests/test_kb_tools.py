from __future__ import annotations

import importlib.util
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load(name: str, path: Path):
    script_dir = str(path.parent)
    if script_dir not in sys.path:
        sys.path.insert(0, script_dir)
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    spec.loader.exec_module(module)
    return module


class KnowledgeToolsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        for name in ("Knowledge", "Projects", "Cases", "Inbox", "Daily", "Attachments", "Archive", "AI/写入日志"):
            (self.root / name).mkdir(parents=True)

    def tearDown(self):
        self.temp.cleanup()

    def run_tool(self, name: str):
        return subprocess.run(
            [sys.executable, str(ROOT / "scripts" / name), "--vault", str(self.root)],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_index_and_clean_lint(self):
        note = """---
id: kb-1
type: knowledge
status: active
title: Example
tags: []
aliases: []
created: 2026-08-26
updated: 2026-08-26
last_verified: 2026-08-26
review_after:
confidence: confirmed
confidentiality: internal
---
# Example
"""
        (self.root / "Knowledge" / "example.md").write_text(note, encoding="utf-8")
        indexed = self.run_tool("kb-index.py")
        self.assertEqual(indexed.returncode, 0, indexed.stderr)
        self.assertIn("Example", (self.root / "Knowledge" / "INDEX.md").read_text(encoding="utf-8"))
        linted = self.run_tool("kb-lint.py")
        self.assertEqual(linted.returncode, 0, linted.stdout + linted.stderr)
        self.assertIn("ERROR=0 WARNING=0", linted.stdout)

    def test_secret_scan_redacts_value(self):
        secret = "ghp_abcdefghijklmnopqrstuvwxyz123456"
        (self.root / "Inbox" / "secret.md").write_text(f"token: {secret}\n", encoding="utf-8")
        scanned = self.run_tool("kb-secret-scan.py")
        self.assertEqual(scanned.returncode, 2)
        self.assertNotIn(secret, scanned.stdout + scanned.stderr)
        self.assertIn("github-token", scanned.stdout)

    def test_transfer_excludes_generated_views(self):
        transfer = load("kb_transfer", ROOT / "scripts" / "kb-transfer.py")
        (self.root / "Knowledge" / "INDEX.md").write_text("generated", encoding="utf-8")
        (self.root / "Knowledge" / "real.md").write_text("real", encoding="utf-8")
        (self.root / "Cases" / "case.md").write_text("case", encoding="utf-8")
        files = transfer.data_files(self.root)
        self.assertNotIn("Knowledge/INDEX.md", files)
        self.assertIn("Knowledge/real.md", files)
        self.assertIn("Cases/case.md", files)

    def test_transfer_detects_divergence_but_allows_target_state(self):
        transfer = load("kb_transfer_conflict", ROOT / "scripts" / "kb-transfer.py")
        empty = {}
        (self.root / "Knowledge" / "local.md").write_text("local", encoding="utf-8")
        current = transfer.data_files(self.root)
        divergent = {
            "format_version": transfer.FORMAT_VERSION,
            "base_manifest_sha256": transfer.manifest_hash(empty),
            "target_manifest_sha256": transfer.manifest_hash({"Knowledge/incoming.md": {"sha256": "x", "size": 1}}),
        }
        with self.assertRaises(ValueError):
            transfer.check_package_conflict(self.root, divergent)
        already_applied = dict(divergent, target_manifest_sha256=transfer.manifest_hash(current))
        transfer.check_package_conflict(self.root, already_applied)

    def test_layout_two_index_and_lint(self):
        (self.root / ".kb-layout-version").write_text("2\n", encoding="utf-8")
        for name in ("01-知识", "02-项目", "03-案例", "04-收集箱", "05-工作记录", "90-归档", "附件"):
            (self.root / "Vault" / name).mkdir(parents=True, exist_ok=True)
        note = """---
id: kb-v2
type: knowledge
status: active
title: Layout Two
created: 2026-08-31
updated: 2026-08-31
confidence: confirmed
confidentiality: internal
tags: []
aliases: []
---
# Layout Two
"""
        (self.root / "Vault" / "01-知识" / "layout-two.md").write_text(note, encoding="utf-8")
        requirement = note.replace("kb-v2", "req-v2").replace("type: knowledge", "type: requirement").replace("Layout Two", "Requirement Two")
        project = self.root / "Vault" / "02-项目" / "Demo" / "需求"
        project.mkdir(parents=True)
        (project / "requirement.md").write_text(requirement, encoding="utf-8")
        indexed = self.run_tool("kb-index.py")
        self.assertEqual(indexed.returncode, 0, indexed.stdout + indexed.stderr)
        self.assertIn("Layout Two", (self.root / "Vault" / "01-知识" / "INDEX.md").read_text(encoding="utf-8"))
        self.assertIn("Requirement Two", (self.root / "Vault" / "02-项目" / "需求中心.md").read_text(encoding="utf-8"))
        linted = self.run_tool("kb-lint.py")
        self.assertEqual(linted.returncode, 0, linted.stdout + linted.stderr)

    def test_layout_migration_requires_apply_and_confirmation(self):
        (self.root / ".kb-role").write_text("personal\n", encoding="utf-8")
        (self.root / "Knowledge" / "old.md").write_text("# Old\n\n[[Projects/Demo]]\n", encoding="utf-8")
        (self.root / "Cases" / "ai-case.md").write_text("# AI Case\n", encoding="utf-8")
        (self.root / ".obsidian").mkdir()
        (self.root / ".obsidian" / "appearance.json").write_text('{"enabledCssSnippets":["personal"]}\n', encoding="utf-8")
        subprocess.run(["git", "init", str(self.root)], check=True, capture_output=True)
        subprocess.run(["git", "-C", str(self.root), "config", "user.email", "test@example.invalid"], check=True)
        subprocess.run(["git", "-C", str(self.root), "config", "user.name", "Test"], check=True)
        subprocess.run(["git", "-C", str(self.root), "add", "."], check=True)
        subprocess.run(["git", "-C", str(self.root), "commit", "-m", "fixture"], check=True, capture_output=True)
        command = [sys.executable, str(ROOT / "scripts" / "kb-migrate-layout.py"), "--root", str(self.root)]
        preview = subprocess.run(command, text=True, encoding="utf-8", capture_output=True, check=False)
        self.assertEqual(preview.returncode, 0, preview.stdout + preview.stderr)
        self.assertIn("### 1. 执行目录迁移", preview.stdout)
        self.assertIn("回复数字：`1`", preview.stdout)
        self.assertIn("或复制回复：`确认执行目录迁移，不提交、不推送。`", preview.stdout)
        self.assertTrue((self.root / "Knowledge" / "old.md").is_file())
        migrated = subprocess.run(command + ["--apply", "--confirm"], text=True, encoding="utf-8", capture_output=True, check=False)
        self.assertEqual(migrated.returncode, 0, migrated.stdout + migrated.stderr)
        self.assertIn("### 1. 创建目录迁移的本地提交", migrated.stdout)
        self.assertIn("### 0. 暂不处理以上操作", migrated.stdout)
        self.assertTrue((self.root / "Vault" / "01-知识" / "old.md").is_file())
        self.assertTrue((self.root / "Vault" / "03-案例" / "ai-case.md").is_file())
        migrated_text = (self.root / "Vault" / "01-知识" / "old.md").read_text(encoding="utf-8")
        self.assertIn("[[02-项目/Demo]]", migrated_text)
        appearance = (self.root / "Vault" / ".obsidian" / "appearance.json").read_text(encoding="utf-8")
        self.assertIn('"personal"', appearance)
        self.assertIn('"work-knowledge-vault"', appearance)
        self.assertTrue((self.root / "Vault" / ".obsidian" / "snippets" / "work-knowledge-vault.css").is_file())
        self.assertEqual((self.root / ".kb-layout-version").read_text(encoding="utf-8").strip(), "2")

    def test_ai_case_contract_supports_optional_raw_transcript(self):
        routing = (ROOT / "integrations" / "shared" / "work-knowledge" / "references" / "content-routing.md").read_text(encoding="utf-8")
        case_template = (ROOT / "Templates" / "案例复盘.md").read_text(encoding="utf-8")
        transcript_template = (ROOT / "Templates" / "案例原始对话.md").read_text(encoding="utf-8")
        self.assertIn("Do not split every case by default", routing)
        self.assertIn("one shared case_id", routing)
        self.assertIn("## 对话阶段与引导动作", case_template)
        self.assertIn("case_id:", case_template)
        self.assertIn("case_id:", transcript_template)
        self.assertIn("related_case: 案例复盘.md", transcript_template)


if __name__ == "__main__":
    unittest.main()
