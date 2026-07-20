# 03 · 手写线程池（Thread Pool）

> 考点：线程复用原理、阻塞队列、ThreadPoolExecutor 七大参数 + 拒绝策略。难度 🟡 中等 · 出现频率 **中高频**（并发岗必问）。

## 题目

手写一个极简线程池，要求：

1. 提交任务：`execute(Runnable task)`；
2. 固定数量的 worker 线程复用执行任务，**不为每个任务新建线程**；
3. 支持 `shutdown()` 优雅停止（把已提交任务跑完后退出）。

示例：

```java
MyThreadPool pool = new MyThreadPool(3, 10); // 3 个 worker，队列容量 10
for (int i = 0; i < 8; i++) {
    int id = i;
    pool.execute(() -> System.out.println(Thread.currentThread().getName() + " run task " + id));
}
pool.shutdown();
// 输出：始终只有 pool-worker-0/1/2 三个线程名在轮流执行 8 个任务
```

## 思路

线程池的本质 = **N 个常驻 worker 线程 + 1 个阻塞任务队列**，是典型的**生产者-消费者**模型：

- `execute()` 是生产者：把 `Runnable` `put` 进 `BlockingQueue`；
- 每个 worker 是消费者：死循环 `queue.take()` 取任务并 `run()`；队列空时 `take()` **阻塞**，线程挂起不空转，这就是「线程复用 + 不耗 CPU」的关键；
- `shutdown()`：置一个 `volatile boolean` 停止标志，worker 循环条件变为「未 shutdown **或** 队列还有剩余任务」，从而把存量任务跑完再退出。

时间：提交/取任务均 O(1)（队列内部 O(1) 或 O(log n)）；空间：O(队列容量)。

## 代码（Java）

```java
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 极简线程池：固定 worker 数 + 一个阻塞任务队列。
 * 核心思想 = 生产者(execute) / 消费者(worker.take) + 优雅关闭标志位。
 */
public class MyThreadPool {

    private final BlockingQueue<Runnable> queue;   // 阻塞任务队列
    private final Worker[] workers;                 // 固定 worker 线程数组
    private volatile boolean shutdown = false;      // 优雅停止标志（volatile 保证可见性）
    private final AtomicInteger threadId = new AtomicInteger(0);

    public MyThreadPool(int poolSize, int queueCapacity) {
        this.queue = new ArrayBlockingQueue<>(queueCapacity); // 有界队列，避免无限堆积 OOM
        this.workers = new Worker[poolSize];
        for (int i = 0; i < poolSize; i++) {
            workers[i] = new Worker();
            workers[i].start();                    // 池启动即创建并启动全部 worker
        }
    }

    /** 提交任务：往队列里塞。队列满时 put 会阻塞（背压），也可改用 offer 实现拒绝策略。 */
    public void execute(Runnable task) throws InterruptedException {
        if (shutdown) {
            throw new IllegalStateException("thread pool is shutting down");
        }
        queue.put(task); // 队列满则阻塞等待，直到有空位
    }

    /** 优雅关闭：不再接收新任务，但把队列里已有任务全部执行完再退出。 */
    public void shutdown() {
        shutdown = true;
        // 唤醒可能阻塞在 take() 上的空闲 worker，让它们重新判断退出条件
        for (Worker w : workers) {
            w.interrupt();
        }
    }

    /** worker 线程：死循环从队列取任务执行。 */
    private class Worker extends Thread {
        Worker() {
            super("pool-worker-" + threadId.getAndIncrement());
        }

        @Override
        public void run() {
            // 只要「没 shutdown」或者「队列里还有存量任务」，就继续消费
            while (!shutdown || !queue.isEmpty()) {
                try {
                    Runnable task = queue.take(); // 队列空则阻塞挂起，不空转耗 CPU
                    task.run();                   // 复用当前线程执行任务
                } catch (InterruptedException e) {
                    // shutdown 时 interrupt 唤醒；此处不退出，交给 while 条件统一判断
                    // 若确定要立即停，可在此 break（对应 shutdownNow 语义）
                } catch (Throwable t) {
                    // 单个任务异常不能拖垮 worker 线程，吞掉/记日志后继续
                    System.err.println(getName() + " task error: " + t.getMessage());
                }
            }
        }
    }

    // ---- 自测 ----
    public static void main(String[] args) throws InterruptedException {
        MyThreadPool pool = new MyThreadPool(3, 10);
        for (int i = 0; i < 8; i++) {
            int id = i;
            pool.execute(() -> {
                System.out.println(Thread.currentThread().getName() + " run task " + id);
                try { Thread.sleep(100); } catch (InterruptedException ignored) {}
            });
        }
        pool.shutdown(); // 8 个任务被 3 个固定线程跑完后，进程退出
    }
}
```

> 面试默写只需记住四要素：**阻塞队列 + worker 死循环 take + execute put + volatile 关闭标志**，其余是锦上添花。

