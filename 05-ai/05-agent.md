# 05 · Agent 智能体 速答（AI Agents）

> 面向 Java/后端程序员的 **Agent 智能体**：什么是 Agent、ReAct、Anthropic 五大编排模式、Workflow vs Agent、单/多智能体、为什么不稳、怎么兜底。覆盖 ~16 个高频问，全部「能背出口」。类比主线：**Agent ≈ 能自己写流程的编排引擎**。深度实现见 [`../../ai-learning/spring-ai-learning`](../../ai-learning/spring-ai-learning)（18-agents）、[`../../ai-learning/spring-ai-alibaba-learning`](../../ai-learning/spring-ai-alibaba-learning)（Graph 多智能体）。

## 🔥 高频必背（Top 14）

| # | 问题 | 一句话答 |
|---|---|---|
| 1 | 什么是 Agent（智能体）？ | 以 **LLM 为大脑**，能**自主规划→调工具→观察结果→多步迭代**直到完成目标，而不是一问一答。核心 = **LLM + 工具（Tools）+ 记忆（Memory）+ 规划循环（Loop）**。 |
| 2 | Agent 和普通 LLM 调用的区别？ | 普通调用是**单次问答**；Agent 是**多步自主循环**——自己决定下一步做什么、要不要再调工具、什么时候结束。类比：普通调用≈调一个函数，Agent≈一段会自己分支/循环的程序。 |
| 3 | ReAct 范式是什么？ | **Reasoning（想下一步）+ Acting（调工具）交替循环**：思考→行动→观察结果→再思考…直到得出答案。是 Agent 最经典的执行范式。 |
| 4 | Agent 的一次循环（Loop）长啥样？ | `LLM 决策 → 选工具 + 填参数 → 执行工具 → 观察返回 → 塞回上下文 → 再决策`，循环到"任务完成"或"触达上限"。 |
| 5 | Workflow 和 Agent 的区别？ | **Workflow=路径预定义**（代码写死步骤/DAG）；**Agent=LLM 自主决定路径**（动态选下一步）。类比：Workflow≈固定 DAG，Agent≈运行时动态决策。 |
| 6 | 什么时候用 Workflow，什么时候用 Agent？ | **能用 Workflow 就别用 Agent**：任务路径固定、可预测→Workflow（稳、便宜、好调试）；路径开放、步数不定、需临场应变→才上 Agent。 |
| 7 | 提示链 Prompt Chaining？ | 把任务**串行拆成固定几步**，前一步输出喂给后一步（可加校验 gate）。属 Workflow。类比：**责任链 / 流水线**。 |
| 8 | 路由 Routing？ | 先**分类**输入，再**分发**到不同的专用处理/模型。类比：**Nginx/网关按路由分流**、`switch-case`。 |
| 9 | 并行化 Parallelization？ | 把任务**拆成子任务并行跑**（Sectioning）或**多次投票取共识**（Voting），再聚合。类比：**MapReduce 的 Map + Reduce**、`CompletableFuture.allOf`。 |
| 10 | 编排者-执行者 Orchestrator-Workers？ | **主 Agent 动态拆任务**，派给多个子 Agent（Workers）执行，再汇总结果。子任务数**运行时才确定**。类比：**主从 / 线程池分发**。 |
| 11 | 评估-优化 Evaluator-Optimizer？ | **生成→评估→按反馈改进→再生成**循环，直到达标。类比：**带质检的重试循环 / PDCA**。 |
| 12 | 单 Agent vs 多 Agent（Multi-Agent）？ | 单 Agent 一个大脑串到底；多 Agent 是**多个专职 Agent 协作**（如规划者+执行者+审查者）。任务太复杂/需并行/需角色分工时才上多 Agent，否则单 Agent 更省更稳。 |
| 13 | Agent 为什么不稳、难落地生产？ | 多步自主决策 → **错误累积放大**、可能**无限循环**、**成本/延迟失控**（每步都调 LLM）、**不可预测**、难调试复现。 |
| 14 | 怎么兜底/驯服 Agent？ | **最大步数/迭代上限 + 超时**、每步**可观测 trace**、关键动作**人工确认（Human-in-the-loop）**、**限制工具权限**、失败回退、**成本预算上限**。类比：**防死循环熔断 + 限流 + 审批**。 |

## 📌 展开速答

**Q：把 Agent 讲清楚——它到底比 RAG/Function Calling 多了什么？**
多了**自主性和多步迭代**。RAG 是"检索→塞上下文→答一次"；Function Calling 是"模型决定调哪个工具、调一次"。Agent 则是**把工具调用放进一个循环里**：LLM 自己规划、调工具、看返回、判断没完成就继续调、直到目标达成。用后端话说，Function Calling 给了"调函数的能力"，Agent 是"一段会自己决定调用顺序、分支、循环的程序"。它靠工具**行动**（见 [`04-function-calling-mcp`](04-function-calling-mcp.md)），靠记忆**记住中间结果**。

**Q：Anthropic《Building Effective Agents》的五种编排模式怎么答？**
面试用一张表讲清楚，前四种属 **Workflow（路径预定义）**，最后要点是"能 Workflow 就别 Agent"：

