# 05 · 手写阻塞队列（Blocking Queue）

> 考点：`ReentrantLock` + 两个 `Condition`（notFull / notEmpty）实现有界阻塞队列；顺带辨析 `ArrayBlockingQueue` vs `LinkedBlockingQueue`。难度 🟡 中等 · 频率 中频。

## 题目

手写一个**有界阻塞队列** `BlockingQueue<E>`，支持：

- `put(e)`：入队。队列满时**阻塞**，直到有空位。
- `take()`：出队。队列空时**阻塞**，直到有元素。

要求线程安全，多生产者 / 多消费者并发下正确。

示例（容量 2）：

```
put(1)  -> ok
put(2)  -> ok
put(3)  -> 阻塞……（等到某线程 take 出一个后才返回）
take()  -> 1
take()  -> 2
take()  -> 3
take()  -> 阻塞……（等到某线程 put 后才返回）
```

## 思路

核心：**一把 `ReentrantLock` + 两个 `Condition`**，实现「满等待 / 空等待」的精准唤醒。

- `notFull`：生产者的等待队列。队列满时 `put` 在此 `await()`；`take` 出队腾出空位后 `notFull.signal()`。
- `notEmpty`：消费者的等待队列。队列空时 `take` 在此 `await()`；`put` 入队后 `notEmpty.signal()`。
- **必须用 `while` 而非 `if` 判断满 / 空**：防止**虚假唤醒（spurious wakeup）**，被唤醒后要重新检查条件。
- `await()` 会**释放锁**并挂起线程，被唤醒后**重新竞争锁**再返回；所以整段逻辑放在 `lock() / finally unlock()` 内是安全的。
- 底层用**循环数组**：`putIndex` / `takeIndex` 到末尾绕回 0，`count` 记录元素个数。判满 `count == items.length`，判空 `count == 0`。时间 O(1)，空间 O(capacity)。

## 代码（Java）

```java
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

/** 有界阻塞队列：循环数组 + ReentrantLock + 两个 Condition。 */
public class MyBlockingQueue<E> {

    private final Object[] items;   // 循环数组
    private int putIndex;           // 下一个写入位置
    private int takeIndex;          // 下一个读取位置
    private int count;              // 当前元素个数

    private final ReentrantLock lock = new ReentrantLock();
    private final Condition notFull  = lock.newCondition(); // 队列不满 -> 生产者可入队
    private final Condition notEmpty = lock.newCondition(); // 队列非空 -> 消费者可出队

    public MyBlockingQueue(int capacity) {
        if (capacity <= 0) throw new IllegalArgumentException("capacity must be > 0");
        this.items = new Object[capacity];
    }

    /** 入队：队列满则阻塞。 */
    public void put(E e) throws InterruptedException {
        if (e == null) throw new NullPointerException();
        lock.lockInterruptibly();
        try {
            // while 而非 if：防虚假唤醒，被唤醒后重新检查是否仍满
            while (count == items.length) {
                notFull.await();               // 释放锁并挂起，等待「不满」信号
            }
            enqueue(e);
            notEmpty.signal();                 // 通知一个等待的消费者：有货了
        } finally {
            lock.unlock();
        }
    }

    /** 出队：队列空则阻塞。 */
    @SuppressWarnings("unchecked")
    public E take() throws InterruptedException {
        lock.lockInterruptibly();
        try {
            while (count == 0) {
                notEmpty.await();              // 释放锁并挂起，等待「非空」信号
            }
            E e = (E) dequeue();
            notFull.signal();                  // 通知一个等待的生产者：有空位了
            return e;
        } finally {
            lock.unlock();
        }
    }

    // ---- 以下方法均在持有锁的前提下调用 ----

    private void enqueue(E e) {
        items[putIndex] = e;
        if (++putIndex == items.length) putIndex = 0; // 绕回队首
        count++;
    }

    private Object dequeue() {
        Object e = items[takeIndex];
        items[takeIndex] = null;                      // 帮助 GC
        if (++takeIndex == items.length) takeIndex = 0;
        count--;
        return e;
    }

    public int size() {
        lock.lock();
        try { return count; } finally { lock.unlock(); }
    }
}
```

