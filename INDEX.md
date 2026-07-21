# 📇 面试库总目录（可搜索索引）

> 用法：**Ctrl/Cmd + F 搜任意标题关键词**（如缓存击穿、分布式事务、接口慢、雪花算法），即可定位到所在文件。
> 本文件由 `gen-index.sh` 自动汇总所有文档标题（# 与 ##）。新增/改动文档后重跑该脚本刷新。

## 01 · 八股速答 Cheatsheet

### 📄 [01-cheatsheet/01-java-basics.md](01-cheatsheet/01-java-basics.md)
- **01 · Java 基础 速答（Java Basics）**
  - 🔥 高频必背（Top 22）
  - 📌 展开速答
  - ⚠️ 易错 / 反问加分

### 📄 [01-cheatsheet/02-collections.md](01-cheatsheet/02-collections.md)
- **02 · 集合 速答（Collections）**
  - 🔥 高频必背（Top 18）
  - 📌 展开速答
  - ⚠️ 易错 / 反问加分

### 📄 [01-cheatsheet/03-concurrency/01-threadlocal.md](01-cheatsheet/03-concurrency/01-threadlocal.md)
- **ThreadLocal 面试完全指南**
  - 一、是什么 & 解决什么问题
  - 二、核心 API（小步骤）
  - 三、底层原理（★ 核心：数据到底存在哪）
  - 四、ThreadLocalMap 细节
  - 五、★★ 内存泄漏问题（面试必考）
  - 六、为什么 key 要用弱引用？（高频追问）
  - 七、经典坑 & 最佳实践
  - 八、相关类对比
  - 九、应用场景
  - 🔗 关联

### 📄 [01-cheatsheet/03-concurrency/02-future.md](01-cheatsheet/03-concurrency/02-future.md)
- **Java Future 工作机制**
  - 一、为什么需要 Future？（解决什么）
  - 二、核心接口 / 类（小步骤）
  - 三、工作机制（★ 核心：FutureTask 原理）
  - 四、Future 的局限（★ 为什么要 CompletableFuture）
  - 五、CompletableFuture（JDK8 增强，实战主力）
  - 六、坑 & 最佳实践
  - 🔗 关联

### 📄 [01-cheatsheet/03-concurrency/03-lightweight-lock.md](01-cheatsheet/03-concurrency/03-lightweight-lock.md)
- **轻量级锁详细机制解析**
  - 一、前置：对象头 & Mark Word
  - 二、锁升级全景（定位轻量级锁）
  - 三、加锁机制（★ 核心，小步骤）
  - 四、解锁机制（小步骤）
  - 五、为什么用轻量级锁（设计动机）
  - 六、自旋 & 自适应自旋
  - 七、三种锁对比
  - 八、膨胀时机
  - 🔗 关联

