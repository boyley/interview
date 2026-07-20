# 07 · 二叉树高频题（Binary Tree）

> 考点：DFS/BFS、递归思维、栈/队列迭代。难度🟡中等 · 出现频率：**高频**（几乎必考 1~2 题）。
> 一句话：**二叉树问题 90% 是「递归 = DFS」，剩下的是「层序 = BFS 用队列」**。会默写遍历 + LCA + 层序，基本够用。

---

## 统一定义

所有题目共用这个节点定义（面试默认给出，无需自己写）：

```java
class TreeNode {
    int val;
    TreeNode left, right;
    TreeNode() {}
    TreeNode(int val) { this.val = val; }
    TreeNode(int val, TreeNode left, TreeNode right) {
        this.val = val; this.left = left; this.right = right;
    }
}
```

**心法对照表**：

| 需求 | 用什么 | 数据结构 |
|------|--------|----------|
| 遍历 / 深度 / 路径 / 自底向上 | **DFS（递归）** | 系统调用栈 |
| 遍历不用递归（加分） | **DFS 迭代** | 显式 `Stack` |
| 按层输出、找最短、层信息 | **BFS** | `Queue` + 记录层大小 |

---

## 一、三种遍历（前序 / 中序 / 后序）

> 前中后指的是**根节点被访问的时机**：根左右 / 左根右 / 左右根。左右子树的相对顺序永远是先左后右。

### 1. 递归版（本质就是 DFS，最好记）

```java
List<Integer> res = new ArrayList<>();

// 前序：根 -> 左 -> 右
void preorder(TreeNode root) {
    if (root == null) return;
    res.add(root.val);   // 访问根
    preorder(root.left);
    preorder(root.right);
}

// 中序：左 -> 根 -> 右（BST 中序 = 升序！）
void inorder(TreeNode root) {
    if (root == null) return;
    inorder(root.left);
    res.add(root.val);   // 把访问根挪到中间
    inorder(root.right);
}

// 后序：左 -> 右 -> 根
void postorder(TreeNode root) {
    if (root == null) return;
    postorder(root.left);
    postorder(root.right);
    res.add(root.val);   // 挪到最后
}
```

三种写法**只差 `res.add` 那一行的位置**，这是默写关键。

### 2. 迭代版（用栈，加分点 ★）

**为什么用栈**：递归本质是靠**系统调用栈**保存「待返回的现场」。手动迭代就是用一个显式 `Stack` 模拟这个调用栈——后进先出正好匹配「深入到底再回溯」的 DFS 特性（BFS 才用队列）。

```java
// 前序迭代：根出栈就访问，先压右再压左（保证左先出）
List<Integer> preorderIter(TreeNode root) {
    List<Integer> res = new ArrayList<>();
    if (root == null) return res;
    Deque<TreeNode> stack = new ArrayDeque<>();
    stack.push(root);
    while (!stack.isEmpty()) {
        TreeNode node = stack.pop();
        res.add(node.val);
        if (node.right != null) stack.push(node.right); // 右先入
        if (node.left != null) stack.push(node.left);   // 左后入 -> 先出
    }
    return res;
}

// 中序迭代：一路压左到底，弹出即访问，再转向右子树
List<Integer> inorderIter(TreeNode root) {
    List<Integer> res = new ArrayList<>();
    Deque<TreeNode> stack = new ArrayDeque<>();
    TreeNode cur = root;
    while (cur != null || !stack.isEmpty()) {
        while (cur != null) {      // 尽量向左走
            stack.push(cur);
            cur = cur.left;
        }
        cur = stack.pop();         // 最左节点，访问
        res.add(cur.val);
        cur = cur.right;           // 转向右子树
    }
    return res;
}

// 后序迭代：用前序(根右左)的变体，最后整体反转
List<Integer> postorderIter(TreeNode root) {
    LinkedList<Integer> res = new LinkedList<>();
    if (root == null) return res;
    Deque<TreeNode> stack = new ArrayDeque<>();
    stack.push(root);
    while (!stack.isEmpty()) {
        TreeNode node = stack.pop();
        res.addFirst(node.val);    // 头插：得到「根右左」的逆序 = 左右根
        if (node.left != null) stack.push(node.left);  // 注意：先左后右
        if (node.right != null) stack.push(node.right);
    }
    return res;
}
```

**复杂度**：三种遍历（递归/迭代）均 **时间 O(n)**，每个节点访问一次；**空间 O(h)**，h 为树高（栈深度），最坏 O(n)（退化成链）。

---

## 二、层序遍历 BFS（★ 高频，按层输出）

> LeetCode 102。要求返回 `[[3],[9,20],[15,7]]` 这种**分层**结果。

