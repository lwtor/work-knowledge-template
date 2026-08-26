# Personal Work Knowledge Base Framework Update

本文件是独立的框架更新协议。只有用户明确要求把个人知识库更新到模板最新版本时才生效；初始化、克隆、查询或写入请求都不构成更新授权。

## 前置条件

1. 用户已经明确要求更新框架。
2. 目标目录是 Git 仓库，且 `.kb-role` 为 `personal`。
3. 工作区没有未提交修改；否则停止，让用户先处理。
4. 先读取目标个人仓库自己的 `AGENTS.md`、`AI/启动配置.md` 和已有更新规则。

## 更新边界

允许更新的框架范围：`README.md`、`AGENTS.md`、`Home.md`、`AI/`、`Templates/`、`scripts/`、`integrations/`、`.gitignore`、`.kb-version`。

必须保留：`Knowledge/`、`Projects/`、`Daily/`、`Inbox/`、`Attachments/`、`AI/LOCAL.md`、`.kb-role`，以及不属于已知框架路径的用户文件。

## 必须执行

1. 比较个人仓库与模板的 `.kb-version`；相同或更新时报告无需更新并停止。
2. 展示版本变化、将更新的框架路径、受保护目录和备份位置。
3. 等待用户确认；拒绝或未确认时不修改任何文件，个人仓库继续按原版本使用。
4. 确认后运行当前模板提供的更新器：Windows 使用 `scripts/update-framework.ps1` 并显式传入个人仓库路径；macOS/Linux 使用 `scripts/update-framework.sh --target`。
5. 更新器必须先备份旧框架，只复制允许范围，并恢复 `AI/LOCAL.md`。
6. 使用更新后的个人仓库自身验证脚本完成验证。
7. 展示变更摘要。提交和推送分别需要用户再次明确授权，不得自动执行。

更新完成后，本文件失效，控制权重新交还个人仓库。
