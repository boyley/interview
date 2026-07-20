# 04 · 生产者消费者（Producer-Consumer）

> 考点：线程通信 / `wait-notify` / 阻塞队列 / 虚假唤醒。难度 🟡 中等。频率 **高频**（并发手撕必考）。

## 题目

多个**生产者**线程往一个**容量有限**的共享缓冲区放数据，多个**消费者**线程从中取数据：

- 缓冲区**满** → 生产者阻塞等待，直到有空位；
- 缓冲区**空** → 消费者阻塞等待，直到有数据；
- 全程线程安全，不丢数据、不重复消费。

要求：用三种方式实现，并说清各自取舍。

```
生产者 ──put──▶ ┌───────────────┐ ──take──▶ 消费者
生产者 ──put──▶ │  有界缓冲区    │ ──take──▶ 消费者
生产者 ──put──▶ │ [■][■][ ][ ]  │ ──take──▶ 消费者
               └───────────────┘
               满→生产者wait  空→消费者wait
```

## 思路

本质是**有界缓冲区 + 两个条件**（"非满"给生产者、"非空"给消费者）。三种写法从底层到高层：

| 方式 | 机制 | 唤醒粒度 | 复杂度 | 推荐度 |
|------|------|----------|--------|--------|
| ★一 `synchronized` + `wait/notify` | 内置锁 + 对象监视器 | `notifyAll` 全唤醒 | 手写量大 | 面试必背 |
| 二 `ReentrantLock` + 2×`Condition` | 显式锁 + 两条件队列 | **精准唤醒**（只叫醒对家） | 中 | 进阶加分 |
| 三 `BlockingQueue` | JDK 封装的阻塞队列 | 内部搞定 | 极简 | **生产首选** |

复杂度：`put/take` 均摊 O(1)，空间 O(capacity)。

---

## 代码（Java）

### ★ 方式一：synchronized + wait/notify（最经典手撕，重点）

```java
import java.util.LinkedList;
import java.util.Queue;

public class PcSyncDemo {

    /** 有界缓冲区：synchronized + wait/notify */
    static class Buffer<T> {
        private final Queue<T> queue = new LinkedList<>();
        private final int capacity;

        Buffer(int capacity) { this.capacity = capacity; }

        /** 生产：满则等待 */
        public synchronized void put(T item) throws InterruptedException {
            // 关键：必须用 while 不能用 if（防虚假唤醒，见下方追问）
            while (queue.size() == capacity) {
                wait();               // 释放锁并挂起，被唤醒后重新竞争锁并再判条件
            }
            queue.offer(item);
            System.out.println("生产: " + item + "  剩余空位=" + (capacity - queue.size()));
            notifyAll();              // 唤醒所有等待线程（含消费者），让其重新判条件
        }

        /** 消费：空则等待 */
        public synchronized T take() throws InterruptedException {
            while (queue.isEmpty()) {
                wait();
            }
            T item = queue.poll();
            System.out.println("  消费: " + item + "  当前数量=" + queue.size());
            notifyAll();
            return item;
        }
    }

    public static void main(String[] args) {
        Buffer<Integer> buffer = new Buffer<>(5);

        // 2 个生产者
        for (int p = 0; p < 2; p++) {
            final int id = p;
            new Thread(() -> {
                for (int i = 0; i < 10; i++) {
                    try { buffer.put(id * 100 + i); Thread.sleep(50); }
                    catch (InterruptedException e) { Thread.currentThread().interrupt(); }
                }
            }, "P-" + p).start();
        }
        // 3 个消费者
        for (int c = 0; c < 3; c++) {
            new Thread(() -> {
                while (true) {
                    try { buffer.take(); Thread.sleep(80); }
                    catch (InterruptedException e) { Thread.currentThread().interrupt(); return; }
                }
            }, "C-" + c).start();
        }
    }
}
```

**默写要点（5 行骨架）**：
```
synchronized put:  while(满) wait();  入队;  notifyAll();
synchronized take: while(空) wait();  出队;  notifyAll();
```

### 方式二：ReentrantLock + 两个 Condition（精准唤醒）

用两个条件队列 `notFull` / `notEmpty` 分开管理，唤醒时**只叫醒真正该醒的那类线程**，避免 `notifyAll` 把同类也吵醒空转。

```java
import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

public class PcLockDemo {

    static class Buffer<T> {
        private final Queue<T> queue = new LinkedList<>();
        private final int capacity;
        private final ReentrantLock lock = new ReentrantLock();
        private final Condition notFull  = lock.newCondition();  // 生产者在此等"非满"
        private final Condition notEmpty = lock.newCondition();  // 消费者在此等"非空"

        Buffer(int capacity) { this.capacity = capacity; }

        public void put(T item) throws InterruptedException {
            lock.lock();
            try {
                while (queue.size() == capacity) {
                    notFull.await();          // 等价于 wait()：释放锁并挂起
                }
                queue.offer(item);
                notEmpty.signal();            // 只唤醒一个消费者（精准，不惊动其他生产者）
            } finally {
                lock.unlock();                // 解锁必须放 finally
            }
        }

        public T take() throws InterruptedException {
            lock.lock();
            try {
                while (queue.isEmpty()) {
                    notEmpty.await();
                }
                T item = queue.poll();
                notFull.signal();             // 只唤醒一个生产者
                return item;
            } finally {
                lock.unlock();
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {
        Buffer<Integer> buffer = new Buffer<>(5);
        Runnable producer = () -> {
            for (int i = 0; i < 20; i++) {
                try { buffer.put(i); } catch (InterruptedException e) { return; }
            }
        };
        Runnable consumer = () -> {
            while (true) {
                try { System.out.println("消费: " + buffer.take()); Thread.sleep(30); }
                catch (InterruptedException e) { return; }
            }
        };
        new Thread(producer, "P").start();
        new Thread(consumer, "C-1").start();
        new Thread(consumer, "C-2").start();
    }
}
```

