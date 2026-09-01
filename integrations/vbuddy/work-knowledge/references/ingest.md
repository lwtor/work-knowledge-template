# Save and organize knowledge

1. Read `AI/AI-GUIDE.md`.
2. Read `references/content-routing.md`, choose the semantic form and area, then read that area's README or index and the matching file under `Templates/` before drafting. Preserve every required frontmatter field unless the repository rules explicitly make it optional. Use `confidence: unverified` for an unverified conclusion; do not misuse `status` as confidence.
3. Extract the problem, context, conclusions, steps, applicability, cautions, and sources from content visible in the current vBuddy task.
4. Search indexes, aliases, tags, and the knowledge, project, and inbox roots resolved by `references/layout.md`.
5. Decide whether to update an existing note, create one note, create an explicitly requested linked case transcript, or stage material in the resolved inbox root. Do not split every case by default.
6. Start the preview with `记录类型`, `目标位置`, and `记录重点`, then show the proposed files, paths, complete frontmatter, and content summary. Record the existing Git working-tree changes before writing so unrelated dirty files are not attributed to this operation.
7. End the preview with the numbered required-confirmation block. State that it will write only the displayed files and will not commit or push. Support the displayed number or copyable reply `确认按上述预览写入知识库，不提交、不推送。`. Wait for confirmation before writing.
8. After writing, update `updated` and append the current month under `AI/写入日志/`; update `last_verified` only when actually revalidated.
9. Rebuild indexes when useful; do not hand-maintain derived index entries.
10. Verify the written files, inspect Git status, and report created, updated, linked, omitted, unresolved, and version-control state. Distinguish this operation's changes from pre-existing dirty files.
11. If this operation produced uncommitted knowledge changes, add “创建本次知识变更的本地提交” to the recomputed optional-action queue. State that it will first show the changes and will not push. Support its displayed number or copyable reply `确认展示本次知识库变更并创建本地提交，不推送。`. Include every other still-applicable action too. A later push requires separate explicit authorization. If a touched file was already dirty and the changes cannot be safely separated, report that instead of offering an unsafe commit.

Do not present inference as fact, silently overwrite or merge notes, invent sources, or claim content was saved unless the files were actually written.
