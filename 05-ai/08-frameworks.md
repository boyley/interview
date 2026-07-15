# 08 · AI 框架选型面试（Spring AI / Alibaba / LangChain4j）

> Java 后端做 AI 应用绕不开的三大框架：**Spring AI**（Spring 官方标准框架）、**Spring AI Alibaba**（阿里在其上加的 Agentic 框架）、**LangChain4j**（对标 Python LangChain 的独立 Java 库）。本篇讲三者定位、设计哲学、核心 API 差异、选型怎么答。深度对照见 [`../../ai-learning`](../../ai-learning) 的两份对比文档。

## 🔥 高频必背（Top 14）

| # | 问题 | 一句话答 |
|---|---|---|
| 1 | 三个框架一句话定位？ | **Spring AI**=Spring 官方的 AI 应用标准框架（地基）；**Spring AI Alibaba**=构建在 Spring AI 之上、加了 DashScope + Graph 多智能体的增强框架；**LangChain4j**=框架无关的独立 Java 库，招牌是声明式 `@AiService`。 |
| 2 | Spring AI 和 Spring AI Alibaba 是竞争关系吗？ | **不是，是上下层关系**。Alibaba 依赖并复用 Spring AI，`ChatClient/Advisor/@Tool/VectorStore` 写法一模一样；类比 **JDBC 与 MyBatis-Plus**。 |
| 3 | Spring AI 的核心入口？ | **`ChatClient`** 链式调用：`chatClient.prompt().user(q).call().content()`。 |
| 4 | LangChain4j 的招牌特性？ | **声明式 `@AiService` 接口**——一个业务接口 = 一个 AI 功能，记忆/工具/RAG 都往接口上挂。 |
| 5 | 两者获取模型的方式差异？ | Spring AI **自动配置**（引 starter + 配 yml，自动注入 `ChatClient.Builder`）；LangChain4j **手动 builder**（`OpenAiChatModel.builder()....build()`，参数显式）。 |
| 6 | Spring AI 的扩展机制是什么？ | **Advisor 拦截器链**——记忆、RAG、日志都是 Advisor（≈Spring 的拦截器/AOP）。 |
| 7 | Spring AI Alibaba 独有、Spring AI 没有的杀手锏？ | **Graph 多智能体编排**（节点/边/全局状态/并行/条件/人类介入），可理解为 **Java 版 LangGraph**。 |
| 8 | 为什么国内项目常选 Spring AI Alibaba？ | **DashScope（通义千问/百炼）国内直连**，一个 Key 打通对话/视觉/文生图/语音/向量全部能力，不用科学上网。 |
| 9 | LangChain4j 怎么做结构化输出？ | AiServices 接口方法**直接声明返回 POJO/enum**，框架据返回类型生成 JSON Schema；Spring AI 则在调用链末尾 `.entity(Movie.class)`。 |
| 10 | 对话记忆怎么挂？ | Spring AI 用 **Advisor**（`MessageChatMemoryAdvisor`）；LangChain4j 用 **装配项**（`AiServices.builder().chatMemory(...)`）。 |
| 11 | RAG 怎么接？ | Spring AI 挂 **`QuestionAnswerAdvisor`**（回答前自动检索）；LangChain4j 装 **`ContentRetriever`** 到接口上。 |
| 12 | 三者都支持 MCP 吗？ | 都支持，客户端+服务端都有。Spring AI 工具以 `ToolCallbackProvider` 注入 ChatClient；LangChain4j 以 `McpToolProvider` 装到 AiServices。 |
| 13 | 选型一句话？ | **Spring 全家桶/企业级监控 → Spring AI**；**通义千问/国内直连/多智能体 → Spring AI Alibaba**；**非 Spring 项目/要最简声明式 → LangChain4j**。 |
| 14 | 三者底层模型层通用吗？ | Spring AI 与 Alibaba 上层 API 完全通用（只换底层模型/依赖/配置 key）；LangChain4j 是另一套 API，但概念（对话/记忆/工具/RAG）一一对应。 |

## 🧭 三框架定位对照（一张表看懂）

