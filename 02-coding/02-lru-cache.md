# 02 · LRU Cache（最近最少使用缓存）

> 考点：哈希表 + 双向链表，`get/put` O(1)；难度 🟡；频率 **高频（几乎必手撕）**。

## 题目

设计并实现一个 LRU（Least Recently Used，最近最少使用）缓存，支持：

- `LRUCache(int capacity)`：以正整数容量初始化。
- `int get(int key)`：存在返回 value，否则返回 -1。**访问算一次「使用」**。
- `void put(int key, int value)`：写入/更新 key。若超出容量，**淘汰最久未使用的那个 key**。

要求 `get` 和 `put` 均为 **O(1)** 时间复杂度。

```
LRUCache cache = new LRUCache(2);   // 容量 2
cache.put(1, 1);                    // 缓存 {1=1}
cache.put(2, 2);                    // 缓存 {1=1, 2=2}
cache.get(1);       // 返回 1，1 变为最近使用 → {2=2, 1=1}
cache.put(3, 3);    // 容量满，淘汰最久未用的 2 → {1=1, 3=3}
cache.get(2);       // 返回 -1（已被淘汰）
cache.put(4, 4);    // 淘汰 1 → {3=3, 4=4}
cache.get(1);       // 返回 -1
cache.get(3);       // 返回 3
cache.get(4);       // 返回 4
```

## 思路

核心矛盾：既要 **O(1) 按 key 查找**，又要 **O(1) 维护「使用顺序」并淘汰最旧的**。单一结构做不到，组合两个：

| 需求 | 结构 | 为什么 |
|------|------|--------|
| O(1) 按 key 查值 | `HashMap<Integer, Node>` | 哈希直接定位节点 |
| O(1) 维护访问顺序、删除任意节点 | **双向链表** | 拿到节点即可 O(1) 摘除（知道前驱） |

约定：**链表头 = 最近使用，链表尾 = 最久未使用**。淘汰时删尾部。

- `get`：命中就把节点移到头部并返回值；未命中返回 -1。
- `put`：存在则更新值并移到头部；不存在则新建插到头部，若超容量删尾部并从 map 移除。

复杂度：**get / put 均摊 O(1)**，空间 **O(capacity)**。

---

## 方式一：基于 LinkedHashMap（最简，几行）

`LinkedHashMap` 内部就是「哈希表 + 双向链表」。构造时传 `accessOrder=true`，它会按**访问顺序**排列（每次 get/put 把元素挪到末尾）；再重写 `removeEldestEntry`，当 `size > capacity` 时返回 true，插入后自动淘汰最旧元素。

```java
import java.util.LinkedHashMap;
import java.util.Map;

public class LRUCache extends LinkedHashMap<Integer, Integer> {
    private final int capacity;

    public LRUCache(int capacity) {
        // initialCapacity, loadFactor, accessOrder=true（按访问顺序，而非插入顺序）
        super(capacity, 0.75f, true);
        this.capacity = capacity;
    }

    public int get(int key) {
        return getOrDefault(key, -1);
    }

    public void put(int key, int value) {
        super.put(key, value);
    }

    // 每次 put 后被调用；返回 true 表示删除最老的 entry
    @Override
    protected boolean removeEldestEntry(Map.Entry<Integer, Integer> eldest) {
        return size() > capacity;
    }
}
```

> 原理：`accessOrder=true` 让 get/put 访问的元素被移到链表尾（最近使用）；`removeEldestEntry` 在插入后判断是否超容，超了就删链表头（最久未使用）。**面试时可先甩这版说明「知道有捷径」，再手写方式二证明底层能力。**

---

## ★ 方式二：手写 HashMap + 双向链表（重点，能默写）

