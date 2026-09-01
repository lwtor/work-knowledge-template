# Make next actions unmistakable

Whenever user confirmation is required, or one or more optional actions are available, end the response with a visually separate action block. Never bury it in status prose, a bullet summary, or a paragraph.

- Required confirmation heading: `## ⚠️ 需要你确认`
- Optional actions heading: `## ➡️ 可选的下一步`
- Put a horizontal rule immediately before the heading.
- For every action, state what will happen, what will not happen, and one exact reply the user can send.
- When several optional actions exist, number them and give each a different exact reply.
- Put nothing after the action block.
- Do not say “请让 Agent……”. Address the user directly.
- If no confirmation or useful optional action exists, do not manufacture an action block.

Example:

```markdown
---

## ➡️ 可选的下一步

### 1. 生成目录迁移预览

只生成预览，不移动文件、不提交、不推送。

请直接回复：`确认生成目录迁移预览。`
```
