#!/usr/bin/env python3
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
AGENTS = ("codex", "bluecode", "vbuddy")
SHARED_REFERENCES = ("interaction.md", "content-routing.md")


def main() -> int:
    for name in SHARED_REFERENCES:
        source = ROOT / "integrations/shared/work-knowledge/references" / name
        content = source.read_text(encoding="utf-8-sig")
        for agent in AGENTS:
            target = ROOT / f"integrations/{agent}/work-knowledge/references" / name
            target.write_text(content, encoding="utf-8", newline="\n")
            print(f"已同步：{target.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