简单自测：

```java
public static void main(String[] args) throws InterruptedException {
    MyBlockingQueue<Integer> q = new MyBlockingQueue<>(2);
    // 生产者
    new Thread(() -> {
        try { for (int i = 1; i <= 5; i++) { q.put(i); System.out.println("put " + i); } }
        catch (InterruptedException e) { Thread.currentThread().interrupt(); }
    }).start();
    // 消费者（故意慢一点，制造满阻塞）
    new Thread(() -> {
        try { for (int i = 1; i <= 5; i++) { Thread.sleep(200); System.out.println("take " + q.take()); } }
        catch (InterruptedException e) { Thread.currentThread().interrupt(); }
    }).start();
}
```

> 用 `LinkedList` 实现同理：把循环数组换成 `Deque`，`enqueue = addLast`、`dequeue = pollFirst`，判满改为 `count == capacity`。数组版无节点分配、缓存友好；链表版无需预分配容量。

## JDK 里的两种实现对比

| | `ArrayBlockingQueue` | `LinkedBlockingQueue` |
|---|---|---|
| 底层 | 定长循环数组 | 链表（单链表节点） |
| 有界性 | **必须有界**（构造传容量） | 可选有界，**默认 `Integer.MAX_VALUE`（近似无界）** |
| 锁 | **一把锁** + 两个 Condition（本题写法） | **两把锁**：`putLock` / `takeLock` 读写分离 |
| 吞吐 | 生产、消费互斥，竞争高时较低 | put/take 用不同锁，**并发吞吐更高** |
| 计数 | 普通 `int count`（受同一把锁保护） | `AtomicInteger count`（两把锁需原子跨锁同步） |

一句话记：**`ArrayBlockingQueue` 一把锁简单、内存紧凑；`LinkedBlockingQueue` 两把锁读写分离、吞吐高但节点有额外开销**。

## 易错点 / 追问

- **为什么两个 Condition 比一个高效？** 一个 Condition 时 `signalAll` 会把生产者和消费者一起唤醒，被唤醒者发现条件不满足又得重新 `await`，产生**无效唤醒 + 惊群**。分成 notFull / notEmpty 后可以**精准唤醒**：`take` 只唤醒生产者、`put` 只唤醒消费者，且能安全用 `signal()`（唤醒一个）而非 `signalAll()`。
- **为什么用 `while` 不用 `if`？** 防**虚假唤醒**，以及被唤醒后到抢回锁之间条件可能又被其他线程改变（多消费者场景）；`while` 保证返回时条件一定成立。
- **`await()` 会释放锁吗？** 会。`await()` 内部释放锁并挂起，被 `signal` 唤醒后需**重新获得锁**才从 `await()` 返回——所以等待期间其他线程能进入临界区。这点和 `Object.wait()` 一致。
- **`signal` 用在 `unlock` 之前还是之后？** 必须在持锁期间调用（`Condition` 要求当前线程持有锁），本题在 `finally` 的 `unlock` 之前 signal 是对的；被唤醒线程也要等本线程 `unlock` 后才能真正拿到锁。
- **有界 vs 无界的坑：** `new LinkedBlockingQueue<>()` 不传容量默认近似无界（`Integer.MAX_VALUE`），生产快于消费时会不断堆积导致 **OOM**；线程池用它当工作队列时 `maximumPoolSize` 会失效（永远塞得下就不会创建非核心线程）。面试要点：**生产环境优先用有界队列 + 拒绝策略**。
- **和 `wait/notify` 版的关系？** `ReentrantLock + Condition` 是 `synchronized + wait/notify` 的升级：支持多个条件队列（精准唤醒）、可中断 / 超时 / 公平锁。生产者消费者的 wait-notify 写法见 [04-producer-consumer](04-producer-consumer.md)。

> 深挖 AQS / Condition 等待队列的底层实现，见 [并发](../../java-learning/09-concurrency)。
