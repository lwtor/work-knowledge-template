# Choose the content form before drafting

Use this rule for every save, summarize, organize, or update request. Resolve the active layout first, then choose the semantic area before choosing a filename or template.

## Routing decision

- Reusable technical facts, concepts, mechanisms, commands, and practices belong in the resolved knowledge root. Examples: KSP mechanisms, coroutine behavior, Lifecycle APIs, Git operations, and Gerrit concepts.
- Material whose value depends on one specific project's code, business behavior, requirement, delivery, test plan, or decision belongs in that project's directory.
- A process worth reviewing or sharing belongs in the resolved case root. Strong case signals include “AI 使用案例”, “怎么引导 AI”, “提示语改进”, “对话过程”, “协作复盘”, “问题排查过程”, “关键转折”, and “以后怎么更好地问”. An AI-collaboration case emphasizes interaction and method; technical details are supporting context, not the default center of the note.
- Unclassified or intentionally deferred material belongs in the resolved inbox root.
- Chronological work activity without a stronger reusable, project, or case purpose belongs in the resolved daily root.

The same conversation may justify more than one artifact, such as reusable technical knowledge plus an AI-collaboration case. Propose each artifact and its distinct value; do not silently duplicate the same content.

## Intent handling

- When the user explicitly names a form or gives a strong signal, choose it directly. Do not ask them to reconfirm an obvious “AI 使用案例” as knowledge versus project material.
- When two or more routes remain genuinely plausible and would materially change the result, show a short numbered classification choice before drafting. State the proposed route and why. Do not produce a full note preview until the classification is resolved.
- Before drafting, read the selected area's README or index and the matching template. Do not choose a path only from the word “知识库”.
- At the top of the preview, always state `记录类型`, `目标位置`, and `记录重点` so the user can catch a wrong classification before writing.

## AI-collaboration cases

- Default to one analysis note based on `Templates/案例复盘.md`. Focus on user intent, information supplied, AI interpretation, ineffective guidance, corrections, key turns, effective prompts, and reusable collaboration methods.
- Do not make the final technical solution the center unless the user asks for a technical-debug case. Keep necessary technical facts as concise background and link separately extracted knowledge when applicable.
- Create a second raw-transcript note from `Templates/案例原始对话.md` only when the user explicitly asks for “原始记录”, “问答全记录”, “完整对话”, “原文”, or an equivalent complete transcript. Do not split every case by default; ordinary cases remain one analysis note.
- When two notes are created, place them in one directory named `YYYYMMDD-可读主题`, use one shared case_id value, use stable filenames `案例复盘.md` and `原始对话.md`, and link them both ways.
- A raw transcript preserves visible message order and speaker roles. Do not silently rewrite, summarize, fill gaps, or present a partial transcript as complete. If the task cannot access the full conversation, identify the missing range before previewing the write.

## Required examples

- “整理 KSP 的工作机制，方便复习” -> knowledge.
- “记录这个项目需求的交付和测试安排” -> project.
- “记录这次怎么引导 AI 找到答案，作为 AI 使用案例” -> case, without an extra classification question.
- “保留这次完整问答，再总结引导方法” -> one case directory containing analysis plus raw transcript.
- “先放着，之后再整理” -> inbox.