### 📄 [01-cheatsheet/04-jvm.md](01-cheatsheet/04-jvm.md)
- **《深入拆解 Java 虚拟机》面试复习总结**
  - 一、面试高频考点速查表（按主题）
  - 二、必背核心结论（背这些应付大部分 JVM 八股）
  - 三、核心流程图解（10 张图看透最难懂的机制）
  - 四、逐讲精要（模块一：JVM 基本原理 01-12）
  - 01 | Java 代码是怎么运行的？
  - 02 | Java 的基本类型
  - 03 | JVM 是如何加载 Java 类的？
  - 04 | JVM 是如何执行方法调用的？（上）——重载/重写与静态/动态绑定
  - 05 | JVM 是如何执行方法调用的？（下）——虚方法表与内联缓存
  - 06 | JVM是如何处理异常的？
  - 07 | JVM是如何实现反射的？
  - 08 | JVM怎么实现invokedynamic（上）：方法句柄
  - 09 | JVM怎么实现invokedynamic（下）：调用点与Lambda
  - 10 | Java对象的内存布局
  - 11 | 垃圾回收（上）：可达性分析与回收算法
  - 12 | 垃圾回收（下）：分代、Minor GC、卡表与收集器
  - 五、逐讲精要（模块二：高效编译 13-23）
  - 13 | Java 内存模型（JMM）
  - 14 | JVM 如何实现 synchronized
  - 15 | Java 语法糖与 Java 编译器
  - 16 | 即时编译（上）：分层编译与触发
  - 17 | 即时编译（下）：Profiling、投机优化与去优化
  - 18 | 即时编译器的中间表达形式（IR）
  - 19 | Java字节码（基础篇）
  - 20 | 方法内联（上）
  - 21 | 方法内联（下）：去虚化
  - 22 | HotSpot虚拟机的intrinsic（内建函数）
  - 23 | 逃逸分析
  - 24 | 字段访问相关优化
  - 六、逐讲精要（模块三：代码优化 24-33 + 模块四：黑科技 34-36）
  - 25 | 循环优化
  - 26 | 向量化
  - 27 | 注解处理器
  - 28 | 基准测试框架 JMH（上）
  - 29 | 基准测试框架 JMH（下）
  - 30 | JVM 监控诊断工具（命令行篇）
  - 31 | JVM 监控诊断工具（GUI 篇）
  - 32 | JNI的运行机制
  - 33 | Java Agent与字节码注入
  - 34 | Graal：用Java编译Java
  - 35 | Truffle：语言实现框架
  - 36 | SubstrateVM：AOT编译框架
  - 附 | 常用工具介绍

### 📄 [01-cheatsheet/05-mysql.md](01-cheatsheet/05-mysql.md)
- **MySQL 面试复习总结（《实战45讲》原理 + 《必知必会》实操）**
  - 一、面试高频考点速查表（按主题）
  - 二、必背核心结论（背这些就够应付大部分八股）
  - 三、核心流程图解（10 张图看透最难懂的机制）
  - 四、逐讲精要（01-08 基础篇）
  - 01 | 基础架构：一条SQL查询语句是如何执行的？
  - 02 | 日志系统：一条SQL更新语句是如何执行的？
  - 03 | 事务隔离：为什么你改了我还看不见？
  - 04 | 深入浅出索引（上）
  - 05 | 深入浅出索引（下）
  - 06 | 全局锁和表锁
  - 07 | 行锁功过：减少行锁对性能的影响
  - 08 | 事务到底是隔离的还是不隔离的？
  - 五、逐讲精要（09-45 实践篇 + 答疑篇）
  - 09 | 普通索引 vs 唯一索引怎么选
  - 10 | MySQL 为什么有时候会选错索引
  - 11 | 怎么给字符串字段加索引
  - 12 | 为什么 MySQL 会"抖"一下（刷脏页）
  - 13 | 表数据删一半，文件大小为什么不变
  - 14 | count(*) 这么慢怎么办
  - 15 | 答疑（一）：日志和索引相关问题
  - 16 | order by 是怎么工作的？
  - 17 | 如何正确地显示随机消息？（order by rand() 的代价）
  - 18 | 逻辑相同性能却差异巨大（索引失效三典型）
  - 19 | 只查一行也很慢的原因
  - 20 | 幻读是什么，幻读有什么问题？
  - 21 | 只改一行却锁很多（加锁规则）
  - 22 | MySQL 有哪些"饮鸩止渴"提高性能的方法？
  - 23 | MySQL是怎么保证数据不丢的？
  - 24 | MySQL是怎么保证主备一致的？
  - 25 | MySQL是怎么保证高可用的？
  - 26 | 备库为什么会延迟好几个小时？
  - 27 | 主库出问题了，从库怎么办？
  - 28 | 读写分离有哪些坑？
  - 29 | 如何判断一个数据库是不是出问题了？
  - 30 | 答疑文章（二）：用动态的观点看加锁
  - 31 | 误删数据后除了跑路，还能怎么办？
  - 32 | 为什么还有 kill 不掉的语句？
  - 33 | 我查这么多数据，会不会把数据库内存打爆？
  - 34 | 到底可不可以使用 join？
  - 35 | join 语句怎么优化？
  - 36 | 为什么临时表可以重名？
  - 37 | 什么时候会使用内部临时表？
  - 38 | 都说 InnoDB 好，那还要不要使用 Memory 引擎？
  - 39 | 自增主键为什么不是连续的？
  - 40 | insert 语句的锁为什么这么多？
  - 41 | 怎么最快地复制一张表？
  - 42 | grant 之后要跟着 flush privileges 吗？
  - 43 | 要不要使用分区表？
  - 44 | 答疑文章（三）：说一说这些好问题
  - 45 | 自增 id 用完怎么办？
  - 六、SQL 实操与库设计（《MySQL必知必会》朱晓峰 补充）

