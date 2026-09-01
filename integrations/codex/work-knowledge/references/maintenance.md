# Maintain knowledge-base health

Read `AI/知识维护.md` before operating.

- Run `python scripts/kb-lint.py` for a read-only health report.
- Run `python scripts/kb-index.py` only when the user asks for maintenance or after an authorized write where refreshed indexes are useful.
- Treat duplicate, stale, orphan, oversized, and secret findings as candidates or blockers according to their severity; never auto-delete or auto-merge.
- Archiving requires a displayed move plan and separate confirmation with exact reply `确认按上述预览归档指定笔记，不提交、不推送。`; then move the note to the matching area under the resolved archive root with `status: archived`.
- Before deletion, list every target and its reference-check result, then use exact reply `确认删除上述指定文件，不提交、不推送。`.
- Before merging or broadly moving notes, show sources, destination, retained content, and affected links. Use exact reply `确认按上述预览合并指定笔记，不提交、不推送。` or `确认按上述预览移动指定文件，不提交、不推送。`; authorize only one action per confirmation.
- Keep project tasks lightweight; the generated task aggregate under the resolved project root is disposable, not a task system of record.