> 分开两个 `Condition` 后，即使只 `signal()`（唤醒一个）也安全，因为被唤醒的一定是"对家"，不会出现"叫醒同类 → 大家都不满足条件 → 一起再睡 → 死锁"。这正是 `notifyAll` 之外的优化点。

### 方式三：BlockingQueue（最简，生产推荐）

`put`（满时阻塞）/ `take`（空时阻塞）由 JDK 内部实现，代码量最少，也是实际项目里的标准做法。

```java
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

public class PcBlockingQueueDemo {

    public static void main(String[] args) {
        // 有界队列容量 5；无界可用 LinkedBlockingQueue（注意内存风险）
        BlockingQueue<Integer> queue = new ArrayBlockingQueue<>(5);

        new Thread(() -> {
            try {
                for (int i = 0; i < 20; i++) {
                    queue.put(i);                 // 满则自动阻塞
                    System.out.println("生产: " + i);
                }
            } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
        }, "P").start();

        Runnable consumer = () -> {
            while (true) {
                try {
                    Integer item = queue.take();  // 空则自动阻塞
                    System.out.println("  消费: " + item);
                    Thread.sleep(50);
                } catch (InterruptedException e) { Thread.currentThread().interrupt(); return; }
            }
        };
        new Thread(consumer, "C-1").start();
        new Thread(consumer, "C-2").start();
    }
}
```

> 常用实现：`ArrayBlockingQueue`（数组有界，一把锁）、`LinkedBlockingQueue`（链表可有界/无界，读写两把锁吞吐更高）、`SynchronousQueue`（无容量，一手交钱一手交货）。

---

## 易错点 / 追问

**Q1：为什么条件判断用 `while` 而不是 `if`？（虚假唤醒 spurious wakeup）**
两个原因，缺一不可：
1. **虚假唤醒**：JVM/OS 允许 `wait()` 在**没有任何 notify** 的情况下自行返回（POSIX 底层特性），用 `if` 就会跳过判断直接往下执行 → 满了还入队 / 空了还出队。
2. **唤醒后条件已变**：`notifyAll` 唤醒多个线程，它们**逐个**重新拿锁；第一个消费者把唯一的数据取走后，第二个消费者拿到锁时队列已空。用 `if` 不会再检查，直接 `poll()` 出 `null` 或越界。
`while` 保证**被唤醒后重新判断条件**，不满足就继续 `wait()`，绝对安全。**口诀：wait 一律放 while 里。**

**Q2：`notify` vs `notifyAll`？为什么方式一必须用 `notifyAll`？**

| | notify | notifyAll |
|---|--------|-----------|
| 唤醒 | 随机一个等待线程 | 全部等待线程 |
| 风险 | 可能唤醒**同类** → 死锁 | 无（但有惊群、性能略低） |

方式一里生产者和消费者**等在同一个对象监视器上**。若生产者生产完只 `notify()`，JVM 可能偏偏唤醒**另一个生产者**：它一看还是满的（或轮到它时又满了）继续 `wait()`，而真正该醒的消费者没被叫醒 → 所有线程都睡死 → **信号丢失 / 死锁**。所以单监视器场景**必须 `notifyAll`**。
（方式二用两个 `Condition` 把两类线程分开等，`signal()` 定向唤醒对家，才可以安全地只叫醒一个。）

**Q3：`wait()` 为什么必须在 `synchronized` 块内？为什么会释放锁？**
- `wait/notify` 依赖**对象监视器（monitor）**，调用前必须先持有该对象的锁，否则抛 `IllegalMonitorStateException`。
- `wait()` 会**释放锁并挂起**当前线程——否则它抱着锁睡，别人永远进不了同步块、也没法 notify，直接死锁。被唤醒后 `wait()` 需**重新竞争到锁**才返回。这也是"释放锁让别人干活、条件满足再回来"的协作本质。
- 三者都必须是**同一个对象**：`obj.wait()` / `obj.notify()` 必须在 `synchronized(obj)` 内。

**Q4：三种方式怎么选？**
- 手撕面试写**方式一**（考的就是 wait/notify + while）；
- 想加分讲**方式二**（精准唤醒、可中断/超时 `awaitNanos`、可多条件）；
- 实际生产用**方式三**（`BlockingQueue`，简单不易错，线程池 `ThreadPoolExecutor` 内部即用它做任务队列）。

**Q5（延伸）：`Lock.await` 和 `Object.wait` 关系？**
`Condition.await/signal` 是 `wait/notify` 的升级版：一把 `Lock` 可绑定**多个** `Condition`（多个等待队列），而一个 `synchronized` 监视器只有一个等待队列。API 语义一致，都要"持锁调用 + while 判条件"。
深入 AQS 原理见 [AQS 与 Condition](../../java-learning/concurrent-aqs.md)。
