# Save and organize knowledge

1. Read `AI/AI-GUIDE.md`.
2. Choose and read the matching file under `Templates/` before drafting a new note. Preserve every required frontmatter field unless the repository rules explicitly make it optional. Use `confidence: unverified` for an unverified conclusion; do not misuse `status` as confidence.
3. Extract the problem, context, conclusions, steps, applicability, cautions, and sources from content visible in the current BlueCode task.
4. Search indexes, aliases, tags, `Knowledge/`, `Projects/`, and `Inbox/` for related material.
5. Decide whether to update an existing note, create a note, or stage it in `Inbox/`.
6. Show the proposed files, paths, complete frontmatter, and content summary. Record the existing Git working-tree changes before writing so unrelated dirty files are not attributed to this operation.
7. Wait for user confirmation before writing.
8. After writing, update `updated` and append the current month under `AI/写入日志/`; update `last_verified` only when actually revalidated.
9. Rebuild indexes when useful; do not hand-maintain derived index entries.
10. Verify the written files, inspect Git status, and report created, updated, linked, omitted, unresolved, and version-control state. Distinguish this operation's changes from pre-existing dirty files.
11. If this operation produced uncommitted knowledge changes, end with one optional question: “是否要我先展示本次知识库变更并创建本地 Git 提交？不会自动推送。” Do not commit without confirmation. A later push requires separate explicit authorization. If a touched file was already dirty and the changes cannot be safely separated, report that instead of offering an unsafe commit.

Do not present inference as fact, silently overwrite or merge notes, invent sources, or claim content was saved unless the files were actually written.
