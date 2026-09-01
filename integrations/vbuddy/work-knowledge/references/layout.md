# Resolve the content layout

- Missing .kb-layout-version or value 1: use only Knowledge, Projects, Inbox, Daily, Archive, and Attachments.
- Value 2: use only Vault/01-知识, Vault/02-项目, Vault/03-案例, Vault/04-收集箱, Vault/05-工作记录, Vault/90-归档, and Vault/附件.
- Never create Vault while the marker is missing or 1; never write legacy content roots when it is 2.
- Layout 1 remains fully usable. Mention optional migration only in a knowledge-base status report, after framework update, or when the user asks about directories. Do not repeat it during ordinary queries or writes.
- If layout migration is unfinished, stop ordinary writes and provide a directly answerable resume instruction.
