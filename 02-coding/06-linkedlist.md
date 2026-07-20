# 06 · 链表高频题（Linked List）

> 考点：指针操作 + 边界处理（哨兵节点、快慢指针）+ 数学推导（环入口）。难度🟡 · 出现频率**极高频**（几乎每场手撕必考其一）。

链表题的三板斧：**哨兵/dummy 节点**（简化头节点边界）、**快慢指针**（判环/找中点/找倒数第 N）、**双指针 prev/cur**（原地反转）。下面每题都能默写。

统一节点定义（全篇复用，不再重复）：

```java
class ListNode {
    int val;
    ListNode next;
    ListNode() {}
    ListNode(int val) { this.val = val; }
    ListNode(int val, ListNode next) { this.val = val; this.next = next; }
}
```

---

## ★ 反转链表（Reverse Linked List）—— 最高频

### 题目
把单链表整体反转。`1→2→3→null` ⇒ `3→2→1→null`，返回新头。

### 思路
- **迭代**：三指针 `prev / cur / next`。每步先存下 `cur.next`，把 `cur.next` 指回 `prev`，然后 `prev`、`cur` 各前进一位。`prev` 最终就是新头。
- **递归**：先递归反转 `head.next` 之后的部分拿到新头，再让 `head.next.next = head` 把自己接到尾部，`head.next = null` 断尾。
- 复杂度：时间均 O(n)；迭代空间 **O(1)**，递归空间 **O(n)**（递归栈深度 = 链表长度）。

### 代码（Java）

```java
// 迭代：双指针（面试首选，O(1) 空间）
ListNode reverseIterative(ListNode head) {
    ListNode prev = null, cur = head;
    while (cur != null) {
        ListNode next = cur.next; // 1. 暂存后继，防止断链丢失
        cur.next = prev;          // 2. 反转指针
        prev = cur;               // 3. prev 前进
        cur = next;               // 4. cur 前进
    }
    return prev; // cur 走到 null 时，prev 是原尾节点 = 新头
}

// 递归
ListNode reverseRecursive(ListNode head) {
    if (head == null || head.next == null) return head; // 空/单节点直接返回
    ListNode newHead = reverseRecursive(head.next); // 反转后半部分
    head.next.next = head; // 让后一个节点指回自己
    head.next = null;      // 断开自己原来的 next，避免成环
    return newHead;        // 新头层层向上传递
}
```

---

## 判断链表有环（Linked List Cycle）+ 找环入口

### 题目
- Cycle I：链表是否有环，返回 boolean。
- Cycle II：若有环，返回**环的入口节点**，无环返回 null。

### 思路（Floyd 快慢指针）
- **判环**：`slow` 每次走 1 步、`fast` 每次走 2 步。无环 `fast` 会先到 null；有环两者必在环内相遇（相对速度 1，快指针每轮追近 1 步，一定追上）。
- **找入口**：设头到入口距离 `a`，入口到相遇点距离 `b`，相遇点绕回入口剩 `c`（环长 `b+c`）。相遇时 slow 走 `a+b`，fast 走 `a+b+k(b+c)`，且 fast = 2×slow ⇒ 推出 **`a = c + (k-1)(b+c)`**，即 `a` 与 `c`（模环长）相等。所以相遇后让一个指针**从头**、一个**从相遇点**，同速每次 1 步，再次相遇即入口。
- 复杂度：时间 O(n)，空间 **O(1)**。

### 代码（Java）

```java
// Cycle I：是否有环
boolean hasCycle(ListNode head) {
    ListNode slow = head, fast = head;
    while (fast != null && fast.next != null) {
        slow = slow.next;       // 走 1 步
        fast = fast.next.next;  // 走 2 步
        if (slow == fast) return true; // 相遇 = 有环
    }
    return false; // fast 到达 null = 无环
}

// Cycle II：找环入口
ListNode detectCycle(ListNode head) {
    ListNode slow = head, fast = head;
    while (fast != null && fast.next != null) {
        slow = slow.next;
        fast = fast.next.next;
        if (slow == fast) {          // 第一次相遇
            ListNode p = head;       // 一个指针回到头
            while (p != slow) {      // 同速前进，相遇处即入口
                p = p.next;
                slow = slow.next;
            }
            return p;
        }
    }
    return null; // 无环
}
```

> 环入口公式一句话记忆：**「头到入口」== 「相遇点绕到入口」（模环长）**，所以头和相遇点同速走必在入口碰头。

---

## 合并两个有序链表（Merge Two Sorted Lists）

### 题目
两个升序链表 `l1`、`l2`，合并成一个升序链表并返回。`1→2→4` + `1→3→4` ⇒ `1→1→2→3→4→4`。

