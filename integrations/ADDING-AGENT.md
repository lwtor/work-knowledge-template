# 新增 Agent 集成清单

本文档指导为新的 AI Agent 添加 work-knowledge 集成。执行集成前必须完整读取本文件。历史教训：vBuddy 集成时漏改了 `scripts/setup.sh` 的 Agent 参数分支，导致手动离线复制流程不认识新 Agent——每类触点都有一份明确清单，逐项核对，不要只凭对上一个 Agent 集成的印象。

## 触点清单（缺一即失败）

新增 Agent（下称 `<agent>`，目录名用小写，PowerShell 参数用首字母大写）时，必须完成以下全部改动：

### 1. 集成文件 `integrations/<agent>/work-knowledge/`

- `SKILL.md`：frontmatter 含 `name: work-knowledge` 和带足中英触发词的 `description`（触发词命中率决定 Agent 何时调用技能）；正文含技能定位方式（读 `.managed-by-work-knowledge-template` 取 `knowledge_base`）、加载语义说明、路由表。
- `references/` 五文件：`ingest.md`（写入）、`query.md`（检索+概览）、`project.md`（项目）、`maintenance.md`（维护）、`update.md`（框架更新）。可以 `sed 's/旧Agent名/新Agent名/g'` 从现有 Agent 版本生成，但必须逐个 diff 检查。

### 2. 安装脚本 `scripts/install-<agent>-skill.ps1` 和 `.sh`

- 目标目录：`<AGENT>_HOME` 环境变量可覆盖，缺省 `~/.<agent>/skills/work-knowledge`。
- 先校验目标存在时必须含本模板 marker（`.managed-by-work-knowledge-template`），否则拒绝，防误删用户自建技能。
- 清空目标目录（保留 marker）→ 复制 → 写 marker（`manager=work-knowledge-template` + `knowledge_base=<绝对路径>`）。
- 结尾输出加载提示，注明该 Agent 的生效方式（见"加载语义"）。

### 3. 验证脚本 `scripts/verify.ps1` 和 `scripts/verify.sh`

- `required` 文件清单加入新 Agent 的全部集成文件和安装脚本。
- 新增 `-Agent <Agent>` 分支：校验已安装 Skill 存在、marker 路径与当前库一致、六个文件与仓库版本哈希/`cmp` 一致。
- **坑（已踩）**：verify.sh 用 `set -u`，`expected` 变量必须在所有 Agent 分支之前定义（曾放在 codex 分支内，单独跑其他 Agent 验证时报未定义变量）。
- 别忘了更新"旧的通用 skills 目录"报错信息里的 Agent 列表。

### 4. `scripts/setup.sh`（手动离线复制流程）

- Agent 参数列表加入 `<agent>`；安装逻辑保持"选谁只装谁，`both` 装全部"的排除式写法；usage 文案和收尾提示同步。**这是最容易漏的触点**（vBuddy 集成时即漏此处），因为主链路（BOOTSTRAP/UPDATE）不走这个脚本。

### 5. 文档层（五处）

- `AGENTS.md`：Agent 接入清单加新 Agent 名 + 加载语义。
- `README.md`：验证命令示例、加载语义说明。
- `AI/启动配置.md`：新增"〈Agent〉自接入"章节（含旧版降级行为）；"已有个人知识库的更新"框架路径清单加 `integrations/<agent>/`；开头的全局注册说明。
- `UPDATE.md`：第 2、6、7 步的 Agent 枚举和安装/验证脚本名。
- `AI/框架更新.md`：Skill 重装条目加新 Agent 及其生效提示。

### 6. 版本号 `.kb-version`

**任何改动一律 bump 版本号**，不犹豫、不攒批。commit message 按惯例：`feat: add <Agent> global skill integration` / `fix: cover <Agent> in ...`。

## 文件编码规范（Windows 上必踩，已实证）

- `.ps1`：UTF-8 **带 BOM** + CRLF。无 BOM 的中文 ps1 在 Windows PowerShell 5.1 下按 ANSI 解析必失败。用 Write/Edit 工具产出后需显式转换（读入→统一换行→带 BOM 写回）。
- `.sh`：UTF-8 无 BOM + LF。仓库 `.gitattributes` 已有 `*.sh text eol=lf`，提交前用 `git ls-files --eol` 核对 `i/lf`。
- 提交前用 `file` 命令逐一核对新文件。

## 加载语义（按 Agent 实测确认，别假设）

- 进程启动时加载一次：安装/更新后必须**重启进程**（如 BlueCode）。
- 每个会话启动时加载：安装/更新后**新开会话**即可，无需重启（如 vBuddy）。
- 把实际语义写进 SKILL.md、安装脚本输出和全部文档，保持一致。

## 验证协议（提交前必须全过）

1. 模板仓库框架检查：`verify.ps1 -Agent Framework` 和 `verify.sh --agent framework` 双通道通过。
2. 端到端：clone 模板到临时目录 → `.kb-role` 改 `personal` → 复制新改动过去 → 跑 `install-<agent>-skill.ps1` → 跑 `verify.ps1 -Agent <Agent>` 通过。
3. 负向隔离：跑 `verify.ps1 -Agent <其他Agent>` 应报"缺少 Skill"或"路径不匹配"，证明参数化没有糊弄。
4. setup.sh：用 `HOME`/`*_HOME` 指向沙盒假目录测 `<agent>` 参数只装新 Agent、非法参数被拒，测完删沙盒。
5. Agent 侧终验（新会话）：问"看下我的知识库"，确认出现 Skill 工具调用（这是技能通道生效的干净判别信号，排除了跨会话记忆的干扰）。

## 通用教训

- **新增枚举值后 grep 旧 Agent 名**：全仓库 `grep -rn "codex\|bluecode"`，凡是把 Agent 名写进参数列表/文案/报错的地方都是触点，逐一确认新 Agent 是否需要加入。
- git add 多路径时若任一路径不存在（如模板专属文件），整条命令静默失败——用 `git add -A` 或分批 add 后用 `git status --short` 复核。
- 集成文件的差异应仅是 Agent 名替换；diff 时出现任何超出名称替换的差异都要逐行解释。
