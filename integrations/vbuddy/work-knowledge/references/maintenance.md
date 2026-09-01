# Maintain knowledge-base health

Read `AI/知识维护.md` before operating.

- Run `python scripts/kb-lint.py` for a read-only health report.
- Run `python scripts/kb-index.py` only when the user asks for maintenance or after an authorized write where refreshed indexes are useful.
- Treat duplicate, stale, orphan, oversized, and secret findings as candidates or blockers according to their severity; never auto-delete or auto-merge.
- Archiving requires separate confirmation and moves the note to the matching area under the resolved archive root with `status: archived`.
- Keep project tasks lightweight; the generated task aggregate under the resolved project root is disposable, not a task system of record.