```java
import java.util.HashMap;
import java.util.Map;

public class LRUCache {

    // 双向链表节点
    private static class Node {
        int key, value;
        Node prev, next;
        Node() {}
        Node(int key, int value) { this.key = key; this.value = value; }
    }

    private final int capacity;
    private final Map<Integer, Node> map = new HashMap<>();
    // 伪头尾哨兵节点：避免头尾插入/删除时判空，代码更简洁
    private final Node head = new Node();
    private final Node tail = new Node();

    public LRUCache(int capacity) {
        this.capacity = capacity;
        head.next = tail;   // 初始 head <-> tail
        tail.prev = head;
    }

    public int get(int key) {
        Node node = map.get(key);
        if (node == null) return -1;
        moveToHead(node);            // 命中：标记为最近使用
        return node.value;
    }

    public void put(int key, int value) {
        Node node = map.get(key);
        if (node != null) {          // 已存在：更新值 + 移到头部
            node.value = value;
            moveToHead(node);
            return;
        }
        Node newNode = new Node(key, value);
        map.put(key, newNode);
        addToHead(newNode);          // 新节点插到头部
        if (map.size() > capacity) { // 超容量：淘汰尾部
            Node removed = removeTail();
            map.remove(removed.key); // 别忘了同步从 map 删除
        }
    }

    // ---- 链表辅助方法 ----

    // 头插：head <-> node <-> 原第一个
    private void addToHead(Node node) {
        node.prev = head;
        node.next = head.next;
        head.next.prev = node;
        head.next = node;
    }

    // 摘除任意节点（O(1)，因为是双向链表，知道前驱）
    private void remove(Node node) {
        node.prev.next = node.next;
        node.next.prev = node.prev;
    }

    // 移到头部 = 先摘除再头插
    private void moveToHead(Node node) {
        remove(node);
        addToHead(node);
    }

    // 删除尾部真实节点（tail 前一个），返回被删节点
    private Node removeTail() {
        Node node = tail.prev;
        remove(node);
        return node;
    }
}
```

默写要点（口诀）：**查表判空 → 移到头；写入更新或新建头插；超容删尾并清表**。四个辅助方法里 `moveToHead = remove + addToHead`，`put` 复用它们，逻辑不重复。

---

## 易错点 / 追问

- **为什么用双向链表，单链表行不行？**
  淘汰/移动节点要先「摘除」它，而摘除必须改它**前驱**的 `next`。双向链表 `node.prev` 直接拿到前驱，删除 O(1)；单链表得从头遍历找前驱，退化成 O(n)。

- **哨兵（dummy head/tail）节点的作用？**
  头尾各放一个不存数据的哨兵，让任何节点的 `prev`/`next` 永不为 null。头插、删尾都不用写「链表为空 / 删的是头节点」这类边界判断，`addToHead`/`remove` 各几行搞定，**大幅减少空指针 bug**。

- **`put` 里最容易漏什么？**
  淘汰尾节点后**忘记 `map.remove(removed.key)`**——只删了链表没删哈希表，map 会越积越大且残留脏数据。所以 `removeTail()` 要返回节点，好拿到 key 去清 map。

- **为什么 HashMap 存的是 Node 而不是 value？**
  存 value 的话，移动/删除时还得在链表里找到对应节点（O(n)）。存 Node 引用，`get` 直接拿到链表节点，才能 O(1) 完成「移到头部」。

- **线程安全吗？**
  两种实现都**非线程安全**。简单场景可 `Collections.synchronizedMap(...)` 或对方法加锁（粗粒度、并发差）；生产环境直接用成熟库 **Caffeine / Guava Cache**（分段锁 + 更优的近似 LRU 算法 TinyLFU）。

- **LRU vs LFU 区别？**
  - **LRU**（Least Recently Used）：按**最近访问时间**淘汰，淘汰「最久没被碰过」的。本题即 LRU。
  - **LFU**（Least Frequently Used）：按**访问频次**淘汰，淘汰「用得最少」的；需额外维护计数，实现更复杂（频次桶 + 双向链表，见 LeetCode 460）。
  - 差异场景：某 key 历史被高频访问但最近没用，LRU 倾向淘汰它，LFU 会保留。

- **能进一步优化吗？** 可把 `capacity == 0` 直接视为不缓存；高并发下用 Caffeine 的 Window-TinyLFU 兼顾命中率与并发。对应 LeetCode 146。
