# Java Future 工作机制

> **核心理念：Future = 异步任务的「结果凭证/占位符」。提交任务立即拿到 Future，将来通过它（阻塞 `get` 或轮询 `isDone`）取回结果。底层靠 FutureTask 的「状态机 + CAS + park/unpark」实现。**
> 答题方法：为什么需要 → 核心接口 → ★工作机制(FutureTask) → 局限 → CompletableFuture 增强 → 坑。

---

## 一、为什么需要 Future？（解决什么）

| | Runnable | Callable |
|---|---|---|
| 返回值 | ❌ 无 | ✅ `V call()` |
| 抛检查异常 | ❌ | ✅ |

- 提交 `Callable` → 返回一个 **Future**，作为"未来结果的凭证"——解决"提交异步任务后**怎么拿返回值**"的问题。

---

## 二、核心接口 / 类（小步骤）

| 类型 | 作用 |
|---|---|
| `Callable<V>` | 有返回值、能抛异常的任务 |
| `Future<V>` | 异步结果凭证 |
| `FutureTask<V>` | `Future + Runnable` 的实现，**既是任务又是凭证** |
| `ExecutorService.submit(Callable)` | 提交任务，返回 `Future` |

**Future 的方法：**
- `get()`：**阻塞**直到完成取结果；`get(timeout)`：带超时
- `isDone()` / `isCancelled()`：状态查询
- `cancel(mayInterruptIfRunning)`：取消

---

## 三、工作机制（★ 核心：FutureTask 原理）

```
主线程:   submit(callable) ─► 得到 Future ─► …干别的… ─► future.get() ──(未完成则 park 阻塞)──┐
                │                                                                            │
                ▼                                                                            │
工作线程: FutureTask.run() ─► callable.call() ─► set(result) 存入 outcome ─► finishCompletion │
                                                                              └─ unpark 主线程 ┘
                                                                                             ▼
主线程被唤醒 ─► 返回 outcome
```

**关键点（小步骤）：**
1. `submit` 把 `Callable` 包成 **FutureTask**，丢进线程池队列
2. 工作线程执行 `FutureTask.run()` → 调 `call()` → 结果写入 `outcome` 字段
3. `get()`：任务没完成时，当前线程 **`LockSupport.park` 阻塞**（挂到 `waiters` 等待栈）
4. 任务完成 `finishCompletion()` → **`unpark` 唤醒**所有等待者
5. **状态机**：`NEW → COMPLETING → NORMAL / EXCEPTIONAL`，或 `CANCELLED / INTERRUPTED`
6. 全程用 **CAS 改状态 + park/unpark 阻塞唤醒**，不用重量级锁

---

## 四、Future 的局限（★ 为什么要 CompletableFuture）

- `get()` 只能**阻塞**或轮询 `isDone()`，**没法注册回调**（非阻塞）
- **不能组合/编排**多个 Future（如 A 完成后自动触发 B）
- 不能手动完成、没有异常处理链
- 多任务并行合并困难

---

## 五、CompletableFuture（JDK8 增强，实战主力）

实现 `Future + CompletionStage`，补齐编排能力：

| 能力 | 方法 |
|---|---|
| **回调（非阻塞）** | `thenApply` / `thenAccept` / `thenRun` |
| **串行依赖** | `thenCompose`（拿上一步结果再发起下一个异步） |
| **并行合并** | `thenCombine`（两个都完成后合并）、`allOf` / `anyOf` |
| **异步执行** | `xxxAsync`（默认 ForkJoinPool，**建议传自定义线程池**） |
| **异常处理** | `exceptionally` / `handle` / `whenComplete` |
| **手动完成** | `complete(v)` |

> 机制：基于**观察者模式**，任务完成时触发注册的**回调栈**（依赖用 CAS 的栈结构存回调），实现非阻塞链式编排。

---

## 六、坑 & 最佳实践

- **`get()` vs `join()`**：`get` 抛检查异常(`InterruptedException`/`ExecutionException`)，`join` 抛非检查异常
- **`get()` 一定设超时**，避免永久阻塞
- **别用默认 ForkJoinPool 跑阻塞 IO**：会耗尽公共池 → CompletableFuture 的 `xxxAsync` **传自定义线程池**
- 异常在异步链里**必须处理**（`exceptionally`/`handle`），否则被吞

---

> **核心原则：Future 是异步任务的结果凭证，`submit` 立即返回、`get` 阻塞取结果；底层 FutureTask 用「状态机 + CAS + park/unpark」实现阻塞唤醒；Future 只能阻塞/轮询、不能编排，所以 JDK8 用 CompletableFuture 支持回调/组合/异常处理做异步编排。**

## 🔗 关联
- ThreadLocal → [01-threadlocal](01-threadlocal.md)
- （待补）线程池原理、CompletableFuture 实战编排