| 维度 | Spring AI | Spring AI Alibaba | LangChain4j |
|---|---|---|---|
| 出品方 | Spring 官方（VMware/Broadcom） | 阿里巴巴 | 社区（对标 Python LangChain） |
| 定位 | AI 应用**标准框架**（地基） | **Agentic** 框架（盖在 Spring AI 上） | 框架无关的独立 Java 库 |
| 类比 | JDBC（规范） | MyBatis-Plus（规范上增强） | 一个第三方 ORM 库 |
| 核心入口 | `ChatClient` 链式 | 同 `ChatClient`（就是 Spring AI 的） | `ChatModel` + `@AiService` 声明式 |
| 模型装配 | 自动配置（yml） | 自动配置（DashScope 优先） | 手动 builder（参数透明） |
| 扩展机制 | **Advisor** 拦截器链 | 同 + **Graph** 编排 | AiServices **装配项** |
| 默认模型 | OpenAI/Anthropic/Ollama… | **DashScope/通义千问** 国内直连 | 任意（builder 指定） |
| 多智能体编排 | ❌ 无内置 | ✅ **Graph（杀手锏）** | 用 AiServices+Tool 手拼 |
| 可观测 | Micrometer + Actuator | 同 + 阿里云 ARMS | `ChatModelListener` 监听器 |
| 招牌 | Spring 生态无缝、Advisor | Graph 多智能体 + 国产模型一站式 | `@AiService` 极简声明式 |

> 记忆口诀：**Spring AI 是地基，Alibaba 在地基上加了"国产模型 + Graph 多智能体"，LangChain4j 是另起炉灶但更轻更声明式。**

## 📌 展开速答

**Q：Spring AI 和 LangChain4j 的设计哲学差在哪？**
一句话：**Spring AI = "Spring 自动配置 + ChatClient 链式 + Advisor 拦截器"；LangChain4j = "手动 builder + 声明式 @AiService 接口 + 装配项"。** Spring AI 深度绑定 Spring 生态、模型靠自动配置注入、扩展全走 Advisor（记忆/RAG/日志都是拦截器），企业监控用 Actuator 无缝接上；LangChain4j 是纯 Java 库可独立用，招牌是 `@AiService` 声明式接口——声明一个接口 + `@SystemMessage/@UserMessage/@V` 注解，`AiServices.create()` 一装配就有了一个带记忆/工具/RAG 的 AI 功能，builder 参数全透明可控。用后端话讲：**Spring AI 像 Spring Data（自动配置、约定优于配置），LangChain4j 像 MyBatis（接口 + 注解、显式可控）。**

**Q：Spring AI Alibaba 到底"扩展"了什么？值不值得用？**
它没重写对话/RAG/工具（这些直接用 Spring AI 的），真正加的是 5 块：①**DashScope 原生模型**（一个百炼 Key 给齐 qwen 对话/视觉 + wanx 文生图 + cosyvoice TTS + paraformer ASR + text-embedding）；②**Graph 多智能体编排**（Java 版 LangGraph，纯 Spring AI 没有——最大护城河）；③**现成 Agent**（`ReactAgent`、A2A 多智能体协作）；④**企业中间件**（Nacos 动态 Prompt 不重启改提示词、ARMS 观测、AnalyticDB/Tair 等云向量库、几十种文档读取器）；⑤**平台产品**（JManus、DeepResearch、NL2SQL/ChatBI、Studio）。**关键认知：用 Alibaba ≠ 放弃 Spring AI**，上层 `ChatClient/Advisor/@Tool` 代码可直接搬，真正绑定的只有 Graph 那层——而那层恰是纯 Spring AI 给不了的。

**Q：三者做 RAG 分别怎么落地？**
都是"对话模型回答、向量模型只负责检索"，差在装配方式：**Spring AI** → ETL 用 `TextReader`→`TokenTextSplitter`→`vectorStore.add()`，检索挂 `QuestionAnswerAdvisor` 到 ChatClient（回答前自动检索拼 Prompt）；**LangChain4j** → `Document/TextSegment`→`embed`→`store.add()`，检索用 `EmbeddingStoreContentRetriever` 装到 `AiServices.builder().contentRetriever(...)`；**Alibaba** → 写法同 Spring AI，只是向量库可换成 AnalyticDB/Tair 等阿里云实现。核心区别一句话：**Spring AI 的 RAG 是"一个 Advisor 挂上去"，LangChain4j 的 RAG 是"一个 ContentRetriever 装进接口"。**

