# Search existing knowledge

1. Read `AI/AI-GUIDE.md`.
2. Search by keywords, project names, system names, error text, tags, and aliases.
3. Read generated indexes, project overviews, and the most relevant notes first; missing or stale indexes do not prove missing knowledge.
4. Check sources, status, update and review dates, and confidence. Search the resolved archive root only for historical requests.
5. Separate confirmed facts, inference, and unknowns.
6. Return the conclusion, applicable conditions, and local reference files.

If no reliable record exists, say so instead of inventing historical facts.

## Knowledge-base overview or status

Use this mode when the user says “查看知识库状态”, “知识库状态”, “检查知识库”, “看下我的知识库”, or otherwise asks to inspect the knowledge base itself. Treat “查看知识库状态” as the canonical copyable command. Do not use it for an ordinary targeted knowledge question.

1. Resolve the active layout, then recursively enumerate real files under its knowledge, project, case (when available), inbox, daily, and archive roots. Do not inspect only the first directory level, and do not call the vault empty merely because its indexes or top-level README files are empty.
2. Treat README files, generated `INDEX.md`, `TASKS.md`, and `.gitkeep` as structure rather than user knowledge. Count and list substantive notes separately, including nested paths under the resolved roots.
3. Read the titles and relevant frontmatter or headings of substantive notes before summarizing them. If a note exists but is unverified, report it as unverified rather than omitting it.
4. Inspect repository state without changing it: current branch, tracking branch, staged/unstaged/untracked paths, and local ahead/behind counts when already available. Do not fetch, commit, pull, push, or clean merely to produce status.
5. Summarize knowledge health: substantive note counts by area, Inbox backlog, unverified or review-due notes, generated-index presence, and lint warnings when the repository's read-only lint tool is available. Do not repair findings in status mode.
6. Read the personal repository root `.kb-version` as the current framework version. For this status report only, read the latest version from `https://raw.githubusercontent.com/lwtor/work-knowledge-template/main/.kb-version`; do not read or copy other template files.
7. Report content, health, Git, framework version, and the resolved layout version. Missing marker or layout 1 is healthy and usable.
8. Recompute the pending-action queue on every status request. If layout 1 is active, include “生成目录迁移预览”. If the latest version is newer, include “更新知识库框架” and state that the current version remains usable. If both apply, show both in the same numbered block; do not hide migration merely because update is selected or completed.
9. For framework update, include this copyable alternative below its number:

```text
请读取 https://raw.githubusercontent.com/lwtor/work-knowledge-template/main/UPDATE.md，并严格按照其中最新协议把我的私人知识库框架更新到模板最新版本。更新前先展示版本变化、更新范围、受保护的个人数据和备份位置，等我确认后再执行；不要自动提交或推送。
```

10. If the latest version cannot be read, report it as unavailable; do not guess. Never modify notes, rebuild indexes, update, commit, pull, or push from a status request.
11. Collect every applicable migration, framework-update, local-commit, and push option into one final `## ➡️ 可选的下一步` block following `references/interaction.md`. Number all items and support both number and copyable reply. Choosing one item does not dismiss the others. After that action finishes, fails, or is cancelled, recompute and repeat every still-applicable item. Only an explicit `0`, “暂不处理以上操作”, or an action-specific refusal suppresses it for the current conversation. Do not place optional actions in the status summary or write anything after this block.
