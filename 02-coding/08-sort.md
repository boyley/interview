# 08 · 排序与 TopK（Sorting & TopK）

> 考点：手撕快排/归并/堆排序 + TopK 三解法 + 排序算法全对照；难度 🟡；频率 **高频（快排、TopK 几乎必问）**。

## 题目

1. **手写快速排序**：对 `int[]` 原地升序排序。
2. **手写归并排序 / 堆排序**：说清分治与建堆思想，给复杂度与稳定性。
3. **TopK 问题**：从 `n` 个元素中找出**最大的 K 个**（或第 K 大）。要求给出适合**海量数据/流式**与**平均 O(n)** 的两种解法。

```
输入: [3, 2, 1, 5, 6, 4], k = 2
输出: [5, 6]        // 最大的 2 个（顺序不要求）
// 变体「第 K 大」: 返回 5（LeetCode 215）
```

## 思路

三大 O(n log n) 排序都靠**分治**，差别在「分」和「治」放在哪一步：

| 算法 | 核心 | 一句话 |
|------|------|--------|
| 快排 | **先分区再递归** | 选 pivot，把小的甩左、大的甩右，递归两半；活在「分」 |
| 归并 | **先递归再合并** | 无脑对半切到底，再两两有序合并；活在「合」 |
| 堆排 | **建堆 + 反复取顶** | 建大顶堆，把堆顶（最大）换到末尾再下沉，缩堆 |

TopK 不必全排序：**维护大小为 K 的小顶堆**（O(n log k)，省内存、可流式）或 **quickselect**（partition 的副产品，平均 O(n)）。

---

## ★ 快速排序（重点，能默写）

分治：选一个 **pivot（基准）**，一趟 `partition` 把数组分成「≤pivot | pivot | ≥pivot」，pivot 落到最终位置，再递归排左右两段。

- 平均 **O(n log n)**，最坏 **O(n²)**（每次分区极不均，如已排序 + 取端点做 pivot）；
- **原地**（空间 O(log n)，递归栈）；**不稳定**（分区时的远距离交换会打乱相等元素相对次序）。

### 写法一：挖坑法（单边，最好记）

```java
public class QuickSort {

    public static void sort(int[] a) {
        if (a == null || a.length < 2) return;
        quickSort(a, 0, a.length - 1);
    }

    private static void quickSort(int[] a, int lo, int hi) {
        if (lo >= hi) return;
        int p = partition(a, lo, hi); // p 归位，左边≤a[p]，右边≥a[p]
        quickSort(a, lo, p - 1);
        quickSort(a, p + 1, hi);
    }

    // 挖坑法：先随机选 pivot 换到 lo，挖出坑，左右指针交替填坑
    private static int partition(int[] a, int lo, int hi) {
        // ★ 随机化 pivot：避免「已排序输入」退化到 O(n²)
        int rand = lo + (int) (Math.random() * (hi - lo + 1));
        swap(a, lo, rand);

        int pivot = a[lo];      // 基准值，a[lo] 成为第一个「坑」
        int left = lo, right = hi;
        while (left < right) {
            // 从右往左找第一个 < pivot 的，填到左坑
            while (left < right && a[right] >= pivot) right--;
            a[left] = a[right];                       // right 处变新坑
            // 从左往右找第一个 > pivot 的，填到右坑
            while (left < right && a[left] <= pivot) left++;
            a[right] = a[left];                        // left 处变新坑
        }
        a[left] = pivot;         // left==right，最后的坑放 pivot
        return left;
    }

    private static void swap(int[] a, int i, int j) {
        int t = a[i]; a[i] = a[j]; a[j] = t;
    }
}
```

### 写法二：双指针 / Lomuto（`j` 扫描，`i` 记边界）