**思路**：BFS 用**队列**。诀窍是每轮循环开始先取 `int size = queue.size()`，这一层恰好有 size 个节点，正好循环 size 次把它们全部出队并收集，同时把下一层子节点入队。**记录当前层大小**是分层输出的核心。

```java
List<List<Integer>> levelOrder(TreeNode root) {
    List<List<Integer>> res = new ArrayList<>();
    if (root == null) return res;
    Queue<TreeNode> queue = new LinkedList<>();
    queue.offer(root);
    while (!queue.isEmpty()) {
        int size = queue.size();          // ★ 固定住当前层节点数
        List<Integer> level = new ArrayList<>();
        for (int i = 0; i < size; i++) {  // 只处理这一层
            TreeNode node = queue.poll();
            level.add(node.val);
            if (node.left != null)  queue.offer(node.left);
            if (node.right != null) queue.offer(node.right);
        }
        res.add(level);
    }
    return res;
}
```

**复杂度**：时间 O(n)；空间 O(n)（队列最多存一层，满二叉树最后一层约 n/2）。

> 变体秒答：**锯齿层序**（奇偶层反转 level）、**右视图**（每层取最后一个 `i==size-1`）、**每层最大值**——都是在这个模板里加一行。

---

## 三、最大深度 / 最小深度（递归）

```java
// 最大深度：左右子树深度较大者 + 1
int maxDepth(TreeNode root) {
    if (root == null) return 0;
    return Math.max(maxDepth(root.left), maxDepth(root.right)) + 1;
}

// 最小深度：注意「叶子」定义 —— 必须左右都为空
int minDepth(TreeNode root) {
    if (root == null) return 0;
    if (root.left == null)  return minDepth(root.right) + 1; // 左空只能走右
    if (root.right == null) return minDepth(root.left) + 1;  // 右空只能走左
    return Math.min(minDepth(root.left), minDepth(root.right)) + 1;
}
```

**易错点**：最小深度**不能**直接 `Math.min(left, right)+1`。当一侧子树为空时，`min` 会取到 0，但根到「空指针」不构成一条到叶子的路径——叶子必须左右孩子都为空。所以要特判单侧为空的情况。**时间 O(n)，空间 O(h)**。

---

## 四、翻转二叉树（递归）

> LeetCode 226，「会翻转二叉树吗」是经典调侃题，务必秒杀。

```java
TreeNode invertTree(TreeNode root) {
    if (root == null) return null;
    TreeNode left = invertTree(root.left);   // 先递归拿到翻转后的子树
    TreeNode right = invertTree(root.right);
    root.left = right;                        // 交换
    root.right = left;
    return root;
}
```

**复杂度**：时间 O(n)，空间 O(h)。也可 BFS/DFS 迭代，交换每个节点的左右孩子即可。

---

## 五、最近公共祖先 LCA（★ 重点，递归）

> LeetCode 236。给定两个节点 p、q，找它们最近的公共祖先（一个节点可以是自己的祖先）。

**思路（后序 + 自底向上）**：递归返回「以 root 为根的子树里，是否含有 p 或 q」。

- 若 root 为空 / 等于 p / 等于 q，直接返回 root（找到了或到底了）。
- 递归左右子树，得到 left、right。
- **left 和 right 都非空** → p、q 分居两侧，**当前 root 就是 LCA**。
- 只有一侧非空 → LCA 在那一侧，把非空的那个往上返回。

```java
TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
    if (root == null || root == p || root == q) return root;
    TreeNode left  = lowestCommonAncestor(root.left, p, q);
    TreeNode right = lowestCommonAncestor(root.right, p, q);
    if (left != null && right != null) return root; // p、q 分列两侧 -> root 是 LCA
    return left != null ? left : right;             // 否则谁非空就往上传谁
}
```

**为什么成立**：递归本质是后序 DFS，先探到底再回溯。第一个「左右都返回非空」的节点，就是两个目标第一次「会合」的最深节点。**时间 O(n)，空间 O(h)**。

> 追问：若是**二叉搜索树（BST）**，可利用有序性优化——p、q 都小于 root 往左，都大于往右，否则当前即 LCA，平均 O(h)（LeetCode 235）。

---

## 六、判断平衡二叉树（自底向上 + 剪枝）

> LeetCode 110。平衡 = 每个节点的左右子树高度差 ≤ 1。

**思路**：朴素做法是对每个节点求高度再判断，会 O(n²) 重复计算。**自底向上**：一趟后序遍历，让「求高度」的递归顺便返回是否平衡——用 **-1 作为「已经不平衡」的哨兵值**，一旦某棵子树返回 -1 就层层向上短路（**剪枝**），不再计算，降到 O(n)。

