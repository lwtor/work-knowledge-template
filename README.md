# Personal Work Knowledge Base

这是一个本地优先的个人知识库模板，用于：

- 保存从 AI 对话中提炼出的可复用知识；
- 保存项目的需求、设计、测试、链接、开发记录和待办；
- 通过 Obsidian 浏览，通过具备本地文件权限的 AI Agent 检索和整理。

## 目录

- `Knowledge/`：跨项目可复用知识
- `Projects/`：项目资料和过程记录
- `Inbox/`：尚未整理的临时内容
- `Daily/`：日常工作记录
- `Templates/`：笔记模板
- `AI/`：Agent 接入、检索、写入和安全规则

## 模板与个人数据

建议将模板仓库和个人知识库分开：

- 模板仓库保存规则、模板、脚本和 Skills；
- 个人知识库仓库保存本目录以及你的 `Knowledge/`、`Projects/`、`Daily/`、`Inbox/` 和 `Attachments/` 内容；
- 个人知识库仓库建议设置为 GitHub 私有仓库。

模板更新只允许修改框架文件，不应覆盖个人数据。个人规则写在 `AI/LOCAL.md`，不要直接修改模板规则文件。

仓库角色由根目录的 `.kb-role` 标识：`template` 表示模板仓库，`personal` 表示个人知识库仓库。Agent 在初始化、同步和更新前必须先检查这个标识。

## 一句话创建或接入

复制下面的纯文本，把占位内容改成你要保存到的父目录，然后发给 Agent；不修改时 Agent 会先询问：

```text
请读取下面这个文件，并严格按照其中协议为我创建或接入个人工作知识库：
https://github.com/lwtor/work-knowledge-template/blob/main/BOOTSTRAP.md

本地父目录：[请填写；未填写或保留此占位文字时请询问我]

除协议明确列出的登录授权、路径询问或冲突外，不要让我手工操作。
```


## Codex 接入

初始化完成后，Codex Skill 会安装到当前用户的 Codex Skills 目录。Windows 使用 `scripts/install-codex-skill.ps1` 和 `scripts/verify.ps1`；macOS/Linux 使用对应的 `.sh` 脚本。新会话可以直接要求记录、整理或查询知识库，无需重复提供本地路径。
## 公司电脑无法 push 时

使用 `scripts/kb-transfer.py` 生成加密增量包，通过手机或 U 盘带回家。详细流程见 `AI/离线同步.md`。该工具只传输个人数据目录，不传输整个仓库，也不会生成明文同步包。

## 更新模板框架

在个人知识库仓库中，先提交当前修改，再执行：

```bash
./scripts/update-framework.sh [模板目录或 GitHub URL] --yes
./scripts/verify.sh
```

脚本会先备份框架文件，只更新 `README.md`、`AGENTS.md`、`Home.md`、`AI/`、`Templates/`、`scripts/`、`integrations/codex/`、`.gitignore` 和 `.kb-version`，不会操作个人数据目录。

## Obsidian

安装 Obsidian 后，选择本仓库的本地目录作为 Vault，打开 `Home.md`。

## 安全提示

本仓库当前是空白模板。未来写入工作内容后，提交到 GitHub 前必须确认仓库权限和公司数据政策。密码、Token、内部敏感资料和不应公开的附件不得提交到公共仓库。
