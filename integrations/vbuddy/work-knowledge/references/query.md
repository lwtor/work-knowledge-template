# Search existing knowledge

1. Read `AI/AI-GUIDE.md`.
2. Search by keywords, project names, system names, error text, tags, and aliases.
3. Read generated indexes, project overviews, and the most relevant notes first; missing or stale indexes do not prove missing knowledge.
4. Check sources, status, update and review dates, and confidence. Search `Archive/` only for historical requests.
5. Separate confirmed facts, inference, and unknowns.
6. Return the conclusion, applicable conditions, and local reference files.

If no reliable record exists, say so instead of inventing historical facts.

## Knowledge-base overview or status

Use this mode when the user asks to view, inspect, summarize, inventory, or check the status of the knowledge base itself, for example “看下我的知识库”, “知识库里有什么”, or “知识库状态”. Do not use it for an ordinary targeted knowledge question.

1. Recursively enumerate real files under `Knowledge/`, `Projects/`, `Inbox/`, `Daily/`, and `Archive/`. Do not inspect only the first directory level, and do not call the vault empty merely because its indexes or top-level README files are empty.
2. Treat README files, generated `INDEX.md`, `TASKS.md`, and `.gitkeep` as structure rather than user knowledge. Count and list substantive notes separately, including nested paths such as `Knowledge/Git/example.md`.
3. Read the titles and relevant frontmatter or headings of substantive notes before summarizing them. If a note exists but is unverified, report it as unverified rather than omitting it.
4. Read the personal repository root `.kb-version` as the current framework version. For this overview/status report only, read the latest version from `https://raw.githubusercontent.com/lwtor/work-knowledge-template/main/.kb-version`; do not read or copy other template files.
5. Report these fields: knowledge-base path, substantive content summary, current framework version, latest template version, and update status.
6. If the latest version is newer, state that the current version remains usable and show this optional command once:

```text
请读取 https://raw.githubusercontent.com/lwtor/work-knowledge-template/main/UPDATE.md，并严格按照其中最新协议把我的私人知识库框架更新到模板最新版本。更新前先展示版本变化、更新范围、受保护的个人数据和备份位置，等我确认后再执行；不要自动提交或推送。
```

7. If the latest version cannot be read, report it as unavailable; do not guess. Never update, commit, or push from an overview request.
