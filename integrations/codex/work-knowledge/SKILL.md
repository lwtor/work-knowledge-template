---
name: work-knowledge
description: Use this Codex integration to record, summarize, organize, retrieve, search, inspect status, or update the user's existing personal work knowledge base. Triggers include “知识库”, “写入知识库”, “记录到知识库”, “存到知识库”, and “知识库状态”. Do not use its stored path for bootstrap, create, initialize, install, clone, or connect requests; those follow BOOTSTRAP.md and the current request.
---

# Codex Work Knowledge

This skill is for Codex only. Do not claim or imply compatibility with other agents.

## Locate the knowledge base

- When installed globally, read `.managed-by-work-knowledge-template` beside this file and use its `knowledge_base` value as the canonical root.
- When read from this repository before installation, the knowledge-base root is three directories above this skill folder.
- For bootstrap, creation, initialization, installation, clone, or connection requests, ignore any stored path and follow `BOOTSTRAP.md`. Ask once if the current request does not provide a real parent directory.

For an explicit knowledge-base request, the marker root is mandatory and the current workspace must not replace it. Compare this installed `.skill-version` with the codex integration under the resolved personal root. If they differ, report that the installed Skill is stale and offer its repository installer; do not claim the current task hot-reloaded a newly installed Skill. Open a new Codex task after installation.

Before operating, read `AGENTS.md`, `AI/启动配置.md`, `AI/AI-GUIDE.md`, and `AI/LOCAL.md` from the resolved root.

Before choosing any content path, read `references/layout.md` and resolve `.kb-layout-version`. Never mix layout 1 and layout 2 paths. If `.kb-migration/state.json` exists, pause ordinary writes and tell the user exactly how to resume the migration.

Before responding, read `references/interaction.md`. Any required confirmation or optional next action must use its separate final action block.

Before choosing a content form, destination, or template for a save request, read `references/content-routing.md`. Strong explicit signals should route directly; ask a classification question only for genuine ambiguity.

## Route the request

- To update the knowledge-base framework itself, read `references/update.md` first. This route is distinct from updating a note or project record.
- To preview or perform the optional personal-data directory migration, read `references/migration.md`. Framework update is not migration authorization.
- To save, summarize, remember, organize, or update conversation material, read `references/content-routing.md` and `references/ingest.md`.
- To retrieve or search existing knowledge, read `references/query.md`.
- To create or maintain project context, links, progress, or tasks, read `references/project.md`.
- To lint, rebuild indexes, review stale knowledge, clean Inbox/Daily, archive, or handle attachments, read `AI/知识维护.md` and `references/maintenance.md`.

Use only content visible in the current Codex task. Follow preview, confirmation, monthly logging, sensitivity, and no-silent-overwrite rules. Never upload, delete, merge, archive, or broadly rename content without separate authorization. Generated indexes are disposable views; notes remain authoritative.