### 📄 [01-cheatsheet/06-redis.md](01-cheatsheet/06-redis.md)
- **《Redis 源码剖析与实战》面试复习总结**
  - 一、面试高频考点速查表（按主题）
  - 二、必背核心结论（背这些应付大部分 Redis 八股）
  - 三、核心流程图解（10 张图看透最难懂的机制）
  - 四、逐讲精要（数据结构模块 01-07）
  - 01 | Redis 源码整体架构
  - 02 | 字符串实现：为什么用 SDS 而不是 char*
  - 03 | 如何实现性能优异的 Hash 表（dict）
  - 04 | 内存友好的数据结构设计
  - 05 | 有序集合 Sorted Set：为何同时支持点查与范围查
  - 06 | 从 ziplist 到 quicklist 再到 listpack
  - 07 | 为什么 Stream 使用 Radix Tree（基数树）
  - 五、逐讲精要（事件驱动与执行模型 08-14）
  - 08 | Redis server 启动流程
  - 09 | IO 多路复用：select / poll / epoll
  - 10 | 事件驱动框架（中）：Redis 是 Reactor 模型吗？
  - 11 | 事件驱动框架（下）：Redis 有哪些事件？
  - 12 | Redis 真的是单线程吗？
  - 13 | Redis 6.0 多 IO 线程
  - 14 | 从命令执行看分布式锁的原子性
  - 六、逐讲精要（缓存淘汰与持久化 15-20）
  - 15 | 近似 LRU 算法的实现
  - 16 | LFU 算法及其优势
  - 17 | LazyFree（惰性删除）对缓存淘汰的影响
  - 18 | RDB 文件的生成与格式
  - 19 | AOF 重写（上）：触发时机与影响
  - 20 | AOF 重写（下）：重写期间新写操作的记录
  - 七、逐讲精要（主从·哨兵·集群 21-28）
  - 21 | 主从复制：基于状态机的设计与实现
  - 22 | 哨兵 Sentinel 的初始化
  - 23 | 哨兵 Leader 选举与 Raft（上）
  - 24 | 哨兵 Leader 选举与 Raft（下）
  - 25 | Pub/Sub 在主从故障切换中的作用
  - 26 | Ping-Pong 消息与 Gossip 协议（Redis Cluster）
  - 27 | 从 MOVED、ASK 看集群节点如何处理命令
  - 28 | Redis Cluster 数据迁移会阻塞吗？
  - 八、逐讲精要（编程技巧模块 29-32）
  - 29 | 如何正确实现循环缓冲区
  - 30 | 如何在系统中实现延迟监控
  - 31 | 从 Module 的实现学习动态扩展功能
  - 32 | 如何在一个系统中实现单元测试
- **🎯 专题：Redis 如何避免内存耗尽？**
  - 步骤 1 · 设内存上限（maxmemory，第一道闸）
  - 步骤 2 · 选对内存淘汰策略（maxmemory-policy，★ 达上限后淘汰谁）
  - 步骤 3 · 过期删除（给 key 设 TTL，主动清理）
  - 步骤 4 · 省着用（数据结构 / 编码优化）
  - 步骤 5 · 防大 key + 内存碎片
  - 步骤 6 · 监控 + 扩容
