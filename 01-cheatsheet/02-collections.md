# 02 · 集合 速答（Collections）

> 面向 Java 后端的集合框架**面试速答**：体系、ArrayList/LinkedList、**HashMap（重点）**、ConcurrentHashMap、Set/Map 三兄弟、fail-fast、并发容器。覆盖 ~22 个高频问，全部「能背出口」。深度原理见 [`../../java-learning/04-collections`](../../java-learning/04-collections)。

## 🔥 高频必背（Top 18）

| # | 问题 | 一句话答 |
|---|---|---|
| 1 | 集合两大体系？ | **Collection**（单值）+ **Map**（键值对）。Collection 下三支：**List**（有序可重复）、**Set**（不可重复）、**Queue**（队列）。详见 [体系总览](../../java-learning/04-collections/01-collection-overview.md)。 |
| 2 | ArrayList vs LinkedList？ | ArrayList=**动态数组**，随机访问 O(1)、尾插均摊 O(1)、中间增删 O(n)；LinkedList=**双向链表**，头尾增删 O(1)、随机访问 O(n)。实战几乎都用 ArrayList。 |
| 3 | ArrayList 扩容机制？ | 默认容量 **10**（首次 add 才真正分配）；满了扩容为 **1.5 倍**（`oldCap + (oldCap>>1)`），`Arrays.copyOf` 拷贝到新数组。 |
| 4 | LinkedList 能当栈/队列吗？ | 能，它实现了 `Deque`，`addFirst/addLast/pollFirst/pollLast` 都是 O(1)，可做栈、队列、双端队列。 |
| 5 | **HashMap 底层结构？** | JDK8 = **数组 + 链表 + 红黑树**。链表长度 ≥ **8** 且数组长度 ≥ **64** 转红黑树；红黑树节点 ≤ **6** 退化回链表。 |
| 6 | HashMap 默认容量 / 负载因子？ | 容量 **16**（`1<<4`），负载因子 **0.75**，阈值 threshold = 容量×0.75 = 12，超过就扩容为 **2 倍**。 |
| 7 | 为什么容量是 2 的幂？ | 让 `hash & (n-1)` 等价于取模且更快；且 `n-1` 低位全 1，散列均匀。即使传奇数初始容量，也会向上取最近 2 的幂。 |
| 8 | 什么是扰动函数？ | `(h = key.hashCode()) ^ (h >>> 16)`，把 **高 16 位异或到低 16 位**，让高位也参与索引计算，减少哈希冲突。 |
| 9 | **HashMap 线程安全吗？** | **不安全**。JDK7 并发扩容头插法会成**环形链表→死循环**；JDK8 改尾插消除死循环，但并发 put 仍会**数据覆盖/丢失**。 |
| 10 | HashMap JDK7 vs JDK8？ | 7=数组+链表、**头插**、先扩容再插入；8=数组+链表+**红黑树**、**尾插**、先插入再判断扩容。详见 [7 vs 8](../../java-learning/04-collections/06-hashmap-jdk7-vs-jdk8.md)。 |
| 11 | HashMap / Hashtable / ConcurrentHashMap？ | HashMap 不安全、允许 null 键值；Hashtable **全表 synchronized**（已淘汰）、不许 null；ConcurrentHashMap **高并发首选**、不许 null。 |
| 12 | **ConcurrentHashMap 怎么保证线程安全？** | JDK7=**分段锁 Segment**（16 段各一把锁）；JDK8=**CAS + synchronized 锁单个桶头节点** + 红黑树，锁粒度更细。 |
| 13 | HashSet / LinkedHashSet / TreeSet？ | HashSet 无序（底层 HashMap）；LinkedHashSet 按**插入顺序**；TreeSet 按**排序**（底层红黑树，O(log n)）。 |
| 14 | HashMap / LinkedHashMap / TreeMap？ | HashMap 无序；LinkedHashMap 保留**插入/访问顺序**（可做 LRU）；TreeMap 按 **key 排序**（红黑树）。 |
| 15 | HashSet 怎么去重？ | 内部就是 HashMap，元素当 key、value 是固定 `PRESENT`。去重靠 **hashCode() + equals()**。 |
| 16 | fail-fast vs fail-safe？ | fail-fast：遍历中被改抛 `ConcurrentModificationException`（靠 **modCount** 检测）；fail-safe：遍历副本不抛（如 CopyOnWrite、ConcurrentHashMap）。 |
| 17 | 遍历时删除元素怎么做？ | 用 **Iterator.remove()**（会同步 modCount），别用 `for-each` 里直接 `list.remove()`，否则 fail-fast 抛异常。 |
| 18 | HashMap 的 key 为什么常用 String/Integer？ | 它们**不可变（immutable）**且重写了 `hashCode/equals`，哈希值稳定，不会因对象被改而找不到桶。 |

## 📌 展开速答

**Q：ArrayList vs LinkedList 到底怎么选？（增删查对比）**
| 操作 | ArrayList（数组） | LinkedList（双向链表） |
|---|---|---|
| 随机访问 get(i) | **O(1)** ✅ | O(n) 要遍历 |
| 尾部增删 | 均摊 O(1) | O(1) |
| 头/中间增删 | O(n) 要挪元素 | 定位 O(n) + 增删 O(1) |
| 内存 | 连续、省（预留空位） | 每节点多存**前后指针**，占用大 |
一句话：**绝大多数场景选 ArrayList**（CPU 缓存友好、随机访问快）；只有频繁在头部增删且不随机访问才考虑 LinkedList，但实际用 `ArrayDeque` 往往更好。详见 [对比](../../java-learning/04-collections/04-arraylist-vs-linkedlist.md)。

