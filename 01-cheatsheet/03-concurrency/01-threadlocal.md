# ThreadLocal 面试完全指南

> **核心理念：ThreadLocal = 线程本地变量，每个线程持有自己独立的副本，用「线程隔离」代替「线程同步」—— 不是解决共享，而是干脆不共享。**
> 答题方法：是什么 → 底层原理(数据存哪) → ★内存泄漏 → 为什么 key 用弱引用 → 坑与最佳实践 → 相关类对比。

---

## 一、是什么 & 解决什么问题

- **每个线程独有一份变量副本**，线程间互不干扰。
- **本质是"线程隔离"，不是"线程同步"**：

| | synchronized | ThreadLocal |
|---|---|---|
| 思路 | 排队共享同一个变量 | 每线程各用各的副本 |
| 取舍 | 时间换空间 | **空间换时间** |

- **典型用途**：每线程独享工具（`SimpleDateFormat` 线程不安全）、**跨方法传上下文**（Spring 事务的 DB 连接、`SecurityContextHolder`、日志 MDC 的 traceId）。

---

## 二、核心 API（小步骤）

| 方法 | 作用 |
|---|---|
| `set(T)` | 存当前线程的值 |
| `get()` | 取当前线程的值 |
| `remove()` | 删当前线程的值（★ 用完必须调） |
| `withInitial(Supplier)` / `initialValue()` | 设默认值 |

---

## 三、底层原理（★ 核心：数据到底存在哪）

**数据不存在 ThreadLocal 上，而是存在「线程」上。**

- 每个 `Thread` 对象里有个字段 `ThreadLocal.ThreadLocalMap threadLocals`
- `ThreadLocalMap` 的 **key = ThreadLocal 对象本身，value = 你存的值**
- `set(v)`：拿到**当前线程**的 `threadLocals`，以 `this`(ThreadLocal) 为 key 存 v
- `get()`：从当前线程的 map 里以 `this` 为 key 取

```
Thread ─► ThreadLocalMap ─► Entry[]
                              │
                              ├─ Entry{ key=ThreadLocalA(弱引用) → value=X }
                              └─ Entry{ key=ThreadLocalB(弱引用) → value=Y }

多个 ThreadLocal 共用同一个线程的 map；ThreadLocal 只是"钥匙"，值挂在线程身上。
```

> 所以：**一个线程一个 ThreadLocalMap；ThreadLocal 只是 key。** 这也是隔离的根本——不同线程访问的是各自的 map。

---

## 四、ThreadLocalMap 细节

- `Entry extends WeakReference<ThreadLocal>`：**key 是弱引用，value 是强引用**
- 解决哈希冲突用 **开放寻址法（线性探测）**，不是链表（和 HashMap 不同）

---

## 五、★★ 内存泄漏问题（面试必考）

**成因链：**
1. `Entry` 的 **key(ThreadLocal) 是弱引用，value 是强引用**
2. 若外部对 ThreadLocal 的强引用消失 → **key 被 GC 回收变 `null`**，但 **value 仍被 `ThreadLocalMap → Entry` 强引用**
3. `ThreadLocalMap` 生命周期 = **线程生命周期**；线程池里线程**长期存活** → value 永远不释放 → **key=null 的 Entry 堆积 = 内存泄漏**

**JDK 的缓解**：`get/set/remove` 时会**顺带清理 key=null 的过期 Entry**（`expungeStaleEntry`）—— 但不保证被触发。

**根治**：**用完必须 `remove()`**，放 `finally` 里（尤其线程池场景）。

---

## 六、为什么 key 要用弱引用？（高频追问）

- **若 key 用强引用**：ThreadLocal 实例即使外部不用了，也被 Entry 强引用 → **key 和 value 一起泄漏**，更严重。
- **用弱引用**：至少 ThreadLocal 能被回收，剩下的 key=null 的 Entry 靠 JDK 清理逻辑兜底。
- **结论**：弱引用是**缓解**（让 key 可回收），**根治仍靠 `remove()`**（清 value）。

---

## 七、经典坑 & 最佳实践

| 坑 | 后果 | 解决 |
|---|---|---|
| 线程池 + 不 remove | 内存泄漏 + **脏数据**（线程复用，上个任务的值残留） | 用完 `remove()`，放 `finally` |
| ThreadLocal 非 static | 每次 new 一个，浪费/易错 | **`private static final`**（复用同一 key） |
| 父子线程传值 | 子线程 `get` 不到父线程的值 | 用 `InheritableThreadLocal` |
| 线程池跨线程传上下文 | InheritableThreadLocal 在池化复用时失效 | 用阿里 **TransmittableThreadLocal(TTL)** |

---

## 八、相关类对比

| 类 | 能力 |
|---|---|
| **ThreadLocal** | 线程隔离，各线程独立副本 |
| **InheritableThreadLocal** | 子线程 `new Thread` 时**继承**父线程的值 |
| **TransmittableThreadLocal**（阿里 TTL） | 解决**线程池**场景的上下文传递（InheritableThreadLocal 在池复用时失效） |

---

## 九、应用场景

- **Spring**：事务的 DB 连接绑定当前线程（`DataSourceTransactionManager`）、`RequestContextHolder`、`SecurityContextHolder`
- **日志**：MDC 的 traceId 全链路透传
- **工具类**：每线程独享 `SimpleDateFormat`（线程不安全）

---

> **核心原则：ThreadLocal 靠「每线程独立副本」实现隔离；数据存在 Thread 的 ThreadLocalMap 里、ThreadLocal 只是弱引用 key；核心坑是「内存泄漏(key 弱引用被回收后 value 残留)」+「线程池脏数据」，必须用完 `remove()`；跨线程传递用 InheritableThreadLocal / TTL。**

## 🔗 关联
- （待补）线程池原理、synchronized/AQS、volatile、CAS
