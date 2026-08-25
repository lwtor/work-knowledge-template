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

把模板 URL 和下面这句话发给具备 GitHub 与本地文件权限的 Agent：

```text
请读取下面这个文件，并严格按照其中协议为我创建或接入个人工作知识库：
https://github.com/lwtor/work-knowledge-template/blob/main/BOOTSTRAP.md

本地父目录：[可选：例如 E:\work；最终知识库将创建为 E:\work\work-knowledge。如果保留此占位文字不修改，请先询问我一次]

除协议明确列出的登录授权、路径询问或冲突外，不要让我手工操作。
```

完整流程见 AI/一键初始化.md。个人独立仓库默认通过模板生成并设为私有；只有明确要求保留上游关系时才真正 fork。

首次指令填写的是本地父目录，例如 E:\work；Agent 固定在其下 clone 为 E:\work\work-knowledge。父目录可以包含其他项目。没有填写时只询问一次，后续会话不再询问。
## 给 AI Agent 的启动指令

把本仓库的 GitHub URL 替换到下面的 `[GitHub URL]`：

```text
这是我的个人知识库模板，GitHub 地址是：

[GitHub URL]

请在本地为我初始化知识库：
1. 先读取仓库中的 README.md、AI/启动配置.md 和 AI/AI-GUIDE.md；
2. 询问或确认本地安装路径，不要覆盖已有目录；
3. 将仓库复制或克隆到本地；
4. 检查你是否能读取、搜索、新建和更新 Markdown 文件；
5. 向我报告本地路径、权限和仍需我操作的事项；
6. 不要导入其他资料，不要上传本地文件，不要删除已有内容。
```

## 从 GitHub 初始化

克隆本仓库后，可以在仓库根目录执行：

```bash
./scripts/setup.sh /path/to/your/Work-Knowledge
```

脚本只允许复制到新的空目录，目标目录非空时会停止，不会覆盖已有内容。初始化后可以执行：

```bash
./scripts/verify.sh
```

验证模板结构是否完整、是否仍然保持空白。
初始化脚本还会把 work-knowledge skill 注册到 Codex 的个人 skills 目录。注册后，在任意新的 Codex 会话中可直接说“把刚刚的对话总结到知识库”，不需要重复提供路径。

知识库移动后可执行 ./scripts/install-codex-skill.sh 重新注册，再用 ./scripts/verify.sh 验证。全局 skill 只保存路径和入口；实际规则仍以 AI/AI-GUIDE.md 为准。新会话不能读取其他会话的正文。

## 公司电脑无法 push 时

使用 `scripts/kb-transfer.py` 生成加密增量包，通过手机或 U 盘带回家。详细流程见 `AI/离线同步.md`。该工具只传输个人数据目录，不传输整个仓库，也不会生成明文同步包。

## 更新模板框架

在个人知识库仓库中，先提交当前修改，再执行：

```bash
./scripts/update-framework.sh [模板目录或 GitHub URL] --yes
./scripts/verify.sh
```

脚本会先备份框架文件，只更新 `README.md`、`AGENTS.md`、`Home.md`、`AI/`、`Templates/`、`scripts/`、`skills/`、`.gitignore` 和 `.kb-version`，不会操作个人数据目录。

## Obsidian

安装 Obsidian 后，选择本仓库的本地目录作为 Vault，打开 `Home.md`。

## 安全提示

本仓库当前是空白模板。未来写入工作内容后，提交到 GitHub 前必须确认仓库权限和公司数据政策。密码、Token、内部敏感资料和不应公开的附件不得提交到公共仓库。