```java
boolean isBalanced(TreeNode root) {
    return height(root) != -1;
}

// 返回子树高度；若已失衡则返回 -1 作为剪枝信号
int height(TreeNode root) {
    if (root == null) return 0;
    int left = height(root.left);
    if (left == -1) return -1;                 // 左子树已失衡，直接上抛
    int right = height(root.right);
    if (right == -1) return -1;                // 右子树已失衡
    if (Math.abs(left - right) > 1) return -1; // 当前节点失衡
    return Math.max(left, right) + 1;          // 平衡则正常返回高度
}
```

**复杂度**：时间 O(n)（每节点算一次高度），空间 O(h)。

---

## 七、对称二叉树（递归）

> LeetCode 101。判断是否轴对称（镜像）。

**思路**：不是判断「左右子树相等」，而是判断「左右子树**互为镜像**」——`left.left` 对 `right.right`，`left.right` 对 `right.left`。

```java
boolean isSymmetric(TreeNode root) {
    if (root == null) return true;
    return isMirror(root.left, root.right);
}

boolean isMirror(TreeNode a, TreeNode b) {
    if (a == null && b == null) return true;   // 都空 -> 对称
    if (a == null || b == null) return false;  // 一空一非空 -> 不对称
    return a.val == b.val
        && isMirror(a.left, b.right)           // 外侧对外侧
        && isMirror(a.right, b.left);          // 内侧对内侧
}
```

**复杂度**：时间 O(n)，空间 O(h)。

---

## 八、验证二叉搜索树 BST（★ 两种法：上下界 / 中序）

> LeetCode 98。BST 定义：**左子树全部 < 根 < 右子树全部**（是整棵子树，不只是左右孩子！）。

### 法一：上下界递归（每个节点带 min/max 约束）

**易错点**：不能只判断 `left.val < root.val < right.val`，那只管到直接孩子。要传递「祖先约束的区间」。**用 `long` 边界防溢出**——节点值可能取到 `Integer.MIN_VALUE/MAX_VALUE`，若用 int 初始化边界，遇到极值会误判，故用 `Long.MIN_VALUE / Long.MAX_VALUE`。

```java
boolean isValidBST(TreeNode root) {
    return valid(root, Long.MIN_VALUE, Long.MAX_VALUE);
}

// root 必须严格落在开区间 (low, high) 内
boolean valid(TreeNode root, long low, long high) {
    if (root == null) return true;
    if (root.val <= low || root.val >= high) return false;
    return valid(root.left, low, root.val)     // 进左子树：上界收紧为 root.val
        && valid(root.right, root.val, high);  // 进右子树：下界收紧为 root.val
}
```

### 法二：中序遍历应严格递增（更好记）

**核心性质**：BST 的**中序遍历（左根右）结果一定是严格升序**。所以中序遍历时，记住前一个值 `pre`，若当前值 `<= pre` 就不是 BST。

```java
long pre = Long.MIN_VALUE;   // 前驱值，用 long 防第一个节点是 Integer.MIN_VALUE

boolean isValidBST(TreeNode root) {
    if (root == null) return true;
    if (!isValidBST(root.left)) return false;  // 中序：先左
    if (root.val <= pre) return false;         // 根：必须严格大于前驱
    pre = root.val;
    return isValidBST(root.right);             // 后右
}
```

**复杂度**：两法均时间 O(n)，空间 O(h)。

---

## 易错点 / 追问速查

| 追问 | 怎么答 |
|------|--------|
| **递归和 DFS 什么关系？** | 递归遍历本质就是 DFS，靠**系统调用栈**保存现场；前中后序只是访问根的时机不同。 |
| **迭代遍历为什么用栈？** | 栈的 LIFO 正好模拟递归调用栈的「深入到底再回溯」；BFS 才用队列。 |
| **层序为什么每轮记 `size`？** | 队列里混着多层节点，进循环先固定住当前层节点数，循环 size 次即精确处理一整层，实现分层输出。 |
| **验证 BST 常见错法？** | ① 只比左右孩子（漏了整棵子树约束）；② int 边界遇到 `Integer.MIN/MAX_VALUE` 溢出误判 → 用 `long`。 |
| **BST 有什么杀手锏性质？** | **中序遍历 = 升序**。验证 BST、找第 K 小、找众数都靠它。 |
| **最小深度为何要特判？** | 单侧子树为空时不能取 min（会取到 0），叶子必须左右孩子都空。 |
| **判断平衡如何降到 O(n)？** | 自底向上，求高度的递归顺带返回失衡信号（-1 哨兵），一失衡就剪枝短路。 |
| **递归爆栈怎么办？** | 树极深（退化链）时递归栈可能溢出，可改迭代（显式栈）或考虑树的形态是否合理。 |

> 更深的 DFS/BFS、递归原理见 `../../algorithm-learning`（若有）。本篇聚焦面试默写与追问。
