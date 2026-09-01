#!/usr/bin/env python3
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "integrations/shared/work-knowledge/references/interaction.md"
TARGETS = [
    ROOT / f"integrations/{agent}/work-knowledge/references/interaction.md"
    for agent in ("codex", "bluecode", "vbuddy")
]


def main() -> int:
    content = SOURCE.read_text(encoding="utf-8-sig")
    for target in TARGETS:
        target.write_text(content, encoding="utf-8", newline="\n")
        print(f"已同步：{target.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