### 思路
哨兵节点 `dummy` 挂在结果头前，`tail` 指向已合并部分的尾。每次比较 `l1.val` 与 `l2.val`，把小的接到 `tail` 后并推进该链。某条链走完后，把另一条**整段**接上即可。哨兵免去了「结果头是哪一个」的判空。

- 复杂度：时间 O(m+n)，空间 O(1)（迭代）。

### 代码（Java）

```java
ListNode mergeTwoLists(ListNode l1, ListNode l2) {
    ListNode dummy = new ListNode(-1); // 哨兵：结果头的前驱
    ListNode tail = dummy;
    while (l1 != null && l2 != null) {
        if (l1.val <= l2.val) {  // <= 保证稳定，相等取 l1
            tail.next = l1;
            l1 = l1.next;
        } else {
            tail.next = l2;
            l2 = l2.next;
        }
        tail = tail.next;
    }
    tail.next = (l1 != null) ? l1 : l2; // 接上剩余那条（有序，整段接）
    return dummy.next; // 跳过哨兵返回真正的头
}
```

---

## K 个一组翻转链表（Reverse Nodes in k-Group）—— 较难 🔴

### 题目
每 `k` 个节点一组就地翻转，不足 `k` 个的尾部保持原序。`1→2→3→4→5`，k=2 ⇒ `2→1→4→3→5`。

### 思路
1. 哨兵 `dummy`，用 `prevGroup` 记录**上一组的尾**（初始为 dummy）。
2. 每一组：先从 `prevGroup` 往后探 `k` 步找组尾 `kth`；**若不足 k 个则结束**（尾部保持原样）。
3. 记下下一组头 `nextGroup = kth.next`，在组内做标准反转（反转边界设为 `nextGroup`）。
4. 反转后原组头变组尾：`prevGroup.next` 接新组头，`prevGroup` 更新为原组头，继续下一组。
- 复杂度：时间 O(n)（每节点访问常数次），空间 O(1)。

### 代码（Java）

```java
ListNode reverseKGroup(ListNode head, int k) {
    ListNode dummy = new ListNode(-1);
    dummy.next = head;
    ListNode prevGroup = dummy; // 上一组的尾节点

    while (true) {
        // 1. 从 prevGroup 起找第 k 个节点作为本组尾
        ListNode kth = prevGroup;
        for (int i = 0; i < k && kth != null; i++) kth = kth.next;
        if (kth == null) break; // 不足 k 个，剩余保持原序，结束

        ListNode nextGroup = kth.next;   // 下一组的头
        ListNode groupHead = prevGroup.next; // 本组原头（反转后会变尾）

        // 2. 组内反转：把 [groupHead, kth] 反转，反转边界是 nextGroup
        ListNode prev = nextGroup, cur = groupHead;
        while (cur != nextGroup) {
            ListNode next = cur.next;
            cur.next = prev;
            prev = cur;
            cur = next;
        }
        // 3. 拼接：prevGroup 接新头 kth，prevGroup 移到本组新尾 groupHead
        prevGroup.next = kth;   // 上一组尾 → 本组新头
        prevGroup = groupHead;  // 本组原头成为下一轮的 prevGroup
    }
    return dummy.next;
}
```

> 技巧：组内反转时直接把 `prev` 初始化为 `nextGroup`，反转结束后本组尾 `groupHead.next` 自然指向下一组头，省去额外拼接。

---

## 找链表中点（Middle of the Linked List）

### 题目
返回链表中间节点。偶数个节点时返回**第二个**中间节点（LeetCode 876 定义）。

### 思路
快慢指针，`fast` 走 2 步、`slow` 走 1 步。`fast` 到末尾时 `slow` 正好在中点。循环条件决定偶数时取哪个中点：`fast != null && fast.next != null` 时偶数返回**后中点**；若想取**前中点**（如归并排序拆分），改成 `fast.next != null && fast.next.next != null` 或让 fast 从 head.next 起步。

- 复杂度：时间 O(n)，空间 O(1)。

### 代码（Java）

```java
// 偶数返回后中点（1→2→3→4 返回 3）
ListNode middleNode(ListNode head) {
    ListNode slow = head, fast = head;
    while (fast != null && fast.next != null) {
        slow = slow.next;
        fast = fast.next.next;
    }
    return slow;
}

// 变体：偶数返回前中点（归并排序拆分常用，1→2→3→4 返回 2）
ListNode middlePrev(ListNode head) {
    ListNode slow = head, fast = head.next; // fast 提前一步
    while (fast != null && fast.next != null) {
        slow = slow.next;
        fast = fast.next.next;
    }
    return slow;
}
```

