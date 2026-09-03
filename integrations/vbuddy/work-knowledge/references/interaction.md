# Unified action queue

Whenever user confirmation is required, or one or more optional actions are available, end the response with one visually separate action block. Never bury actions in status prose, a bullet summary, or a paragraph.

## Format

- Required confirmation heading: `## ⚠️ 需要你确认`
- Optional actions heading: `## ➡️ 可选的下一步`
- Put a horizontal rule immediately before the heading.
- Number every action from `1`, even when there is only one action.
- For every action, state what will happen and what will not happen.
- End each action with both forms: `回复数字：1` and a copyable full reply such as `或复制回复：确认……`.
- A bare number authorizes only the matching item in the most recent action block. It never authorizes any other action or an older block.
- Do not use letters such as A/B. Do not require a bare “确认” or “确认提交”.
- Put nothing after the action block.
- Do not say “请让 Agent……”. Address the user directly.
- If no confirmation or useful optional action exists, do not manufacture an action block.

## Pending-action queue

- Before every knowledge-base status response and after every completed, failed, or cancelled action, recompute all currently applicable actions.
- Typical actions include framework update, layout migration, local commit, push, write confirmation, conflict handling, review, and cleanup.
- Put every applicable action into the same final block. Choosing one item does not dismiss the others.
- After executing one item, show every remaining applicable item again with fresh numbering. Do not rely on the user remembering an earlier message.
- Remove an item only when its condition is no longer true or the user explicitly says it is not needed.
- In an optional-action block, add `0. 暂不处理以上操作`. Reply `0` or `暂不处理以上操作。` explicitly dismisses the currently listed optional items for the rest of the current conversation. It does not change files or create a permanent preference.
- A new conversation has no dismissal memory, so status mode must recompute applicable actions again. If the user wants a persistent preference, preview an `AI/LOCAL.md` change and obtain normal write confirmation.

## Standard copyable replies

- Content or project write: `确认按上述预览写入知识库，不提交、不推送。`
- Skill reinstall: `确认使用当前私人知识库中的安装脚本重新安装当前 Agent 的 work-knowledge Skill。`
- Archive, delete, merge, and move: use the action-specific replies in `references/maintenance.md`.
- Push: first display the commits, remote, and target branch; use `确认将上述本地提交推送到已显示的远程分支。`. Commit and push never share one authorization.

Example:

```markdown
---

## ➡️ 可选的下一步

### 1. 更新知识库框架

更新框架文件；不会迁移个人目录、提交或推送。

回复数字：`1`

或复制回复：`确认执行框架更新，不提交、不推送。`

### 2. 生成目录迁移预览

只生成预览；不会移动文件、提交或推送。

回复数字：`2`

或复制回复：`确认生成目录迁移预览。`

### 0. 暂不处理以上操作

回复数字：`0`
```