- **📏 专题：存储 7000 万条数据，Redis 怎么预估内存占用？**
  - 一、预估方法论（大步骤）
  - 二、单条的隐藏开销（★ 以 String 为例）
  - 三、选对结构省一半（★ 关键）
  - 四、7000 万条实操估算（举例）
  - 五、怎么"预估"最靠谱（小步骤）
  - 六、顺带优化

### 📄 [01-cheatsheet/07-spring/01-ioc-startup.md](01-cheatsheet/07-spring/01-ioc-startup.md)
- **Spring IOC 容器启动流程**
  - 一、整体框架（两大阶段，先立骨架）
  - 二、核心入口 `refresh()` 的关键步骤（★ 大步骤）
  - 三、单个 Bean 的创建流程（★ 小步骤：第 11 步内部 `doCreateBean`）
  - 四、三级缓存与循环依赖（高频追问，简述）
  - 五、两种容器实现
  - 🔗 关联

### 📄 [01-cheatsheet/08-network.md](01-cheatsheet/08-network.md)
- **08 · 计算机网络 速答（Computer Network）**
  - 🔥 高频必背（Top 20）
  - 📌 展开速答
  - ⚠️ 易错 / 反问加分

### 📄 [01-cheatsheet/09-os.md](01-cheatsheet/09-os.md)
- **09 · 操作系统 速答（Operating System）**
  - 🔥 高频必背（Top 18）
  - 📌 展开速答
  - ⚠️ 易错 / 反问加分

### 📄 [01-cheatsheet/10-distributed/01-transaction.md](01-cheatsheet/10-distributed/01-transaction.md)
- **分布式事务解决方案**
  - 一、为什么需要分布式事务？
  - 二、两大流派（★ 先立分类框架）
  - 三、方案逐个梳理（每个方案 = 原理 + 优缺点 + 场景）
  - 四、横向对比选型
  - 五、怎么选型（决策口诀）
  - 📎 附：2PC 深挖（高频追问）
  - 🔗 关联

### 📄 [01-cheatsheet/10-distributed/02-consistency.md](01-cheatsheet/10-distributed/02-consistency.md)
- **分布式系统中的一致性**
  - 一、先厘清"一致性"的两种语境（★ 很多人混淆）
  - 二、一致性模型（从强到弱，大步骤）
  - 三、CAP 理论（必背）
  - 四、BASE 理论（AP 的落地思想，柔性）
  - 五、如何实现一致性（大步骤 → 小步骤）
  - 六、怎么选（决策）
  - 🔗 关联

### 📄 [01-cheatsheet/10-distributed/03-lock.md](01-cheatsheet/10-distributed/03-lock.md)
- **分布式锁 · Redis 锁的坑 · Redlock**
  - 一、分布式锁的基本要求（先立标准）
  - 二、单机 Redis 分布式锁怎么做（基础）
  - 三、Redis 实现分布式锁有哪些坑？（★ 逐个：坑 + 解决）
  - 四、Redlock 算法（★ 针对坑 #5：多实例多数派）
  - 五、Redlock 的争议（★ 加分：Martin vs antirez）
  - 六、对比：Redis 锁 vs Redlock vs ZooKeeper 锁
  - 🔗 关联

### 📄 [01-cheatsheet/11-troubleshooting.md](01-cheatsheet/11-troubleshooting.md)
- **11 · 线上问题排查 速答（Troubleshooting）**
- **🐢 线上接口响应很慢，一般是哪些问题导致的？**
  - 一、先建立分层链路框架（★ 分类框架，别一上来乱猜）
  - 二、逐层排查可能原因（大步骤 → 每层小步骤）
  - 三、排查工具（小步骤：按层选工具）
  - 四、排查方法论（编号步骤）
  - 五、高频根因 TOP + 对应优化
  - 📌 待补排查题（占位）

## 02 · 手撕代码 Coding