---

## 相交链表（Intersection of Two Linked Lists）

### 题目
两条单链表可能在某节点后共享同一段（Y 形），返回第一个公共节点；不相交返回 null。**按引用（==）判相交，不是按值。**

### 思路（双指针走对方长度）
指针 `pa` 走 A、`pb` 走 B；到各自末尾后跳到**对方头部**继续。设 A 独有长 `a`、B 独有长 `b`、公共长 `c`。两指针各走 `a+c+b` 与 `b+c+a` 步，路程相等，会在第一个公共节点相遇；若不相交，则同时走到 null 退出。妙在无需先算长度差。

- 复杂度：时间 O(m+n)，空间 O(1)。

### 代码（Java）

```java
ListNode getIntersectionNode(ListNode headA, ListNode headB) {
    if (headA == null || headB == null) return null;
    ListNode pa = headA, pb = headB;
    while (pa != pb) {                     // 相交处相遇，或同为 null 退出
        pa = (pa == null) ? headB : pa.next; // A 走完转到 B 头
        pb = (pb == null) ? headA : pb.next; // B 走完转到 A 头
    }
    return pa; // 公共节点，或 null
}
```

> 为什么用 `pa == null` 而非 `pa.next == null` 做切换：让指针实际走到 null 再跳，能保证不相交时两者同时为 null 退出循环，否则会死循环。

---

## 删除倒数第 N 个节点（Remove Nth Node From End）

### 题目
删除链表倒数第 `n` 个节点，返回头。`1→2→3→4→5`，n=2 ⇒ `1→2→3→5`。一趟扫描完成。

### 思路
哨兵 `dummy` 指向 head（应对「删的是头节点」这一边界）。快指针 `fast` 先从 dummy 走 `n` 步，然后 `fast` 和慢指针 `slow`（从 dummy 起）同步走，`fast` 到达末尾（null）时，`slow` 正好停在**待删节点的前驱**，改 `slow.next` 跳过即可。

- 复杂度：时间 O(L) 一趟，空间 O(1)。

### 代码（Java）

```java
ListNode removeNthFromEnd(ListNode head, int n) {
    ListNode dummy = new ListNode(-1);
    dummy.next = head;
    ListNode fast = dummy, slow = dummy;
    for (int i = 0; i < n; i++) fast = fast.next; // fast 先走 n 步
    while (fast.next != null) {   // 二者同步走，fast 到尾节点为止
        fast = fast.next;
        slow = slow.next;
    }
    slow.next = slow.next.next; // slow 是待删前驱，跳过目标节点
    return dummy.next; // 哨兵化解「删头」边界
}
```

---

## 易错点 / 追问

| 主题 | 要点 |
|------|------|
| **哨兵/dummy 节点** | 凡是**头节点可能被删/被换**（删倒数第 N、合并、K 组反转）就用 dummy 挂头前，统一逻辑、免去大量 `head == null`/头判断，最后 `return dummy.next`。 |
| **反转丢链** | 迭代反转必须先 `next = cur.next` 暂存，再改 `cur.next = prev`，否则改完指针就找不到后继。 |
| **递归空间 O(n)** | 递归反转优雅但递归栈深度 = 链表长度，长链表可能 **StackOverflow**；面试若强调空间/超长链表，答**迭代 O(1)**。 |
| **快慢指针判环为何成立** | 有环时快指针相对慢指针每轮逼近 1 步，差距必被抹平而相遇；无环则 fast 先触 null。循环条件 `fast != null && fast.next != null` 缺一不可（fast 走两步要保证中途不 NPE）。 |
| **环入口公式** | 记 `a=c`（模环长）：`a`=头到入口，`c`=相遇点绕回入口。相遇后一指针回头、一指针留原地，**同速**再相遇即入口。别背错成「slow 回头」——回头的是新起的头指针，slow 留在相遇点。 |
| **相交按引用** | 判相交是 `==`（同一节点对象），不是 val 相等；切换条件用 `pa == null` 而非 `pa.next == null`，保证不相交时同步走到 null 退出。 |
| **找中点取哪个** | 偶数节点「前/后中点」取决于循环条件与 fast 起点；**归并排序拆分要取前中点**，否则可能死递归。 |
| **删倒数第 N 的边界** | n 等于链表长度时删的是头节点，靠 dummy 化解；题目保证 n 合法则无需额外判越界，否则要判 `fast` 是否提前为 null。 |

> 深度原理（如为什么 Floyd 一定能在 O(环长) 内相遇、Brent 判环算法）可扩展到算法专题；本篇聚焦面试默写与口述推导。