| 模式 | 做什么 | 适用场景 / 后端类比 |
|------|--------|----------|
| **Prompt Chaining** 提示链 | 串行拆成固定几步，逐步传递（可加校验 gate） | 任务能清晰分解、每步可校验；≈责任链/流水线 |
| **Routing** 路由 | 先分类再分发到不同处理/模型 | 输入类型多样、各有专门处理；≈网关分流/`switch` |
| **Parallelization** 并行化 | 拆子任务并行（Sectioning）或多次投票（Voting） | 子任务独立可并行 / 需多视角投票提准；≈MapReduce |
| **Orchestrator-Workers** 编排者-执行者 | 主 Agent 动态拆任务派给子 Agent，再汇总 | 子任务**数量/内容运行时才知道**；≈主从/线程池 |
| **Evaluator-Optimizer** 评估-优化 | 生成→评估→按反馈改进的循环 | 有明确评价标准、迭代能提质；≈带质检的重试 |

前四种是**你写死编排、LLM 只填空**（可控）；只有当路径无法预先确定、需要 LLM 临场决定下一步时，才升级到真正的 **Agent（自主循环）**。

**Q：Workflow 和 Agent 到底怎么选？为什么强调"能用 Workflow 就别用 Agent"？**
核心是**可控性 vs 灵活性的权衡**。Workflow 路径写死，**可预测、便宜、好调试、延迟稳定**；Agent 每步都让 LLM 决策，**灵活但不稳、贵、慢、难复现**。工程铁律：先看任务路径是否固定——固定就用 Workflow（甚至五种编排模式里挑一个组合），只有面对**开放式、步数不定、需要临场应变**的任务（如"帮我把这个 bug 从定位到修复跑通"）才用 Agent。一句话：**别为了用 Agent 而用 Agent，复杂度要花在刀刃上**。

**Q：什么时候需要多 Agent（Multi-Agent）？怎么协作？**
当任务复杂到**单个 Agent 上下文塞不下 / 需要角色分工 / 可并行**时才上多 Agent。典型协作：**规划者拆任务 + 多个执行者并行干 + 审查者兜底质检**，本质就是 Orchestrator-Workers 的落地。Spring AI Alibaba 用 **Graph（图编排）** 描述多智能体：节点=Agent/工具，边=流转条件，天然表达分支/循环/并行。代价是**协调开销、成本翻倍、更难调试**，所以能单 Agent 解决就别拆。深度见 [`../../ai-learning/spring-ai-alibaba-learning`](../../ai-learning/spring-ai-alibaba-learning)。

**Q：Agent 为什么在生产环境不稳？举具体的坑。**
根因是**多步自主决策会放大不确定性**：①**错误累积**——第 1 步选错工具，后面全跑偏，越滚越远；②**无限循环**——反复调同一工具或来回横跳出不来；③**成本/延迟失控**——每步都调一次 LLM，10 步就是 10 次调用，token 和耗时线性甚至爆炸增长；④**不可预测 + 难复现**——同样输入两次跑出不同路径，线上出问题难还原。这就是为什么"demo 惊艳、上线拉胯"。

**Q：怎么驯服 Agent、让它能上生产？（这题最能体现工程能力）**
分层兜底，全套答出来加分：①**熔断**——设最大步数/迭代上限 + 单步与整体超时（防死循环，≈限流熔断）；②**可观测**——每步的思考/工具/参数/返回都打 trace（LangSmith/Langfuse），能回放调试（见 [`06-ai-engineering`](06-ai-engineering.md)）；③**人工确认（Human-in-the-loop）**——写库、发消息、花钱等高危动作先让人审批；④**最小权限**——严格限制可调工具和其权限范围；⑤**成本预算上限**——超 token/费用阈值就中断；⑥**失败回退**——工具失败有降级/兜底话术，不硬撑。把这套讲出来，就是"做过真实 Agent 项目"的信号。

**Q：Agent 典型落地场景有哪些？**
**多步、需串联多个工具、路径不完全固定**的任务：复杂任务自动化（客服自动处理工单：查订单→查物流→退款）、多步查询与研究（Deep Research：反复检索→归纳→再检索）、**Agentic RAG**（Agent 自主决定要不要检索、检索几次、换什么 query，比一次性 RAG 更强，见 [`03-rag`](03-rag.md)）、代码/运维 Agent（定位→改→验证）。判据不变：**步骤固定的别硬做成 Agent**。

## ⚠️ 易错 / 反问加分

- ⚠️ **别把"调了一次工具"当 Agent**——单次 Function Calling 不是 Agent，**自主多步循环**才是。答错这条暴露没搞懂本质。
- ⚠️ **别张口就上多 Agent/复杂 Agent**——面试官爱听"我先评估能不能用 Workflow 解决"，盲目上 Agent 反而显得不懂工程取舍。
- ⚠️ **别忽略成本和循环风险**——被问"Agent 上线要注意什么"只答功能不答**步数上限/成本/可观测/人工确认**，直接掉档。
- ✅ **加分**：把编排模式映射回后端熟词——Routing≈网关分流、Parallelization≈MapReduce、Orchestrator-Workers≈主从/线程池、Evaluator-Optimizer≈带质检的重试、最大步数≈防死循环熔断。
- ✅ **加分**：主动引 Anthropic《Building Effective Agents》的观点——"**从简单的可组合模式（Workflow）起步，只在必要时才加 Agent 的自主性**"，显示读过一手资料。
- ✅ **加分**：谈任何 Agent 能力都带一句治理（不稳→trace 可观测、会飞→步数上限、危险动作→Human-in-the-loop、贵→预算上限），把"会写 Agent"升级成"敢上生产的 Agent"。
- 🔗 Agent 靠工具行动 → [`04-function-calling-mcp`](04-function-calling-mcp.md)；可观测/成本/兜底工程化 → [`06-ai-engineering`](06-ai-engineering.md)；Agentic RAG → [`03-rag`](03-rag.md)。