```java
// 以 a[hi] 为 pivot，i 指向「< pivot 区」的下一个位置
private static int partition(int[] a, int lo, int hi) {
    int rand = lo + (int) (Math.random() * (hi - lo + 1));
    swap(a, rand, hi);           // 随机 pivot 换到末尾
    int pivot = a[hi];
    int i = lo;                  // [lo, i) 都 < pivot
    for (int j = lo; j < hi; j++) {
        if (a[j] < pivot) {
            swap(a, i, j);
            i++;
        }
    }
    swap(a, i, hi);              // pivot 归位到 i
    return i;
}
```

默写口诀：**选基准 → 一趟分区把基准归位 → 递归左右**。挖坑法记「右找小填左坑、左找大填右坑」，两个内层 while 的 `>=` / `<=` 保证相等元素不无限交换。

---

## 归并排序（稳定，需 O(n) 空间）

分治：对半切到只剩单个元素（天然有序），再自底向上**两两合并**两个有序段。

- 时间 **O(n log n)**（平均=最坏，与输入无关）；空间 **O(n)**（合并辅助数组）；**稳定**（合并时 `<=` 让左段相等元素优先，保序）。

```java
public class MergeSort {

    public static void sort(int[] a) {
        if (a == null || a.length < 2) return;
        int[] tmp = new int[a.length];       // 复用一个辅助数组，避免反复 new
        mergeSort(a, 0, a.length - 1, tmp);
    }

    private static void mergeSort(int[] a, int lo, int hi, int[] tmp) {
        if (lo >= hi) return;
        int mid = lo + (hi - lo) / 2;
        mergeSort(a, lo, mid, tmp);
        mergeSort(a, mid + 1, hi, tmp);
        merge(a, lo, mid, hi, tmp);
    }

    private static void merge(int[] a, int lo, int mid, int hi, int[] tmp) {
        for (int k = lo; k <= hi; k++) tmp[k] = a[k];
        int i = lo, j = mid + 1;
        for (int k = lo; k <= hi; k++) {
            if (i > mid)                a[k] = tmp[j++];   // 左段用完
            else if (j > hi)            a[k] = tmp[i++];   // 右段用完
            else if (tmp[i] <= tmp[j])  a[k] = tmp[i++];   // ★ <= 保证稳定
            else                        a[k] = tmp[j++];
        }
    }
}
```

---

## 堆排序（原地，不稳定）

建**大顶堆**（父 ≥ 子），堆顶即最大值：把堆顶与末尾交换、堆大小减一、对新堆顶**下沉（siftDown）**恢复堆序，重复到堆空。

- 时间 **O(n log n)**（建堆 O(n) + n 次下沉 O(log n)）；空间 **O(1)** 原地；**不稳定**。

```java
public class HeapSort {

    public static void sort(int[] a) {
        int n = a.length;
        // 1) 建堆：从最后一个非叶子节点 (n/2-1) 起自底向上下沉
        for (int i = n / 2 - 1; i >= 0; i--) siftDown(a, i, n);
        // 2) 反复把堆顶（最大）换到末尾，缩堆并下沉
        for (int end = n - 1; end > 0; end--) {
            swap(a, 0, end);
            siftDown(a, 0, end);      // 堆大小缩到 end
        }
    }

    // 让 a[i] 在 [0, size) 的堆里下沉到合适位置
    private static void siftDown(int[] a, int i, int size) {
        while (2 * i + 1 < size) {
            int child = 2 * i + 1;                 // 左孩子
            if (child + 1 < size && a[child + 1] > a[child]) child++; // 取较大孩子
            if (a[i] >= a[child]) break;           // 已满足堆序
            swap(a, i, child);
            i = child;
        }
    }

    private static void swap(int[] a, int i, int j) {
        int t = a[i]; a[i] = a[j]; a[j] = t;
    }
}
```

> 升序排序用**大顶堆**（最大值不断沉到尾部）；求 TopK 最大用**小顶堆**（见下）——别记反。

---

## ★ TopK 问题（重点，高频）

> 「n 个数里找最大的 K 个 / 第 K 大」。三种解法，面试**首选小顶堆或 quickselect**，说清各自适用场景是加分点。

