# Java 后端面试库（interview）

> 考前速刷 + 面试怎么答。深度原理在 `../jvm-learning`、`../java-learning` 等库，这里只做**面试速答、手撕、场景题**并链接回去。
> 规范见 [`_CONVENTIONS.md`](./_CONVENTIONS.md)。

> 🔎 **想按标题找内容？看总目录索引 → [`INDEX.md`](./INDEX.md)**（汇总所有文档标题，Ctrl+F 搜关键词即可定位）。

## 📚 模块总览

| 模块 | 定位 | 索引 |
|------|------|------|
| 01 八股速答 | 每领域一篇，考前速刷、能背出口 | [01-cheatsheet](./01-cheatsheet/README.md) |
| 02 手撕代码 | 高频算法 + 手写实现（单例/LRU/线程池…） | [02-coding](./02-coding/README.md) |
| 03 系统设计 | 场景/系统设计题（短链/秒杀/IM…） | [03-system-design](./03-system-design/README.md) |
| 04 项目与 HR | 项目深挖话术 + 行为/HR 面 | [04-project-hr](./04-project-hr/README.md) |
| 05 AI 应用 | 程序员视角 AI 面试（LLM/RAG/Agent/工程化） | [05-ai](./05-ai/README.md) |

## 🗺️ 覆盖清单（进度总表）

图例：✅ 已写 · ⬜ 待生成（按需生成，告诉我编号即可）

### 01 八股速答
- ⬜ 01 Java 基础
- ⬜ 02 集合（Collection）
- ⬜ 03 并发（Concurrency）
- ✅ 04 JVM
- ✅ 05 MySQL
- ✅ 06 Redis
- ⬜ 07 Spring / Spring Boot
- ⬜ 08 计算机网络
- ⬜ 09 操作系统
- ✅ 10 分布式 / 中间件（分布式事务/2PC、一致性/CAP/BASE…）
- ✅ 11 线上问题排查（接口慢；CPU/OOM/GC/死锁 待补）

### 02 手撕代码
- ⬜ 手写单例（懒汉/DCL/枚举）
- ⬜ LRU Cache
- ⬜ 手写线程池 / 生产者消费者
- ⬜ 手写阻塞队列
- ⬜ 高频算法（反转链表、两数之和、二叉树遍历、快排、TopK…）

### 03 系统设计
- ⬜ 短链系统
- ⬜ 秒杀 / 高并发扣减库存
- ⬜ 分布式 ID 生成
- ⬜ IM / 消息推送
- ✅ 06 服务高可用设计
- ✅ 07 高并发系统设计

### 04 项目与 HR
- ⬜ STAR 项目话术模板
- ⬜ 项目深挖高频问答
- ⬜ 行为 / HR 高频题（离职原因、职业规划、优缺点…）

### 05 AI 应用（程序员视角）
- ✅ 01 LLM 应用基础（Token/上下文窗口/温度/幻觉/流式/成本）
- ✅ 02 Prompt 工程（CoT/少样本/结构化输出/注入防护）
- ✅ 03 RAG 检索增强（分块/Embedding/检索/重排/评估）★重点
- ✅ 04 工具调用 & MCP（Function Calling/MCP 协议）
- ✅ 05 Agent 智能体（ReAct/编排模式/多智能体）
- ✅ 06 AI 工程化落地（框架选型/缓存限流/可观测/成本）
- ✅ 07 向量与向量库（Embedding/相似度/pgvector/HNSW）

## 🎯 建议复习路线

1. **打基础**：先过 `01-cheatsheet` 的 01→04（Java/集合/并发/JVM），这是 Java 后端必问核心。
2. **补存储**：05 MySQL、06 Redis —— 几乎必问。
3. **框架**：07 Spring。
4. **手撕**：并行刷 `02-coding`，面试现场高频。
5. **进阶**：08~10（网络/OS/分布式）+ `03-system-design`，冲中高级/大厂。
6. **收尾**：`04-project-hr` 打磨项目话术，面前一天过。

---

**用法**：想复习某块时，直接告诉我模块 + 编号（如「生成 01-cheatsheet 的 03 并发」），
我按 `_CONVENTIONS.md` 规范生成，并把上面清单对应项打勾 ✅。
