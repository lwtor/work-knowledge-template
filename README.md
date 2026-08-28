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
- `Archive/`：经确认归档、默认不参与检索的历史内容
- `Templates/`：笔记模板
- `AI/`：Agent 接入、检索、写入和安全规则

## 模板与个人数据

建议将模板仓库和个人知识库分开：

- 模板仓库保存规则、模板、脚本和 Skills；
- 个人知识库仓库保存本目录以及你的 `Knowledge/`、`Projects/`、`Daily/`、`Inbox/` 和 `Attachments/` 内容；
- 个人知识库仓库建议设置为 GitHub 私有仓库。

模板更新只允许修改框架文件，不应覆盖个人数据。个人规则写在 `AI/LOCAL.md`，不要直接修改模板规则文件。

仓库角色由根目录的 `.kb-role` 标识：`template` 表示模板仓库，`personal` 表示个人知识库仓库。Agent 在初始化、同步和更新前必须先检查这个标识。

## 协议边界

- `BOOTSTRAP.md` 负责创建或克隆个人仓库，在完成报告中显示私人仓库当前版本、模板最新版本和可选更新指令，随后把控制权交给个人仓库。
- `UPDATE.md` 只在用户明确要求更新框架时使用。
- 初始化不会自动升级个人仓库；发现新版时只提示一次，拒绝升级不影响使用当前版本。
## 一句话创建或接入

复制下面的纯文本，把占位内容改成你要保存到的父目录，然后发给 Agent；不修改时 Agent 会先询问：

```text
请读取下面这个文件，并严格按照其中协议为我创建或接入个人工作知识库：
https://github.com/lwtor/work-knowledge-template/blob/main/BOOTSTRAP.md

本地父目录：[请填写；未填写或保留此占位文字时请询问我]

除协议明确列出的登录授权、路径询问或冲突外，不要让我手工操作。
```


## Codex / BlueCode / vBuddy 接入

初始化完成后，当前 Agent 对应的 Skill 会安装到其全局 Skills 目录。Windows 验证时使用 `scripts/verify.ps1 -Agent Codex`、`-Agent BlueCode` 或 `-Agent Vbuddy`；macOS/Linux 使用 `scripts/verify.sh --agent codex`、`--agent bluecode` 或 `--agent vbuddy`，不会要求安装另一种 Agent。新会话可以直接要求记录、整理或查询知识库，无需重复提供本地路径。

BlueCode 在进程启动时加载一次全局 Skill；安装或更新 BlueCode Skill 后，需要重启 BlueCode 才会识别。vBuddy 在每个会话启动时加载全局 Skill；安装或更新 vBuddy Skill 后，新开一个会话即可生效，无需重启进程。

初始化完成报告会同时显示私人仓库当前框架版本和模板最新版本。存在可选更新时，Agent 会给出一句可直接复制的更新指令，但不会自动更新，也不会把旧版本视为初始化失败。

在新会话中要求“看下我的知识库”或“知识库状态”时，Agent 会递归盘点嵌套笔记，并再次显示当前版本、模板最新版本和可选更新提示；具体知识问题不会反复显示升级提示。
## 公司电脑无法 push 时

使用 `scripts/kb-transfer.py` 在两台设备间生成和导入加密增量包。详细流程见 `AI/离线同步.md`。该工具只传输个人数据目录，不传输整个仓库；双方分叉时不会覆盖，而会生成冲突报告供用户确认。

## 长期维护

- `python scripts/kb-lint.py`：只读检查元数据、链接、Inbox 滞留、待复核、附件和疑似重复。
- `python scripts/kb-secret-scan.py`：只报告疑似秘密的位置与规则，不显示秘密原文。
- `python scripts/kb-index.py`：重建知识索引、项目索引、待复核清单和跨项目待办。

新笔记采用最小 frontmatter；旧笔记渐进补齐，不在框架升级时批量改写。详见 `AI/知识维护.md`。

## 更新模板框架

只有你明确要求更新时才执行；拒绝更新不影响当前版本继续使用。更新操作先读取模板仓库最新 `UPDATE.md`，因此旧私人仓库不会依赖自身的旧更新协议；个人仓库规则仍用于提供附加保护，且新旧保护范围取并集。详细规则见 `AI/框架更新.md`。

Windows：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/update-framework.ps1 -Confirm
```

macOS/Linux：

```bash
./scripts/update-framework.sh https://github.com/lwtor/work-knowledge-template.git --yes
```

更新只操作框架路径，保留个人数据、归档、个人规则和写入日志；受保护目录中的 README、INDEX 和 TASKS 入口仅在缺失时补充，绝不覆盖同名文件。完成后不会自动提交或推送。更新意外中断时，最新更新器可以在严格检查仅有框架差异后续跑。
## Obsidian

安装 Obsidian 后，选择本仓库的本地目录作为 Vault，打开 `Home.md`。

## 安全提示

本仓库当前是空白模板。未来写入工作内容后，提交到 GitHub 前必须确认仓库权限和公司数据政策。密码、Token、内部敏感资料和不应公开的附件不得提交到公共仓库。