| 解法 | 时间 | 空间 | 适用 |
|------|------|------|------|
| ① 大小为 K 的**小顶堆** | O(n log k) | O(k) | **海量数据 / 数据流**，内存放不下全部 |
| ② **快速选择 quickselect** | 平均 O(n)，最坏 O(n²) | O(1) | 数据能全进内存、只求一次 |
| ③ 全排序取后 K 个 | O(n log n) | O(1)~O(n) | 最省事但最慢，还要求「有序 TopK」时可用 |

### 解法一：大小为 K 的小顶堆（PriorityQueue）

维护一个**只存 K 个元素的小顶堆**，堆顶是这 K 个里的最小值。遍历每个数：堆不满就进；否则若 `x > 堆顶` 就弹堆顶、加 x。遍历完堆里就是最大的 K 个。**只需 O(k) 内存**，天然支持流式 / 分布式（各分片出 TopK 再归并）。

```java
import java.util.PriorityQueue;

public int[] topK(int[] nums, int k) {
    if (k <= 0) return new int[0];
    // 小顶堆：堆顶最小，便于把「更大的新值」挤掉最小的
    PriorityQueue<Integer> heap = new PriorityQueue<>(); // 默认自然序=小顶堆
    for (int x : nums) {
        if (heap.size() < k) {
            heap.offer(x);
        } else if (x > heap.peek()) {   // 比当前第 K 大还大，替换堆顶
            heap.poll();
            heap.offer(x);
        }
    }
    int[] res = new int[heap.size()];
    for (int i = 0; i < res.length; i++) res[i] = heap.poll();
    return res; // 若求「第 K 大」，遍历完 heap.peek() 即答案
}
```

### 解法二：快速选择 quickselect（平均 O(n)）

复用快排的 `partition`：一趟分区后 pivot 落到下标 `p`。求「第 K 大」等价于求升序**下标 `n-k`** 的元素——只需递归**含目标下标的那一半**，另一半丢弃，于是 `T(n)=T(n/2)+O(n)=O(n)`（平均）。

```java
import java.util.Random;

// 返回 nums 中第 k 大的元素（LeetCode 215）
public int findKthLargest(int[] nums, int k) {
    int target = nums.length - k;          // 升序后第 k 大在下标 n-k
    int lo = 0, hi = nums.length - 1;
    Random rnd = new Random();
    while (true) {
        int p = partition(nums, lo, hi, rnd);
        if (p == target) return nums[p];
        else if (p < target) lo = p + 1;   // 目标在右半
        else hi = p - 1;                   // 目标在左半
    }
}

private int partition(int[] a, int lo, int hi, Random rnd) {
    swap(a, hi, lo + rnd.nextInt(hi - lo + 1)); // 随机 pivot 防退化
    int pivot = a[hi], i = lo;
    for (int j = lo; j < hi; j++) {
        if (a[j] < pivot) swap(a, i++, j);
    }
    swap(a, i, hi);
    return i;
}

private void swap(int[] a, int i, int j) { int t = a[i]; a[i] = a[j]; a[j] = t; }
```

> **想找最小的 K 个**：小顶堆解法改成**大顶堆**（`PriorityQueue<>(Collections.reverseOrder())`），`x < 堆顶` 时替换；quickselect 目标下标改成 `k-1`。

---

## 排序算法对照表

