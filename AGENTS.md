# 工作知识库入口

这是个人工作知识库。执行知识库相关任务前，先阅读 `README.md`、`AI/启动配置.md` 和 `AI/AI-GUIDE.md`；执行巡检、索引、归档或生命周期维护时再读取 `AI/知识维护.md`。

当前仓库提供两种 Agent 专用接入：`integrations/codex/work-knowledge/`（Codex）和 `integrations/bluecode/work-knowledge/`（BlueCode）。不要把该目录描述为通用 Agent Skill，也不要推断其他 Agent 已受支持。BlueCode 的全局 Skill 在进程启动时加载一次，安装或更新后必须提示用户重启 BlueCode。

框架更新只在用户明确要求时读取 `AI/框架更新.md`。初始化完成报告，以及用户明确要求“查看知识库”“知识库状态”“知识库概览”时，可以只读比较当前 `.kb-version` 与模板最新 `.kb-version` 并给出一次可选更新提示；普通具体知识查询和写入时不得检查模板版本，任何场景都不得主动升级。

不要把普通项目代码、临时脚本或未经确认的敏感资料写入本目录。
