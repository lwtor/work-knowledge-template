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
7. Report content, health, Git, framework version, and the resolved layout version. Missing marker or layout 1 is healthy and usable. In status mode only, if layout 1 is active, show this optional command once: `请先按照 MIGRATION.md 生成目录迁移预览，现在不要移动文件。` End with only actions that apply; each remains optional and separately authorized.
8. If the latest version is newer, state that the current version remains usable and show this optional command once:

```text
请读取 https://raw.githubusercontent.com/lwtor/work-knowledge-template/main/UPDATE.md，并严格按照其中最新协议把我的私人知识库框架更新到模板最新版本。更新前先展示版本变化、更新范围、受保护的个人数据和备份位置，等我确认后再执行；不要自动提交或推送。
```

9. If the latest version cannot be read, report it as unavailable; do not guess. Never modify notes, rebuild indexes, update, commit, pull, or push from a status request.