| 算法 | 平均时间 | 最坏时间 | 空间 | 稳定 | 备注 |
|------|----------|----------|------|:----:|------|
| 冒泡 Bubble | O(n²) | O(n²) | O(1) | ✅ | 相邻交换；加标志位可对近乎有序早停 O(n) |
| 插入 Insertion | O(n²) | O(n²) | O(1) | ✅ | 近乎有序时快 O(n)；小数组优选 |
| 选择 Selection | O(n²) | O(n²) | O(1) | ❌ | 每趟选最小换到前面，交换少但**不稳定** |
| 希尔 Shell | O(n^1.3) | O(n²) | O(1) | ❌ | 分组插入排序，插入排序改良版 |
| **快排 Quick** | **O(n log n)** | O(n²) | O(log n) | ❌ | 常数小、实测最快；随机 pivot 防退化 |
| **归并 Merge** | O(n log n) | O(n log n) | O(n) | ✅ | 稳定、最坏也 nlogn；外部排序常用 |
| **堆排 Heap** | O(n log n) | O(n log n) | O(1) | ❌ | 原地、最坏 nlogn；缓存不友好，常数偏大 |
| 计数 Counting | O(n+k) | O(n+k) | O(n+k) | ✅ | 非比较；k=值域，仅整数/小范围 |
| 桶 Bucket | O(n+k) | O(n²) | O(n+k) | ✅ | 分桶后桶内排序；数据均匀分布才快 |
| 基数 Radix | O(d·(n+k)) | O(d·(n+k)) | O(n+k) | ✅ | 按位分配收集；d=位数，非比较排序 |

记忆：**「快希选堆」不稳定**，其余（冒插归 + 三种非比较）稳定；非比较排序（计数/桶/基数）能突破 O(n log n) 下界，但受值域/分布限制。

---

## 易错点 / 追问

- **快排为什么不稳定？** partition 时会把远处的元素直接交换到 pivot 另一侧，两个相等元素的相对顺序可能被打乱。例如 `[3a, 3b, 2]` 选 2 相关分区后 3a、3b 顺序可能颠倒。归并的合并、插入/冒泡的相邻交换则不会跨越相等元素，所以稳定。

- **快排最坏 O(n²) 何时发生？怎么优化？** pivot 每次都取到最值（如对**已排序/逆序**数组固定取首/尾元素做 pivot），分区极不均，递归深度 O(n)。优化：① **随机化 pivot** 或**三数取中**（首/中/尾的中位数）；② 小区间（如长度 < 10）**切插入排序**；③ 递归改成**尾递归 / 手动栈**、先递归较短一侧，把栈深压到 O(log n)。

- **稳定性定义、何时需要？** 稳定 = 排序后**值相等的元素相对次序不变**。需要它的典型场景：**多关键字排序**——先按次关键字排，再按主关键字用**稳定**排序，能保住次关键字的既有顺序（如先按价格、再按销量排，价格相同的仍按销量序）。

- **海量数据 TopK 为什么用小顶堆而不是全排序？** 数据量大到**内存放不下全部**（如 100 亿个数求 Top 100），无法一次性载入排序。小顶堆只占 **O(k)** 内存，数据可**流式**逐个读入、读完即弃；还天然可**分布式**：每台机器/每个分片各出局部 TopK，再归并成全局 TopK。用**小**顶堆求**最大**K：堆顶是候选集里的最小者，新值只要比它大就替换，堆里始终留着最大的 K 个。

- **`Arrays.sort` 底层用什么？**
  - **基本类型**（`int[]`/`double[]`…）：**双轴快速排序（Dual-Pivot QuickSort）**——两个 pivot 分三段，实测比单轴更快；小数组转插入排序。因基本类型无「稳定性」概念（值相同即完全相同），用不稳定的快排无所谓。
  - **对象类型**（`Object[]` / `Collections.sort` / `Arrays.sort(T[], Comparator)`）：**TimSort**（归并 + 插入的混合，识别已有升/降序「run」再合并），**稳定**且对近乎有序数据接近 O(n)。对象排序常涉及多关键字，必须稳定，故选归并系。

- **归并能否原地省掉 O(n) 空间？** 有「原地归并」算法但实现复杂且常数大，面试一般不要求；真省空间就用**堆排序**（O(1) 且最坏 nlogn）。

- **TopK 三解法怎么选？** 数据全在内存、只求一次 → **quickselect**（平均 O(n) 最快）；数据是**流 / 海量 / 分布式** → **小顶堆**（O(k) 内存、可增量）；还要求结果**有序输出**或 n 不大图省事 → 全排序。对应 LeetCode 215（第 K 大）、347（前 K 高频）、剑指 Offer 40（最小的 K 个数）。
