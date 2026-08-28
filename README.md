[![Framework v0.7.11](https://img.shields.io/badge/framework-v0.7.11-2563eb?style=for-the-badge)](.kb-version)

<div align="center">

# Personal Work Knowledge Base

### 把 AI 对话变成真正属于你的长期工作记忆

[![Local First](https://img.shields.io/badge/storage-local--first-16a34a?style=flat-square)](#安全与数据边界)
[![Format](https://img.shields.io/badge/content-Markdown-475569?style=flat-square)](#知识库结构)
[![Agents](https://img.shields.io/badge/agents-Codex%20%7C%20BlueCode%20%7C%20vBuddy-7c3aed?style=flat-square)](#agent-兼容)

本地优先 · Git 版本化 · Obsidian 浏览 · 多 Agent 读写

[快速开始](#-一句话创建或接入) · [工作流程](#-工作流程) · [Agent 兼容](#-agent-兼容) · [安全边界](#-安全与数据边界) · [框架更新](#-更新框架)

</div>

---

## ✨ 核心能力

这是一个面向个人工作的知识库模板。它把散落在 AI 对话、项目记录和日常工作中的信息，整理为普通 Markdown 文件，并通过明确的协议让 Agent 能够安全地查询、预览和写入。

| 能力 | 说明 |
| --- | --- |
| 🧠 知识沉淀 | 将对话中的问题、结论、步骤和注意事项整理为可复用笔记 |
| 📁 项目管理 | 保存项目需求、设计、测试、链接、决策和待办 |
| 🔎 跨会话检索 | 安装对应 Agent Skill 后，新会话无需重复说明知识库路径 |
| 🛡️ 写入保护 | 默认先预览、再确认；删除、覆盖、归档和上传需要单独授权 |
| 🔄 框架升级 | 模板规则可以更新，个人知识、附件和本地规则不会被覆盖 |
| 📴 离线传输 | 无法推送 Git 时，可使用加密增量包在设备间传输个人数据 |

## 🚀 一句话创建或接入

将下面这段话复制给具备 GitHub 和本地文件权限的 Agent。把父目录占位内容替换为你的实际路径；如果没有填写，Agent 会询问一次，不会自行猜测保存位置。

```text
请读取下面这个文件，并严格按照其中协议为我创建或接入个人工作知识库：
https://github.com/lwtor/work-knowledge-template/blob/main/BOOTSTRAP.md

本地父目录：[请填写；未填写或保留此占位文字时请询问我]

除协议明确列出的登录授权、路径询问或冲突外，不要让我手工操作。
```

初始化完成后，新开一个会话即可直接说：

```text
把刚刚的对话总结到知识库。
```

或者：

```text
看下我的知识库现在有哪些内容。
```

## 🧭 工作流程

```text
读取 BOOTSTRAP.md
        ↓
创建或复用私人 GitHub 仓库
        ↓
克隆到“用户提供的父目录/work-knowledge”
        ↓
安装当前 Agent 对应的全局 Skill
        ↓
验证读、搜、写和版本状态
        ↓
后续新会话直接查询或记录知识
```

`BOOTSTRAP.md` 只负责创建、克隆和首次接入。完成后控制权立即移交给私人仓库，日常操作只遵循私人仓库自己的规则。模板更新不会被偷偷绑定到初始化流程。

## 🤖 Agent 兼容

| Agent | Windows 验证 | macOS/Linux 验证 | Skill 更新后生效方式 |
| --- | --- | --- | --- |
| Codex | `scripts/verify.ps1 -Agent Codex` | `scripts/verify.sh --agent codex` | 新会话使用新 Skill |
| BlueCode | `scripts/verify.ps1 -Agent BlueCode` | `scripts/verify.sh --agent bluecode` | 重启 BlueCode 进程 |
| vBuddy | `scripts/verify.ps1 -Agent Vbuddy` | `scripts/verify.sh --agent vbuddy` | 新开一个会话 |

三种接入彼此隔离：只验证当前 Agent，不会因为其他 Agent 未安装而失败。仓库中的集成文件位于 `integrations/<agent>/work-knowledge/`，它们是各 Agent 的专用实现，不应被描述为通用 Skill。

## 🗂️ 知识库结构

```text
work-knowledge/
├─ Knowledge/       跨项目可复用知识
├─ Projects/        项目资料、过程记录和待办
├─ Inbox/           尚未整理的临时内容
├─ Daily/           日常工作记录
├─ Archive/         经确认归档的历史内容
├─ Attachments/     图片、文档等附件（个人仓库中使用）
├─ Templates/       知识、项目、问题解决和日常记录模板
├─ AI/              Agent 规则、个人覆盖层和写入日志
├─ integrations/    Codex、BlueCode、vBuddy 专用 Skill
└─ scripts/         安装、验证、索引、巡检、更新和传输工具
```

仓库角色由 `.kb-role` 标识：

- `template`：公共模板，只保存框架、规则和工具；
- `personal`：私人知识库，保存个人知识和项目资料。

个人规则写在 `AI/LOCAL.md`，避免直接修改公共规则文件，从而降低以后升级框架时的冲突。

## 🔐 安全与数据边界

- 个人知识库应使用私有仓库，并遵守所在组织的数据政策。
- 密码、Token、私钥和不应上传的内部资料不得写入公共仓库。
- 新增或修改正式知识前，Agent 必须先展示预览并获得确认。
- 删除、覆盖、合并、归档、批量重命名和远程上传需要单独授权。
- 框架更新只操作白名单路径，并在执行前创建备份。
- `Knowledge/`、`Projects/`、`Daily/`、`Inbox/`、`Attachments/`、`Archive/`、`AI/LOCAL.md` 和写入日志属于受保护数据。

## 🧰 长期维护

```bash
# 只读检查元数据、链接、Inbox 滞留、附件和疑似重复
python scripts/kb-lint.py

# 扫描疑似秘密，只报告位置，不显示秘密原文
python scripts/kb-secret-scan.py

# 重建知识索引、项目索引、待复核清单和跨项目待办
python scripts/kb-index.py
```

公司电脑无法推送时，可使用 `scripts/kb-transfer.py` 生成和导入加密增量包。它只传输个人数据目录，双方发生分叉时会停止并生成冲突报告，不会静默覆盖。详细流程见 [`AI/离线同步.md`](AI/离线同步.md)。

## 🔄 更新框架

初始化和框架更新是两个独立流程。知识库版本落后时仍然可以继续使用，只有用户明确要求更新才会执行。

推荐直接对 Agent 说：

```text
请读取 https://raw.githubusercontent.com/lwtor/work-knowledge-template/main/UPDATE.md，并严格按照其中最新协议把我的私人知识库框架更新到模板最新版本。更新前先展示版本变化、更新范围、受保护的个人数据和备份位置，等我确认后再执行；不要自动提交或推送。
```

更新器会从模板最新版本获取协议和脚本，备份旧框架，保留个人数据，并在完成后重新安装当前 Agent 对应的 Skill。提交与推送仍需分别确认。

## 💎 Obsidian

安装 [Obsidian](https://obsidian.md/) 后，将私人知识库的本地目录作为 Vault 打开，再进入 `Home.md`。Obsidian 是推荐浏览界面，但不是运行知识库的必要依赖；所有内容始终是普通 Markdown 文件。

## 📚 关键文档

| 文档 | 用途 |
| --- | --- |
| [`BOOTSTRAP.md`](BOOTSTRAP.md) | 从零创建或接入私人知识库 |
| [`UPDATE.md`](UPDATE.md) | 按模板最新协议更新私人仓库框架 |
| [`AGENTS.md`](AGENTS.md) | Agent 进入仓库后的总入口 |
| [`AI/启动配置.md`](AI/启动配置.md) | 各 Agent 的安装、验证和降级规则 |
| [`AI/AI-GUIDE.md`](AI/AI-GUIDE.md) | 检索、写入、确认和安全约束 |
| [`AI/知识维护.md`](AI/知识维护.md) | 索引、复核、归档和长期巡检规则 |
| [`integrations/ADDING-AGENT.md`](integrations/ADDING-AGENT.md) | 新增 Agent 专用接入时的完整检查清单 |

---

<div align="center">

当前框架版本：**0.7.11**

模板负责提供能力，私人仓库始终由用户自己控制。

</div>