**Q：工具调用（Function Calling）三者写法差异？**
本质相同（方法加注解声明工具），差在注解包和注册位置：**Spring AI** 用 `@Tool(description=...)` + `@ToolParam`，`.tools(new XxxTools())` 注册到 ChatClient；**LangChain4j** 用 `@Tool("描述")` + `@P("描述")`，`AiServices.builder().tools(xxx)` 装到接口；**Alibaba** 同 Spring AI，另带一堆社区现成工具（百度/高德/必应搜索等开箱即用的 `@Tool`）。详见 [`04-function-calling-mcp`](04-function-calling-mcp.md)。

**Q：Spring AI Alibaba 接入有什么坑？**
最容易翻车的是 **BOM**：从 1.1.2.x 起 `spring-ai-alibaba-bom` 变"瘦"了，只管 `graph-core` 等少数坐标，**不再收录 `starter-dashscope` 等、也不帮你导入 `spring-ai-bom`**。正确姿势是父 pom **同时导入两个 BOM**（`spring-ai-bom` + `spring-ai-alibaba-bom`），并给漏掉的阿里 starter 显式写版本号。版本对应：Alibaba `1.1.2.3` 前三位跟 Spring AI 1.1，末位是阿里迭代号，与 `spring-ai 1.1.7`、`Spring Boot 3.5.4` 共存。

**Q：面试官问"你选了哪个框架、为什么"，怎么答加分？**
别只报名字，按**场景 + trade-off** 答：①"项目是 Spring Boot 全家桶、要复用 Actuator 监控 → 选 **Spring AI**，Advisor 机制和 Spring 拦截器一个思路，团队上手快"；②"要用**通义千问、国内直连**、还要文生图/语音一站式 → **Spring AI Alibaba**，一个 Key 搞定，且上层 API 就是 Spring AI，将来换回成本极低"；③"如果要**多智能体/复杂工作流/人类介入** → Alibaba 的 **Graph** 是唯一现成选择"；④"非 Spring 的轻量项目、想要最简声明式 → **LangChain4j** 的 `@AiService`"。能说出"两头下注就用 Alibaba，因为学的 Spring AI 技能完全通用"体现你想过演进成本。

## ⚠️ 易错 / 反问加分

- ⚠️ **别把 Spring AI 和 Spring AI Alibaba 说成竞品**——是上下层依赖关系（JDBC vs MyBatis-Plus），Alibaba 复用 Spring AI 的全部核心抽象。
- ⚠️ **别说"LangChain4j 是 Python LangChain 的移植"**——它是**对标**（同类定位）的独立 Java 实现，API 是 Java 风格的，不是照搬。
- ⚠️ **Graph 是 Alibaba 独有**——被问"Spring 生态怎么做多智能体编排"，答案是 Spring AI Alibaba 的 Graph，纯 Spring AI 目前只有基础 Agent 样例、无图引擎。
- ✅ **加分**：把框架机制映射回后端熟词——Advisor≈拦截器/AOP、自动配置≈Spring Boot Starter 约定、`@AiService`≈MyBatis Mapper 接口、Graph≈工作流引擎/状态机、BOM≈依赖版本统一管理。
- ✅ **加分**：强调"**上层业务代码框架无关**"——对话/RAG/工具的写法在 Spring AI 与 Alibaba 间可直接搬，选型主要绑定的是"模型来源 + 编排能力"，体现你分得清"业务逻辑"与"基础设施"。
- ✅ **加分**：提一句 **Nacos 动态 Prompt**（不重启改提示词）——这是 Alibaba 很实用的企业特性，能答出来显得关注生产运维。
- 🔗 各能力的通用原理 → [`03-rag`](03-rag.md)、[`04-function-calling-mcp`](04-function-calling-mcp.md)、[`05-agent`](05-agent.md)；工程化落地（可观测/成本）→ [`06-ai-engineering`](06-ai-engineering.md)。
