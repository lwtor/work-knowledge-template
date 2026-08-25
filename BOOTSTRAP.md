# Personal Work Knowledge Base Bootstrap

这是给全新 Agent 会话读取的自包含初始化协议。

## 本地路径规则

- 用户提供的路径统一解释为父目录。
- 最终知识库路径始终为 父目录/work-knowledge。
- 父目录可以非空，其中已有其他文件或项目不构成冲突。
- 路径字段仍是方括号占位说明、为空或仅包含示例文字：视为没有提供路径，绝不能把占位文字当作真实目录。
- 用户没有提供：只询问一次“知识库要保存到哪个本地父目录？”，然后暂停等待回答。
- 不得猜测磁盘或目录；用户回答后继续流程，初始化完成后不再询问。

## 固定来源

- 模板仓库：https://github.com/lwtor/work-knowledge-template
- 个人仓库默认名称：work-knowledge
- 默认可见性：private
- 本地路径没有通用默认值，必须来自用户当前指令或首次回答。

## Agent 必须执行

1. 读取模板的 README.md、AGENTS.md、AI/启动配置.md 和 AI/AI-GUIDE.md。检查用户当前指令是否提供本地父目录；缺失时只询问一次，得到回答后不得重复询问。
2. 使用 GitHub 连接器或已登录的 GitHub CLI；均不可用时只请求一次登录授权。
3. 获取当前 GitHub 用户名并检查 当前用户/work-knowledge：已存在则复用；不存在则从 lwtor/work-knowledge-template 生成名为 work-knowledge 的私有独立仓库。只有用户明确要求保留上游关系时才真正 fork。
4. 进入用户提供的父目录执行 clone，目标固定为 父目录/work-knowledge。目标不存在则 clone；已存在且 origin 相同则复用；只有该目标目录非空且不是目标知识库时才停止。不得检查或限制父目录中的其他内容，也不得覆盖未提交修改。
5. 确认 .kb-role 为 personal。新生成的个人仓库如果仍为 template，只修改 .kb-role，创建一次仅包含该文件的初始化提交并推送，使角色在以后 clone 时仍然正确；不得提交本地路径或个人资料。
6. 执行 scripts/install-codex-skill.sh。
7. 执行 scripts/verify.sh。
8. 报告仓库 URL、本地路径、可见性和验证结果。

## 授权与停止条件

要求按本协议创建或接入，即授权创建最多一个 work-knowledge 仓库、clone 到用户指定或首次确认的父目录下的 work-knowledge 子目录，并安装知识库 skill；除上述仅含 .kb-role 的初始化提交外，不授权上传其他文件、提交个人资料、删除内容或覆盖冲突目录。无法自动解决时停止，只给出一条最短操作说明。
