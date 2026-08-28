# Personal Work Knowledge Base Framework Update

本文件是独立的框架更新协议。只有用户明确要求把个人知识库更新到模板最新版本时才生效；初始化、克隆、查询或写入请求都不构成更新授权。

无论个人仓库当前版本多旧，本次更新都以模板 `main` 分支最新的本文件为临时执行协议。个人仓库自己的规则用于识别本地布局、用户覆盖和附加保护；新旧保护范围不一致时取并集，不得因为采用最新协议而降低旧仓库已有的数据保护。更新完成后，本文件立即失效。

## 前置条件

1. 用户已经明确要求更新框架。
2. 目标目录是 Git 仓库，且 `.kb-role` 为 `personal`。
3. 工作区没有未提交修改；否则停止，明确说明“框架尚未开始更新”，列出阻塞更新的暂存、未暂存和未跟踪路径，并给出用户可以直接回复的下一步指令。默认推荐：`请先展示这些现有修改，确认后创建本地 Git 提交，不推送；提交完成后继续更新知识库框架。` 不得只说“请先处理”，不得把 `stash`、丢弃修改或手工执行命令作为默认选择。只有用户明确选择临时保存或丢弃时，才能在再次展示影响并获得确认后执行相应操作。
   - 唯一例外是此前框架更新已经中断，且用户明确确认续跑。此时只允许更新器的恢复开关继续：不得存在暂存修改，全部未提交路径必须位于框架白名单内，`Knowledge/`、`Projects/`、`Daily/`、`Inbox/`、`Attachments/`、`Archive/`、`AI/LOCAL.md` 和写入日志不得有新差异；任一条件不满足都必须停止。
4. 已完整读取模板 `main` 分支最新的本文件，再读取目标个人仓库自己的 `AGENTS.md`、`AI/启动配置.md` 和已有更新规则；不得反过来以旧协议替代本文件。

## 更新边界

允许更新的框架范围：`README.md`、`AGENTS.md`、`Home.md`、`AI/`、`Templates/`、`scripts/`、`integrations/`、`.gitignore`、`.gitattributes`、`.kb-version`。

必须保留：`Knowledge/`、`Projects/`、`Daily/`、`Inbox/`、`Attachments/`、`Archive/`、`AI/LOCAL.md`、`AI/写入日志.md`、`AI/写入日志/`、`.kb-role`，以及不属于已知框架路径的用户文件。

允许在受保护目录中仅补充缺失的框架入口文件：`Archive/README.md`、`Knowledge/README.md`、`Knowledge/INDEX.md`、`Projects/README.md`、`Projects/INDEX.md`、`Projects/TASKS.md`、`Inbox/README.md`、`Daily/README.md`。同名文件已经存在时不得覆盖，无论内容是否旧或不完整。

## 必须执行

1. 比较个人仓库与模板的 `.kb-version`；相同或更新时报告无需更新并停止。
2. 展示版本变化、将更新的框架路径、只在缺失时补充的入口文件、受保护目录、备份位置和 Obsidian 导航配置策略；当前 Agent 是 Codex、BlueCode 或 vBuddy 时，还要说明更新后会用个人仓库内的新集成重新安装对应的全局 `work-knowledge` Skill，使新会话使用新规则。Obsidian 只能覆盖模板管理的导航 CSS；已有非空 `appearance.json` 与 `app.json` 必须保留。
3. 等待用户确认；拒绝或未确认时不修改任何文件，个人仓库继续按原版本使用。
4. 确认后从与本文件相同的最新模板版本运行更新器：Windows 使用模板的 `scripts/update-framework.ps1` 并显式传入个人仓库路径；macOS/Linux 使用模板的 `scripts/update-framework.sh --target`。不得因为个人仓库已有旧更新器而优先运行旧文件。
5. 更新器必须先备份旧框架，只复制允许范围，并恢复个人规则与写入日志；旧版单文件日志不得丢失。
6. 当前 Agent 是 Codex、BlueCode 或 vBuddy 时，使用更新后的个人仓库自身安装脚本重新安装对应的全局 Skill：Codex 用 `scripts/install-codex-skill.ps1`（Windows）/ `scripts/install-codex-skill.sh`（macOS/Linux），BlueCode 用 `scripts/install-bluecode-skill.ps1` / `scripts/install-bluecode-skill.sh`，vBuddy 用 `scripts/install-vbuddy-skill.ps1` / `scripts/install-vbuddy-skill.sh`。不得从模板目录直接安装。其他 Agent 跳过此步。BlueCode 安装或重装后必须提示用户重启 BlueCode 进程，新 Skill 才会被加载；vBuddy 提示用户新开一个会话即可。
7. 使用更新后的个人仓库自身验证脚本并明确当前 Agent：Windows 使用 `scripts/verify.ps1 -Agent Codex`、`-Agent BlueCode` 或 `-Agent Vbuddy`；macOS/Linux 使用 `scripts/verify.sh --agent codex`、`--agent bluecode` 或 `--agent vbuddy`。不得因另一种可选 Agent 未安装或存在其他来源的 Skill 而失败。
8. 展示变更摘要，并明确区分“框架文件已更新”和“Git 尚未记录本次更新”。若本次框架更新产生未提交变更，必须以这句可直接回答的问题收尾：`框架已经更新完成，但这些变更尚未创建 Git 提交。是否要我先展示本次框架变更并创建本地 Git 提交？不会自动推送。` 用户确认后仅提交本次框架更新；推送仍需再次单独授权。不得自动提交或推送。

更新中断后的续跑仍需再次展示将执行的修复并获得确认。Windows 对最新模板更新器使用 `-ResumeFrameworkUpdate`；macOS/Linux 使用 `--resume-framework-update`。该开关不是通用的“忽略脏工作区”，只允许更新器通过上述白名单检查后恢复框架更新。

更新完成后，本文件失效，控制权重新交还个人仓库。