### 📄 [02-coding/01-singleton.md](02-coding/01-singleton.md)
- **01 · 手写单例（Singleton）**
  - 题目
  - 思路
  - 代码（Java）
  - 易错点 / 追问

### 📄 [02-coding/02-lru-cache.md](02-coding/02-lru-cache.md)
- **02 · LRU Cache（最近最少使用缓存）**
  - 题目
  - 思路
  - 方式一：基于 LinkedHashMap（最简，几行）
  - ★ 方式二：手写 HashMap + 双向链表（重点，能默写）
  - 易错点 / 追问

### 📄 [02-coding/03-thread-pool.md](02-coding/03-thread-pool.md)
- **03 · 手写线程池（Thread Pool）**
  - 题目
  - 思路
  - 代码（Java）
  - 对照 JDK：ThreadPoolExecutor 七大参数
  - 易错点 / 追问

### 📄 [02-coding/04-producer-consumer.md](02-coding/04-producer-consumer.md)
- **04 · 生产者消费者（Producer-Consumer）**
  - 题目
  - 思路
  - 代码（Java）
  - 易错点 / 追问

### 📄 [02-coding/05-blocking-queue.md](02-coding/05-blocking-queue.md)
- **05 · 手写阻塞队列（Blocking Queue）**
  - 题目
  - 思路
  - 代码（Java）
  - JDK 里的两种实现对比
  - 易错点 / 追问

### 📄 [02-coding/06-linkedlist.md](02-coding/06-linkedlist.md)
- **06 · 链表高频题（Linked List）**
  - ★ 反转链表（Reverse Linked List）—— 最高频
  - 判断链表有环（Linked List Cycle）+ 找环入口
  - 合并两个有序链表（Merge Two Sorted Lists）
  - K 个一组翻转链表（Reverse Nodes in k-Group）—— 较难 🔴
  - 找链表中点（Middle of the Linked List）
  - 相交链表（Intersection of Two Linked Lists）
  - 删除倒数第 N 个节点（Remove Nth Node From End）
  - 易错点 / 追问

### 📄 [02-coding/07-binary-tree.md](02-coding/07-binary-tree.md)
- **07 · 二叉树高频题（Binary Tree）**
  - 统一定义
  - 一、三种遍历（前序 / 中序 / 后序）
  - 二、层序遍历 BFS（★ 高频，按层输出）
  - 三、最大深度 / 最小深度（递归）
  - 四、翻转二叉树（递归）
  - 五、最近公共祖先 LCA（★ 重点，递归）
  - 六、判断平衡二叉树（自底向上 + 剪枝）
  - 七、对称二叉树（递归）
  - 八、验证二叉搜索树 BST（★ 两种法：上下界 / 中序）
  - 易错点 / 追问速查

### 📄 [02-coding/08-sort.md](02-coding/08-sort.md)
- **08 · 排序与 TopK（Sorting & TopK）**
  - 题目
  - 思路
  - ★ 快速排序（重点，能默写）
  - 归并排序（稳定，需 O(n) 空间）
  - 堆排序（原地，不稳定）
  - ★ TopK 问题（重点，高频）
  - 排序算法对照表
  - 易错点 / 追问

### 📄 [02-coding/09-hot-leetcode.md](02-coding/09-hot-leetcode.md)
- **09 · 高频 LeetCode 精选（Hot Problems）**
  - 📋 速览（考点归类）
  - 1. 两数之和（Two Sum）· 哈希
  - 2. ★ 无重复字符的最长子串（Longest Substring Without Repeating）· 滑动窗口
  - 3. 三数之和（3Sum）· 排序 + 双指针
  - 4. 接雨水（Trapping Rain Water）· 双指针 / 单调栈
  - 5. 最长回文子串（Longest Palindromic Substring）· 中心扩展
  - 6. 合并区间（Merge Intervals）· 排序 + 遍历
  - 7. 有效的括号（Valid Parentheses）· 栈
  - 8. 爬楼梯 / 斐波那契（Climbing Stairs）· DP 滚动变量
  - 9. 二分查找（Binary Search）· 二分模板
  - ✅ 复习检查清单

