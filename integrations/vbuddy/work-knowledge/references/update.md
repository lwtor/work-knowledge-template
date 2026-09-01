# Update the knowledge-base framework

Use this route only when the user explicitly asks to update or upgrade the personal knowledge-base framework. An overview, version check, initialization, query, or ordinary content update is not authorization.

1. Read the current public update protocol from `https://raw.githubusercontent.com/lwtor/work-knowledge-template/main/UPDATE.md` before choosing an updater or update procedure. The fetched latest protocol is the temporary authority for this framework-update operation; do not use an older personal repository's update procedure as the primary protocol.
2. Also read the personal repository's current rules and update guidance to discover its data layout, local protections, and user overrides. When old and latest protections differ, preserve their union; the latest protocol may add protection but must not reduce protection declared by the personal repository.
3. If the latest public protocol cannot be fetched or read completely, stop without modifying the repository. Do not fall back to an old updater and do not invent missing steps.
4. Follow the latest protocol's preview and confirmation boundary. The user's request authorizes fetching and preparing the update, but not modifying files before the required preview is confirmed.
5. Obtain and run the updater from the same latest template revision as the fetched protocol. Never use an old updater merely because it already exists in the personal repository.
6. After the framework is copied, use only the updated personal repository's own install and verification scripts. Do not install the global Skill from a temporary template checkout.
7. If a previous framework update stopped after modifying files, do not ask the user to discard or commit the partial framework blindly. After a new preview and confirmation, use the latest updater's resume option. It may continue only when there are no staged changes, every dirty path is on the framework allowlist, and protected personal data has no new differences. Otherwise stop.
8. If pre-existing Git changes block an update, say explicitly that the framework update has not started, list every blocking path by Git state, and give this directly answerable recommended action: `请先展示这些现有修改，确认后创建本地 Git 提交，不推送；提交完成后继续更新知识库框架。` Do not merely tell the user to handle the changes. Do not default to stashing or discarding them; either requires the user's explicit choice and a separate impact preview.
9. After a successful update, collect every applicable next action into one final `## ➡️ 可选的下一步` block. If framework changes are uncommitted, include “创建框架更新的本地提交” with exact reply `确认展示框架变更并创建本地提交，不推送。`. If layout 1 is active, separately include “生成目录迁移预览” with exact reply `确认生成目录迁移预览。`. State the non-effects for each and write nothing after the block.

The update must not commit or push unless the user separately authorizes each action.