## 对照 JDK：ThreadPoolExecutor 七大参数

真实生产用 `ThreadPoolExecutor`，构造函数**七大参数**（务必背）：

| # | 参数 | 含义 |
|---|------|------|
| 1 | `corePoolSize` | 核心线程数，常驻，默认不回收 |
| 2 | `maximumPoolSize` | 最大线程数 = 核心 + 非核心（临时）线程 |
| 3 | `keepAliveTime` | 非核心线程空闲多久后被回收 |
| 4 | `unit` | keepAliveTime 的时间单位（TimeUnit） |
| 5 | `workQueue` | 任务阻塞队列（ArrayBlockingQueue / LinkedBlockingQueue / SynchronousQueue…） |
| 6 | `threadFactory` | 线程工厂，定制线程名/优先级/守护属性（便于排查问题） |
| 7 | `handler` | 拒绝策略：线程满 + 队列满时如何处理新任务 |

### 执行流程（记这条主线）

```
提交任务 execute(task)
   │
   ├─ 当前线程数 < corePoolSize ?  ── 是 → 新建核心线程直接执行
   │                                  否 ↓
   ├─ workQueue 没满 ?             ── 是 → 入队等待（核心线程慢慢消费）
   │                                  否 ↓
   ├─ 当前线程数 < maximumPoolSize ? ─ 是 → 新建「非核心线程」执行
   │                                  否 ↓
   └─ 触发 handler 拒绝策略（RejectedExecutionHandler）
```

一句话：**先用核心线程 → 再塞队列 → 再开非核心线程 → 最后拒绝**。
（注意：是「队列满了」才开非核心线程，不是核心满了就开——这也是为什么无界队列会让 maximumPoolSize 失效。）

### 四种拒绝策略

| 策略 | 行为 | 场景 |
|------|------|------|
| `AbortPolicy`（默认） | 直接抛 `RejectedExecutionException` | 需要感知过载、快速失败 |
| `CallerRunsPolicy` | 由**提交任务的线程**自己执行该任务 | 削峰/背压，别丢任务又不想爆内存 |
| `DiscardPolicy` | 静默丢弃新任务，不抛异常 | 任务可丢、不重要 |
| `DiscardOldestPolicy` | 丢掉队列**最老**的任务，再尝试提交新任务 | 只关心最新数据（如实时行情） |

深度原理（Worker 继承 AQS、ctl 高低位存状态+线程数、addWorker 源码）详见 [../../java-learning/09-concurrency/09-thread-pool.md](../../java-learning/09-concurrency/09-thread-pool.md)。

## 易错点 / 追问

**Q1：为什么阿里规约禁止用 `Executors` 的 `newFixedThreadPool` / `newCachedThreadPool`？**

- `newFixedThreadPool` / `newSingleThreadExecutor`：用**无界队列** `LinkedBlockingQueue`（容量 `Integer.MAX_VALUE`），任务无限堆积 → **OOM**；
- `newCachedThreadPool`：`maximumPoolSize = Integer.MAX_VALUE`，用 `SynchronousQueue`，来一个任务开一个线程，瞬时高并发下**线程数暴涨** → OOM / CPU 打满。
- 结论：**手动 `new ThreadPoolExecutor(...)`**，显式指定**有界队列 + 合理 max + 拒绝策略**，参数可控。

**Q2：核心线程为什么默认不回收？**

- `keepAliveTime` 默认只作用于**非核心线程**；核心线程视为常驻，避免频繁创建销毁开销（线程创建要分配栈、内核态切换，成本高）。
- 想让核心线程也回收：调 `allowCoreThreadTimeOut(true)`，此时核心线程空闲超时也会被回收。

**Q3：线程数怎么设？**

- **CPU 密集型**（计算为主）：`N + 1`（N = CPU 核数），+1 是让某线程因缺页/偶尔阻塞时仍能占满 CPU；
- **IO 密集型**（等 DB/网络为主）：约 `2N`，或更精确 `N × (1 + 平均等待时间/平均计算时间)`——线程大部分时间在等 IO，可以多开。
- 经验值仅供起点，最终以**压测**定，并做监控（队列长度、活跃线程数、拒绝次数）。

**Q4：为什么 worker 里 `take()` 而不是 `poll()`？**

- `take()` 队列空时**阻塞挂起**线程，不占 CPU；`poll()` 非阻塞会返回 null 导致死循环空转（busy-wait）烧 CPU。真实 TPE 里核心线程用 `take()`，非核心线程用带超时的 `poll(keepAliveTime)` 来实现「空闲超时回收」。

**Q5：任务里抛了异常会怎样？**

- 若不 try-catch，异常会顺着 `run()` 抛出，**该 worker 线程直接终止**，池子可用线程数悄悄减少。所以手写和生产都要在 worker 循环里 catch 住 `Throwable`（如上代码），或在任务内部自行兜底。