## 03 · 系统设计 System Design

### 📄 [03-system-design/01-short-url.md](03-system-design/01-short-url.md)
- **01 · 短链系统（Short URL）**
  - 一、需求澄清（先问清楚再动手）
  - 二、容量估算（Capacity Estimation）
  - 三、★ 核心：短码生成方案（重点对比）
  - 四、存储设计
  - 五、跳转流程（时序图）
  - 六、难点与权衡（面试深挖点）
  - 七、高并发设计（读多写少的重点）
  - 八、演进路线（Evolution）
  - 🔗 关联

### 📄 [03-system-design/02-seckill.md](03-system-design/02-seckill.md)
- **02 · 秒杀系统（Seckill / Flash Sale）**
  - 一、什么是秒杀？特点是什么？
  - 二、核心难点（先搞清"难在哪"）
  - 三、★ 分层削峰（重点：漏斗式层层过滤）
- **网关粗粒度限流示例（Nginx）**
  - 四、★ 防超卖（重点：多方案，面试必问）
  - 五、异步下单流程（Redis 扣成功 → MQ → 落库 → 通知）
  - 六、数据一致性（Redis 与 DB 最终一致）
  - 七、防刷 / 防作弊（防黄牛、防脚本）
  - 八、架构演进 / 优化
  - 九、整体架构图 + 下单时序图
  - 十、小结（面试一句话答法）
  - 🔗 关联

### 📄 [03-system-design/03-distributed-id.md](03-system-design/03-distributed-id.md)
- **03 · 分布式 ID 生成（雪花算法 Snowflake 为主）**
  - 一、为什么需要分布式 ID？（先讲背景与要求）
  - 二、雪花算法结构（★ 核心：64 位 long 的位拆分）
  - 三、生成流程（小步骤）
  - 四、优缺点
  - 五、时钟回拨问题（★ 高频追问）
  - 六、workerId 怎么分配？
  - 七、替代 / 对比方案
  - 🔗 关联

### 📄 [03-system-design/04-im-push.md](03-system-design/04-im-push.md)
- **04 · IM 即时通讯 / 消息推送（IM & Push）**
  - 一、需求澄清（先问清「做什么」）
  - 二、总体架构（分层）
  - 三、★ 长连接（重点：为什么、怎么保活、怎么找人）
  - 四、★ 消息流转（核心：一条消息怎么从 A 到 B）
  - 五、消息可靠性（不丢 / 不重 / 有序，面试高频）
  - 六、群聊：写扩散 vs 读扩散（推 vs 拉）
  - 七、在线状态与路由（水平扩展）
  - 八、存储设计
  - 九、推送（离线走第三方通道）
  - 十、难点与权衡（★ 加分项）
  - 十一、小结
  - 🔗 关联

### 📄 [03-system-design/05-rate-limiter.md](03-system-design/05-rate-limiter.md)
- **05 · 限流系统（Rate Limiter）**
  - 一、为什么要限流？
  - 二、★ 四种核心限流算法（重点）
  - 三、★ 单机限流 vs 分布式限流（重点）
- **Nginx 接入层限流：每 IP 10r/s，允许 burst 20（令牌桶思想）**
  - 四、限流维度
  - 五、超限了怎么处理？
  - 六、限流 vs 熔断 vs 降级（区别与配合）
  - 七、框架与技术选型
  - 八、面试速答模板
  - 🔗 关联

### 📄 [03-system-design/06-high-availability.md](03-system-design/06-high-availability.md)
- **06 · 服务高可用设计实现指南（High Availability）**
  - 一、什么是服务高可用？
  - 二、高可用的主要挑战（先搞清"难在哪"）
  - 三、高可用解决方案设计（★ 核心大步骤：分层解决，每层再拆小步骤）
  - 四、故障转移流程（Failover）
  - 五、架构示意图
  - 六、技术栈推荐
  - 七、高可用设计原则
  - 八、小结
  - 🔗 关联

