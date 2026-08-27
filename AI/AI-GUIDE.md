# AI 知识库使用规则

## 1. 定位与权威

本库是个人工作记忆库：`Knowledge/` 保存跨项目知识，`Projects/` 保存项目上下文，`Inbox/` 暂存未整理内容，`Daily/` 保存日常记录，`Archive/` 保存已归档历史。Markdown 正文与 frontmatter 是库内事实来源；正式业务系统仍是业务事实来源。

新 Agent 先读取 `AI/启动配置.md`、本文件和 `AI/LOCAL.md`，并实测读、搜、写权限。不得因读到规则就假设具备权限。

## 2. 最小元数据

新建 `Knowledge/` 笔记必须包含 `id`、`type`、`status`、`title`、`created`、`updated`、`confidence`、`confidentiality`、`tags`、`aliases`。项目资料按模板保留适用字段。旧笔记缺少字段时只报告并渐进补齐，不得因升级批量改写。

- `status`：`active`、`deprecated`、`archived`；暂存草稿可用 `draft`。
- `confidence`：`unverified` 或 `confirmed`。
- `created` 创建后不变；正文变化时更新 `updated`；只有重新验证结论时更新 `last_verified`。
- `review_after` 可为空；到期只进入待复核清单，不自动降级、移动或删除。
- `aliases` 保存本篇别名；`AI/术语与同义词.md` 保存跨笔记通用术语。
- `confidentiality`：`public`、`internal`、`restricted`。

## 3. 检索规则

1. 优先读取可重建的 `Knowledge/INDEX.md`、`Projects/INDEX.md` 和项目总览，再按关键词、项目名、错误文本、`tags`、`aliases` 和同义词搜索正文。
2. 默认检索 `Knowledge/`、`Projects/`，必要时检查 `Inbox/`、`Daily/`；只有用户需要历史内容时才检索 `Archive/`。
3. 阅读相关正文，优先使用 `active + confirmed` 且未明显过期的记录。
4. 区分知识库事实、AI 推断和待确认内容，并列出引用路径。
5. 未找到可靠记录时明确说明，不得虚构。

索引是派生内容，笔记才是事实来源。不得因索引缺失就认定知识不存在。

用户要求查看整个知识库、知识库状态或知识库概览时，必须递归盘点 `Knowledge/`、`Projects/`、`Inbox/`、`Daily/` 和 `Archive/` 中的真实文件，排除仅凭顶层 README 判断为空。报告实际条目、当前 `.kb-version`、模板最新版本和更新状态；存在新版时给出一次可选更新指令，但不得自动更新。普通的具体知识问答不附加版本提示。

## 4. 整理与查重

用户要求保存或整理当前会话内容时：

1. 提取问题、背景、结论、步骤、适用条件、版本、注意事项和来源。
2. 在 `Knowledge/`、`Projects/`、`Inbox/` 中依次检查 aliases、标题、tags/project/type、关键词与同义词、问题—原因—方案组合。
3. 同一问题、原因和方案优先更新原笔记；同主题不同环境优先分章节；互相冲突的结论分别保留并请求确认；多个可独立复用主题应建议拆分。
4. 未验证内容标记 `unverified`，不补造用户没有提供的信息。
5. 正式写入前展示目标路径和摘要，等待确认。
6. 写入后更新元数据，按需运行索引生成器，并写入当月 `AI/写入日志/YYYY-MM.md`。

## 5. Inbox、Daily 与归档

- Inbox 项目超过 30 天属于滞留项；巡检只提醒，由用户决定整理、保留或删除。期限可在 `AI/LOCAL.md` 覆盖。
- Daily 中反复出现或可复用的结论，应在用户要求整理时提议提升到 `Knowledge/` 或 `Projects/`。
- `unverified → confirmed` 需要实际验证依据。
- 已知过时内容改为 `deprecated`，保留替代方案链接。
- 归档必须单独确认；确认后设置 `status: archived` 并移动到 `Archive/Knowledge/` 或 `Archive/Projects/`。
- `AI/待复核清单.md` 由脚本生成，不是事实来源。

## 6. 项目与待办

项目资料放在 `Projects/项目名/`。项目总览只保存索引与关键结论，细节放在独立笔记。项目待办使用统一 Markdown checkbox，可选写截止日期和优先级；跨项目汇总由索引脚本生成，只读派生，不把本库扩展为完整任务管理系统。

## 7. 附件

- 使用相对路径，建议命名为 `Attachments/YYYY/MM/YYYYMMDD-可读名称.ext`。
- 单文件超过 10 MB 时警告并请用户决定；不默认启用 Git LFS。
- 写入前检查重名和敏感内容；删除前检查引用并单独确认。
- 巡检报告孤立附件，不自动删除。

## 8. 安全与变更边界

- 不静默覆盖、删除、自动合并冲突结论。
- 删除、合并、归档、大范围改名必须单独确认。
- 密码、私钥、Token、连接串和不必要的隐私不得写入。
- `restricted` 内容不得交给远程 Agent 或外部服务。
- 疑似敏感信息扫描只能阻止并报告，不自动清理，也不在日志复述秘密。
- 远程上传、Git 提交和推送均需各自授权。

## 9. 输出要求

检索回答包含结论、适用条件、事实与推断区分、参考文件。写入完成后报告新增、更新、关联、未写入内容和待确认事项。
