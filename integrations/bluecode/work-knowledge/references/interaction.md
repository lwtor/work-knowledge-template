# Make next actions unmistakable

Whenever user confirmation is required, or one or more optional actions are available, end the response with a visually separate action block. Never bury it in status prose, a bullet summary, or a paragraph.

- Required confirmation heading: `## ⚠️ 需要你确认`
- Optional actions heading: `## ➡️ 可选的下一步`
- Put a horizontal rule immediately before the heading.
- For every action, state what will happen, what will not happen, and one exact reply the user can send.
- When several optional actions exist, number them and give each a different exact reply.
- Put nothing after the action block.
- Do not say “请让 Agent……”. Address the user directly.
- Never use bare `A`, `B`, a number, “确认”, or “确认提交” as the requested reply. The reply itself must name the authorized action and its boundary.
- Standard content-write reply: `确认按上述预览写入知识库，不提交、不推送。`
- Standard archive/delete/merge/move replies are defined in `references/maintenance.md`; do not improvise shorter variants.
- Before any push, display the commits, remote, and target branch. Use exact reply `确认将上述本地提交推送到已显示的远程分支。`; commit and push must never share one authorization.
- If no confirmation or useful optional action exists, do not manufacture an action block.

Example:

```markdown
---

## ➡️ 可选的下一步

### 1. 生成目录迁移预览

只生成预览，不移动文件、不提交、不推送。

请直接回复：`确认生成目录迁移预览。`
```