### 📄 [03-system-design/07-high-concurrency.md](03-system-design/07-high-concurrency.md)
- **07 · 高并发系统的设计与解决方案（High Concurrency）**
  - 一、什么是高并发？
  - 二、高并发的主要挑战（先搞清"难在哪"）
  - 三、高并发解决方案设计（★ 核心大步骤：分层解决，每层再拆小步骤）
  - 四、架构示意图
  - 五、高并发实践优化建议
  - 六、技术栈推荐
  - 七、高并发系统设计原则
  - 八、小结
  - 🔗 关联

### 📄 [03-system-design/08-payment-safety.md](03-system-design/08-payment-safety.md)
- **08 · 调用三方支付，怎么防止错付 / 多付？**
  - 一、先分清两类问题（★ 分类框架）
  - 二、防「多付 / 重复扣款」（★ 核心 = 幂等）
  - 三、防「错付」（金额 / 对象 / 串单错误）
  - 四、支付结果怎么确认（★ 不能只信同步返回）
  - 五、超时 / 异常处理（★ 最容易多付的点）
  - 六、对账兜底（最终一致）
  - 七、退款同样要幂等
  - 🗺️ 一笔安全支付的链路
  - 🔗 关联

## 04 · 项目 & HR

### 📄 [04-project-hr/01-star-template.md](04-project-hr/01-star-template.md)
- **01 · STAR 项目话术模板（STAR Method）**
  - 🎯 一、STAR 是什么
  - ⭐ 二、一个完整 STAR 示例（订单系统性能优化）
  - 💡 三、如何把普通 CRUD 讲出技术含量
  - ⚠️ 四、常见坑（踩一个掉一档）
  - ✅ 五、准备清单（面试前必做）
  - 📝 六、一页话术骨架模板（套用填空）

### 📄 [04-project-hr/02-project-deep-dive.md](04-project-hr/02-project-deep-dive.md)
- **02 · 项目深挖高频问答（Project Deep Dive）**
  - 🎯 一句话心法
  - 🔥 高频深挖问题 · 速查表
  - 1️⃣ "你这个项目难点在哪？"
  - 2️⃣ "为什么这么设计 / 为什么选 X 不选 Y？"
  - 3️⃣ "遇到过什么线上问题？怎么排查的？"
  - 4️⃣ "你负责哪部分？"
  - 5️⃣ "QPS / 数据量多少？怎么扛的？"
  - 6️⃣ "如果流量涨 10 倍怎么办？"
  - 7️⃣ "项目还有什么可以优化的？"
  - ⚠️ 反例警示总集（深挖翻车四大死法）
  - ✅ 面试前准备清单（每个项目都过一遍）

### 📄 [04-project-hr/03-hr-questions.md](04-project-hr/03-hr-questions.md)
- **03 · 行为与 HR 高频题（Behavioral & HR）**
  - 🎯 三条铁律（先记这个）
  - 1. 为什么离职？（最高频，必被问）
  - 2. 你的优缺点？
  - 3. 你的职业规划？
  - 4. 期望薪资？（谈薪，别乱报）
  - 5. 你还有什么问题问我？
  - 6. 能接受加班吗？
  - 7. 为什么选我们公司？（考功课）
  - 8. 简短话术合集
  - 9. 压力面应对
  - ✅ 面试前检查清单

### 📄 [04-project-hr/04-reverse-questions.md](04-project-hr/04-reverse-questions.md)
- **04 · 反问面试官的加分问题（Reverse Questions）**
  - 🔥 为什么反问很重要
  - 📌 ★ 按面试轮次分类（重点）
  - ✅ 加分反问示例（体现上进 + 契合）
  - ⚠️ 别问的雷区
  - 🎬 收尾话术（表达兴趣 + 问流程）
  - 🧾 面前快速检查清单

