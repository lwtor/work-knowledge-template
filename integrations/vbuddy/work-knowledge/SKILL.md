---
name: work-knowledge
version: 1.0.0
description: Use this vBuddy skill to record, summarize, organize, retrieve, search, or update the user's existing personal work knowledge base (个人工作知识库). Triggers include '知识库', '写入知识库', 'work knowledge', 'work-knowledge', '记录到知识库', '存到知识库', '查知识库', '知识库里有什么', '知识库状态', '整理知识', '归档笔记', '知识巡检', '重建索引', and any request to save reusable knowledge or project context into the knowledge base. Do NOT use for bootstrap, create, initialize, install, clone, or connect requests; those follow BOOTSTRAP.md and the current request.
description_zh: 操作用户已有的个人工作知识库：记录、提炼、整理、检索、更新知识笔记与项目资料。触发词：'知识库'、'记录到知识库'、'存到知识库'、'查知识库'、'知识库里有什么'、'知识库状态'、'整理知识'、'归档'、'巡检'、'重建索引'等。不适用于知识库的创建、初始化、克隆或接入请求，那些走 BOOTSTRAP.md 协议。
---

# vBuddy Work Knowledge

This skill is for vBuddy only. Do not claim or imply compatibility with other agents.

vBuddy loads this skill once per conversation. After installing or updating it, a new conversation is required before it is recognized; no process restart is needed.

## Locate the knowledge base

- When installed globally, read `.managed-by-work-knowledge-template` beside this file and use its `knowledge_base` value as the canonical root. This skill folder typically lives at `~/.vbuddy/skills/work-knowledge/`.
- When read from this repository before installation, the knowledge-base root is three directories above this skill folder.
- For bootstrap, creation, initialization, installation, clone, or connection requests, ignore any stored path and follow `BOOTSTRAP.md`. Ask once if the current request does not provide a real parent directory.

For an explicit knowledge-base request, the marker root is mandatory and the current workspace must not replace it. Compare this installed `.skill-version` with the vbuddy integration under the resolved personal root. If they differ, report that the installed Skill is stale and offer its repository installer; open a new vBuddy conversation after installation.

Before operating, read `AGENTS.md`, `AI/启动配置.md`, `AI/AI-GUIDE.md`, and `AI/LOCAL.md` from the resolved root.

Before choosing any content path, read `references/layout.md` and resolve `.kb-layout-version`. Never mix layout 1 and layout 2 paths. If `.kb-migration/state.json` exists, pause ordinary writes and tell the user exactly how to resume the migration.

Before responding, read `references/interaction.md`. Any required confirmation or optional next action must use its separate final action block.

Before choosing a content form, destination, or template for a save request, read `references/content-routing.md`. Strong explicit signals should route directly; ask a classification question only for genuine ambiguity.

## Route the request

Reference files below live in `references/` next to this file; read them with file tools before acting.

- To update the knowledge-base framework itself, read `references/update.md` first. This route is distinct from updating a note or project record.
- To preview or perform the optional personal-data directory migration, read `references/migration.md`. Framework update is not migration authorization.
- To save, summarize, remember, organize, or update conversation material, read `references/content-routing.md` and `references/ingest.md`.
- To retrieve or search existing knowledge, read `references/query.md`.
- To create or maintain project context, links, progress, or tasks, read `references/project.md`.
- To lint, rebuild indexes, review stale knowledge, clean Inbox/Daily, archive, or handle attachments, read `AI/知识维护.md` and `references/maintenance.md`.

Use only content visible in the current vBuddy session. Follow preview, confirmation, monthly logging, sensitivity, and no-silent-overwrite rules. Never upload, delete, merge, archive, or broadly rename content without separate authorization. Generated indexes are disposable views; notes remain authoritative.
