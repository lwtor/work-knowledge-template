# 新增 Agent 集成清单

本文档指导为新的 AI Agent 添加 work-knowledge 集成。执行集成前必须完整读取本文件。历史教训：vBuddy 集成时漏改了 `scripts/setup.sh` 的 Agent 参数分支，导致手动离线复制流程不认识新 Agent——每类触点都有一份明确清单，逐项核对，不要只凭对上一个 Agent 集成的印象。

## 触点清单（缺一即失败）

新增 Agent（下称 `<agent>`）时，目录名使用稳定的小写标识；命令行参数的拼写和大小写必须在安装、验证与文档中保持一致，不从 Agent 品牌名机械推导。

### 1. 集成文件 `integrations/<agent>/work-knowledge/`

- `SKILL.md`：frontmatter 含 `name: work-knowledge` 和带足中英触发词的 `description`（触发词命中率决定 Agent 何时调用技能）；正文含技能定位方式（读 `.managed-by-work-knowledge-template` 取 `knowledge_base`）、加载语义说明、路由表。
- `references/` 包含写入、查询、项目、维护、更新、布局、迁移、内容分类和交互规则。`interaction.md` 与 `content-routing.md` 不得自行编写：权威源位于 `integrations/shared/work-knowledge/references/`，运行 `python scripts/sync-agent-interaction.py` 生成全部 Agent 副本；新增 Agent 时同步更新脚本中的 Agent 列表。验证器会逐字检查，任何副本漂移都必须失败。其他 reference 可以从现有集成复制公共契约作为起点，但必须按目标 Agent 的术语和能力审查差异。

### 2. 安装脚本 `scripts/install-<agent>-skill.ps1` 和 `.sh`

- 目标目录和可选环境变量必须依据该 Agent 的官方说明或实际客户端验证分别确定；不得把 `~/.<agent>/skills/work-knowledge` 当作通用公式。将已确认的路径与加载方式写入该 Agent 自己的安装脚本和文档。
- 先校验目标存在时必须含本模板 marker（`.managed-by-work-knowledge-template`），否则拒绝，防误删用户自建技能。
- 清空目标目录（保留 marker）→ 复制 → 写 marker（`manager=work-knowledge-template` + `knowledge_base=<绝对路径>`）。
- 结尾输出加载提示，注明该 Agent 的生效方式（见"加载语义"）。

### 3. 验证脚本 `scripts/verify.ps1` 和 `scripts/verify.sh`

- `required` 文件清单加入新 Agent 的全部集成文件和安装脚本。
- 为 Windows 与 Bash 验证器新增一致的 Agent 选择值和分支：校验已安装 Skill 存在、marker 路径与当前库一致、全部 Skill 文件与仓库版本哈希/`cmp` 一致。
- **坑（已踩）**：verify.sh 用 `set -u`，`expected` 变量必须在所有 Agent 分支之前定义（曾放在 codex 分支内，单独跑其他 Agent 验证时报未定义变量）。
- 别忘了更新"旧的通用 skills 目录"报错信息里的 Agent 列表。

### 4. `scripts/setup.sh`（手动离线复制流程）

- Agent 参数列表加入 `<agent>`；安装逻辑保持“选谁只装谁”。兼容已有参数的原始语义：本模板中的 `both` 固定表示 Codex + BlueCode，全部已支持 Agent 使用 `all`。usage 文案和收尾提示同步。**这是最容易漏的触点**（vBuddy 集成时即漏此处），因为主链路（BOOTSTRAP/UPDATE）不走这个脚本。

### 5. 文档层（五处）

- `AGENTS.md`：Agent 接入清单加新 Agent 名 + 加载语义。
- `README.md`：验证命令示例、加载语义说明。
- `AI/启动配置.md`：新增"〈Agent〉自接入"章节（含旧版降级行为）；"已有个人知识库的更新"框架路径清单加 `integrations/<agent>/`；开头的全局注册说明。
- `UPDATE.md`：第 2、6、7 步的 Agent 枚举和安装/验证脚本名。
- `AI/框架更新.md`：Skill 重装条目加新 Agent 及其生效提示。

### 6. 版本号 `.kb-version`

**任何改动一律 bump 版本号**，不犹豫、不攒批，并同步更新 README 顶部徽章和页尾版本。commit message 按惯例：`feat: add <Agent> global skill integration` / `fix: cover <Agent> in ...`。

## 文件编码规范（Windows 上必踩，已实证）

- `.ps1`：UTF-8 **带 BOM** + CRLF。无 BOM 的中文 ps1 在 Windows PowerShell 5.1 下按 ANSI 解析必失败。用 Write/Edit 工具产出后需显式转换（读入→统一换行→带 BOM 写回）。
- `.sh`：UTF-8 无 BOM + LF，并提交为可执行模式 `100755`。仓库 `.gitattributes` 已有 `*.sh text eol=lf`，提交前用 `git ls-files --eol` 和 `git ls-files -s` 同时核对换行与模式。
- 提交前使用当前系统可用的编码检查工具逐一核对新文件；不要假设 Windows 一定提供 `file` 命令。

## 加载语义（按 Agent 实测确认，别假设）

- 进程启动时加载一次：安装/更新后必须**重启进程**（如 BlueCode）。
- 每个会话启动时加载：安装/更新后**新开会话**即可，无需重启（如 vBuddy）。
- 把实际语义写进 SKILL.md、安装脚本输出和全部文档，保持一致。

## 验证协议（提交前必须全过）

1. 模板仓库框架检查：`verify.ps1 -Agent Framework` 和 `verify.sh --agent framework` 双通道通过。
2. 端到端：从当前待验证版本创建临时副本 → `.kb-role` 改 `personal` → 跑目标 Agent 安装脚本 → 用同一 Agent 选择值运行验证并通过。
3. 隔离回归：分别只安装并验证每个受支持 Agent；验证当前 Agent 时，其他 Agent 未安装、安装在别处或存在非模板同名目录均不得影响结果。再单独确认验证一个确实未安装的目标 Agent 会给出准确错误。
4. setup.sh：用 `HOME`/各 Agent 实际支持的 home 参数指向沙盒假目录，验证单 Agent 参数只安装目标 Agent、`both` 保持既有含义、`all` 安装全部、非法参数被拒，测完删沙盒。
5. Agent 侧终验（新会话）：问“看下我的知识库”，按该 Agent 实际提供的可观察信号确认 Skill 已加载，例如 Skill 调用标识、来源信息或按 marker 定位到正确知识库；不要要求所有 Agent 都展示相同的工具调用界面。

## 通用教训

- **新增枚举值后搜索全部既有 Agent 名**：全仓库搜索当前所有 Agent 的目录标识和显示名称；凡是把 Agent 名写进参数列表、分支、文案或报错的地方都是触点，逐一确认新 Agent 是否需要加入。
- `git add` 多路径时若任一路径不存在会返回错误，且可能导致预期文件未进入暂存区；应检查退出状态，并用 `git status --short` 复核实际暂存范围。
- 集成文件应共享知识库的安全边界和业务契约，但安装路径、frontmatter、工具能力、加载方式及会话术语可以因 Agent 而不同；diff 中的差异必须能由目标 Agent 的实际行为解释。
