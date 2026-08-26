from __future__ import annotations

import importlib.util
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    spec.loader.exec_module(module)
    return module


class KnowledgeToolsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        for name in ("Knowledge", "Projects", "Inbox", "Daily", "Attachments", "Archive", "AI/写入日志"):
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
        files = transfer.data_files(self.root)
        self.assertNotIn("Knowledge/INDEX.md", files)
        self.assertIn("Knowledge/real.md", files)

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


if __name__ == "__main__":
    unittest.main()