**Q：★ HashMap 的 put 流程？（重点，能画出来最好）**
1. 对 key 算 hash：`(h=key.hashCode()) ^ (h>>>16)`（扰动，高位混入低位）。
2. `i = (n-1) & hash` 定位桶下标。
3. 桶为空 → 直接放新节点。
4. 桶非空 → 比较：key 相同（hash 相等且 `equals` 为真）则**覆盖 value**。
5. 否则是链表就**尾插**（8 尾插）；链表长度 ≥ 8 且表长 ≥ 64 → **树化**成红黑树；已是红黑树则按树插入。
6. 插入后 `++size > threshold` → **扩容 2 倍**（`resize()`）。
```
key ──hashCode──▶ h ──扰动 h^(h>>>16)──▶ hash ──& (n-1)──▶ 桶下标 i
                                                     │
              ┌──────────────────────────────────────┤
           桶空？直接放           桶非空：equals 命中→覆盖
                                 未命中→尾插链表(≥8&表≥64 转红黑树)
```
底层细节详见 [HashMap 源码](../../java-learning/04-collections/05-hashmap.md)。

**Q：★ 为什么 HashMap 线程不安全？（两个经典场景）**
- **JDK7 死循环**：并发 `resize()` 时用**头插法**转移节点，两个线程交叉迁移会让链表指针形成**环（A→B→A）**，后续 `get` 命中该桶时**死循环 100% CPU**。
- **JDK8 数据覆盖**：改成尾插消除了死循环，但 put 命中同一空桶时，线程 A、B 都判断桶为空各自写入，**后者覆盖前者**，丢数据；`++size` 非原子也会导致 size 不准。
结论：多线程用 **ConcurrentHashMap**，别用 `HashMap` 或过时的 `Collections.synchronizedMap`。

**Q：★ ConcurrentHashMap 1.7 分段锁 vs 1.8 CAS+synchronized？**
| | JDK7 | JDK8 |
|---|---|---|
| 结构 | Segment[] + HashEntry[]，**分段锁** | Node[] + 链表/红黑树（同 HashMap） |
| 锁 | 每个 Segment 一把 `ReentrantLock`，默认 16 段 → **最多 16 线程并发** | **CAS**（桶空时无锁写）+ **synchronized 锁桶头节点** |
| 并发度 | 受 Segment 数限制 | 锁粒度 = 单个桶，**并发度更高** |
| 计数 | 分段 size 累加 | `baseCount` + `CounterCell[]` 分散计数减竞争 |
put 流程（1.8）：桶空→**CAS 写入**（失败自旋）；桶非空→**synchronized 锁头节点**再插链表/树；扩容时多线程可**协助迁移**（`transfer`）。为什么放弃分段锁？因为 8 的分段锁粒度太粗、内存开销大，桶级锁更细更省。详见 [ConcurrentHashMap](../../java-learning/04-collections/07-concurrenthashmap.md)。

**Q：CopyOnWriteArrayList 原理？适用场景？**
**写时复制**：写操作（add/set/remove）时 `ReentrantLock` 加锁，**复制一份新数组**改完再把引用指回去；读**完全无锁**读旧数组。适合**读多写极少**（如白名单、监听器列表）。缺点：写内存翻倍、读到的是**旧快照**（弱一致），不适合频繁写。它也是 fail-safe（遍历的是快照，不抛 CME）。

**Q：BlockingQueue 是什么？（一句带过）**
支持**阻塞**的队列：队满时 put 阻塞、队空时 take 阻塞，是**生产者-消费者 / 线程池**的核心。常见 `ArrayBlockingQueue`（有界数组）、`LinkedBlockingQueue`（可选有界链表）、`SynchronousQueue`（不存元素直接交接）。

**Q：fail-fast 到底怎么检测的？**
集合内部维护 `modCount`（结构性修改次数），创建 Iterator 时记下 `expectedModCount = modCount`；每次 `next()` 校验两者是否相等，不等就抛 `ConcurrentModificationException`。它是**一种错误检测机制而非并发保证**——单线程里用 for-each 删元素也会触发。想安全删用 `Iterator.remove()`；并发遍历用 fail-safe 容器。详见 [fail-fast/safe](../../java-learning/04-collections/10-fail-fast-fail-safe.md)。

## ⚠️ 易错 / 反问加分

- ⚠️ **树化不是「链表到 8 就一定变树」**——还要求**数组长度 ≥ 64**，否则只是**扩容**而非树化。只背 8 会被追问打穿。
- ⚠️ **负载因子 0.75 别答成 0.75 是「链表长度」**——它是「元素数 / 容量」的阈值比例，是空间与冲突的折中。
- ⚠️ **HashMap 允许 1 个 null key、多个 null value**；Hashtable 和 ConcurrentHashMap **都不允许 null**（并发下 null 无法区分「不存在」和「值为 null」）。
- ⚠️ **JDK7 死循环 / JDK8 数据覆盖别记反**：环形链表是 7 的头插问题，8 已修复但仍有覆盖丢数据。
- ✅ **加分**：被问 HashMap 线程安全，主动补「ConcurrentHashMap 1.8 用 CAS+synchronized 锁桶头、放弃分段锁」，显示看过源码。
- ✅ **加分**：用不可变对象做 key 的理由说透——「可变对象改了字段后 hashCode 变，会定位到别的桶导致取不出来 / 内存泄漏」。
- ✅ **加分**：LinkedHashMap 重写 `removeEldestEntry` + 访问顺序模式可**手写 LRU**，关联 [`../02-coding`](../02-coding) 手撕题。
- 🔗 排序相关（Comparable vs Comparator）→ [comparable-comparator](../../java-learning/04-collections/11-comparable-comparator.md)；TreeMap/TreeSet 红黑树 → [treemap-treeset](../../java-learning/04-collections/09-treemap-treeset.md)。
