# 09 · 高频 LeetCode 精选（Hot Problems）

> 考点：哈希 / 双指针 / 滑动窗口 / 栈 / DP / 二分——后端面试最高频算法题合集；难度 🟡；频率 **极高频（几乎每场必考 1~2 道）**。
> 每题给：题意 → 最优思路 → 可编译 Java 代码 → 复杂度。★ 标注为最爱考的必背题。

## 📋 速览（考点归类）

| # | 题目 | 考点 | 最优复杂度 | 一句话套路 |
|---|------|------|-----------|-----------|
| 1 | 两数之和 | 哈希 | O(n) / O(n) | 边遍历边查「target-x」是否在 map |
| 2 | ★ 无重复字符最长子串 | 滑动窗口 | O(n) / O(k) | 右扩、遇重复缩左边界 |
| 3 | 三数之和 | 排序+双指针 | O(n²) / O(1) | 固定一个，左右夹逼，三处去重 |
| 4 | 接雨水 | 双指针 / 单调栈 | O(n) / O(1) | 短板决定水位，矮的一侧内移 |
| 5 | 最长回文子串 | 中心扩展 | O(n²) / O(1) | 枚举中心，奇偶两种向两边扩 |
| 6 | 合并区间 | 排序+遍历 | O(nlogn) / O(n) | 按左端排序，能接上就并 |
| 7 | 有效的括号 | 栈 | O(n) / O(n) | 左括号压栈，右括号配对弹 |
| 8 | 爬楼梯 / 斐波那契 | DP | O(n) / O(1) | `f(n)=f(n-1)+f(n-2)`，滚动两变量 |
| 9 | 二分查找（含左右边界） | 二分 | O(logn) / O(1) | 记牢 3 套模板，边界是命门 |

---

## 1. 两数之和（Two Sum）· 哈希

### 题目
数组 `nums` 与目标 `target`，返回**和为 target 的两个数的下标**（假设恰有一解，同一元素不可用两次）。
`nums=[2,7,11,15], target=9` → `[0,1]`（2+7=9）。

### 思路
暴力 O(n²) 双层循环。最优：用 `HashMap<值, 下标>` **一次遍历**——遍历到 `x` 时查 `target-x` 是否已出现，出现即得解。查找 O(1)。

### 代码（Java）
```java
public int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> seen = new HashMap<>();   // 值 -> 下标
    for (int i = 0; i < nums.length; i++) {
        int need = target - nums[i];
        if (seen.containsKey(need)) {               // 先查再放，避免自己配自己
            return new int[]{seen.get(need), i};
        }
        seen.put(nums[i], i);
    }
    return new int[]{-1, -1};                        // 无解
}
```
**复杂度**：时间 O(n)，空间 O(n)。

### 易错点 / 追问
- **先查后放**：若先 put 再查，`target=2x` 且只有一个 x 时会误配自己。
- 追问「有重复元素/多组解」：map 存下标会覆盖，但因题设唯一解不影响；要全部组合则用 `List<int[]>` 且值映射到下标列表。

---

## 2. ★ 无重复字符的最长子串（Longest Substring Without Repeating）· 滑动窗口

### 题目
给字符串 `s`，求**不含重复字符的最长子串长度**。
`"abcabcbb"` → 3（`"abc"`）；`"bbbbb"` → 1；`"pwwkew"` → 3（`"wke"`）。

### 思路
滑动窗口 `[left, right]`。右指针不断扩张，用 map 记录**每个字符最近出现位置**；当 `s[right]` 已在窗口内（其上次位置 ≥ left），把 `left` 直接跳到「上次位置 + 1」。每步更新答案。每个字符进出各一次 → O(n)。

### 代码（Java）
```java
public int lengthOfLongestSubstring(String s) {
    Map<Character, Integer> last = new HashMap<>();   // 字符 -> 最近出现下标
    int max = 0, left = 0;
    for (int right = 0; right < s.length(); right++) {
        char c = s.charAt(right);
        if (last.containsKey(c) && last.get(c) >= left) {
            left = last.get(c) + 1;                   // 左边界跳过重复字符
        }
        last.put(c, right);
        max = Math.max(max, right - left + 1);
    }
    return max;
}
```
**复杂度**：时间 O(n)，空间 O(min(n, 字符集大小))。

### 易错点 / 追问
- **`last.get(c) >= left` 必须判**：否则窗口外的旧重复会把 left 往回拉。例：`"abba"`，处理最后的 `a` 时旧下标 0 已在窗口外，不能回退。
- **滑动窗口通用模板**（背下来）：
  ```
  for (right = 0; right < n; right++) {
      加入 s[right] 到窗口;
      while (窗口不满足条件) { 移出 s[left]; left++; }
      更新答案;
  }
  ```
  用 `HashSet` 版则在 while 里 `set.remove(s[left++])` 直到无重复，思路等价、更直观但左指针逐格移。

---

## 3. 三数之和（3Sum）· 排序 + 双指针

### 题目
找出 `nums` 中所有**和为 0 且不重复**的三元组。
`[-1,0,1,2,-1,-4]` → `[[-1,-1,2],[-1,0,1]]`。

### 思路
先排序。固定第一个数 `nums[i]`，在其右侧用**左右双指针**夹逼找 `-nums[i]`：和大右指针左移，和小左指针右移。三个位置都要**去重**（跳过相邻相等）。

### 代码（Java）
```java
public List<List<Integer>> threeSum(int[] nums) {
    Arrays.sort(nums);
    List<List<Integer>> res = new ArrayList<>();
    for (int i = 0; i < nums.length - 2; i++) {
        if (nums[i] > 0) break;                       // 最小已>0，不可能凑0
        if (i > 0 && nums[i] == nums[i - 1]) continue;// 跳过重复的固定值
        int l = i + 1, r = nums.length - 1;
        while (l < r) {
            int sum = nums[i] + nums[l] + nums[r];
            if (sum == 0) {
                res.add(Arrays.asList(nums[i], nums[l], nums[r]));
                while (l < r && nums[l] == nums[l + 1]) l++;  // 去重
                while (l < r && nums[r] == nums[r - 1]) r--;  // 去重
                l++; r--;
            } else if (sum < 0) {
                l++;
            } else {
                r--;
            }
        }
    }
    return res;
}
```
**复杂度**：时间 O(n²)，空间 O(1)（不计返回值与排序栈）。

### 易错点 / 追问
- **去重三处**：固定值 `i`、命中后的 `l` 与 `r`。少一处就会出现重复三元组。
- **`i>0 && nums[i]==nums[i-1]`** 用「和前一个比」而非「和后一个比」，否则会漏掉合法的重复对（如 `-1,-1,2`）。
- 命中后 `l++; r--` 别忘，否则死循环。

---

## 4. 接雨水（Trapping Rain Water）· 双指针 / 单调栈

### 题目
高度数组 `height`，每格宽 1，求下雨后能接多少水。
`[0,1,0,2,1,0,1,3,2,1,2,1]` → 6。

### 思路
某格水量 = `min(左侧最高, 右侧最高) − 自身高度`。**双指针 O(1) 空间**：左右各一指针与 `leftMax/rightMax`，**谁矮移谁**——因为矮的一侧水位由该侧最大值确定（对面更高，短板在本侧）。

### 代码（Java）
```java
public int trap(int[] height) {
    int l = 0, r = height.length - 1;
    int leftMax = 0, rightMax = 0, water = 0;
    while (l < r) {
        leftMax = Math.max(leftMax, height[l]);
        rightMax = Math.max(rightMax, height[r]);
        if (leftMax < rightMax) {           // 左侧是短板，左格水位由 leftMax 定
            water += leftMax - height[l];
            l++;
        } else {
            water += rightMax - height[r];
            r--;
        }
    }
    return water;
}
```
**复杂度**：时间 O(n)，空间 O(1)。

### 易错点 / 追问
- 为何「谁矮移谁」正确：移动短板侧时，其水位只取决于本侧最大值，对面必然更高，无需知道对面精确高度。
- 追问其他解法：**单调栈**（逐层横向累加，遇到更高柱出栈结算凹槽）或**前后缀最大值数组**（O(n) 空间，最好写、最好理解）。

---

## 5. 最长回文子串（Longest Palindromic Substring）· 中心扩展

### 题目
返回 `s` 中最长的回文子串。
`"babad"` → `"bab"`（或 `"aba"`）；`"cbbd"` → `"bb"`。

### 思路
**中心扩展**：回文关于中心对称，枚举每个中心向两边扩。中心有两类——**奇数长**（单字符中心）与**偶数长**（双字符中心），共 2n−1 个中心。

### 代码（Java）
```java
public String longestPalindrome(String s) {
    if (s == null || s.length() < 2) return s;
    int start = 0, maxLen = 1;
    for (int i = 0; i < s.length(); i++) {
        int len1 = expand(s, i, i);       // 奇数中心
        int len2 = expand(s, i, i + 1);   // 偶数中心
        int len = Math.max(len1, len2);
        if (len > maxLen) {
            maxLen = len;
            start = i - (len - 1) / 2;    // 由中心与长度反推起点
        }
    }
    return s.substring(start, start + maxLen);
}

// 从 [l,r] 向两侧扩，返回回文长度
private int expand(String s, int l, int r) {
    while (l >= 0 && r < s.length() && s.charAt(l) == s.charAt(r)) {
        l--; r++;
    }
    return r - l - 1;                     // 退出时多走一步，故 -1
}
```
**复杂度**：时间 O(n²)，空间 O(1)。

### 易错点 / 追问
- **奇偶两种中心都要试**，只试奇数会漏 `"bb"` 这类偶回文。
- `start = i - (len-1)/2` 是易错点：`expand` 返回长度后由中心反推起点。
- 追问 O(n)：**Manacher 算法**（面试能说出名字+核心「利用对称复用已算半径」即可，通常不要求手写）。

---

## 6. 合并区间（Merge Intervals）· 排序 + 遍历

### 题目
合并所有重叠区间。
`[[1,3],[2,6],[8,10],[15,18]]` → `[[1,6],[8,10],[15,18]]`。

### 思路
**按左端点排序**后一次遍历：维护当前合并区间，若下一个左端 ≤ 当前右端则重叠，右端取 max 扩张；否则结算当前、开启新区间。

### 代码（Java）
```java
public int[][] merge(int[][] intervals) {
    Arrays.sort(intervals, (a, b) -> Integer.compare(a[0], b[0]));
    List<int[]> res = new ArrayList<>();
    int[] cur = intervals[0];
    for (int i = 1; i < intervals.length; i++) {
        if (intervals[i][0] <= cur[1]) {                 // 重叠：扩右端
            cur[1] = Math.max(cur[1], intervals[i][1]);
        } else {                                         // 断开：结算
            res.add(cur);
            cur = intervals[i];
        }
    }
    res.add(cur);                                        // 别忘最后一段
    return res.toArray(new int[res.size()][]);
}
```
**复杂度**：时间 O(nlogn)（排序主导），空间 O(n)。

### 易错点 / 追问
- **循环结束后要补 `res.add(cur)`**，最后一个合并区间还没入结果。
- 排序用 `Integer.compare` 而非 `a[0]-b[0]`，避免大数相减**整型溢出**。
- 边界 `<=`：`[1,4],[4,5]` 视为重叠（相邻端点算接上）。

---

## 7. 有效的括号（Valid Parentheses）· 栈

### 题目
字符串只含 `()[]{}`，判断括号是否有效（正确闭合且嵌套匹配）。
`"()[]{}"` → true；`"(]"` → false；`"([)]"` → false。

### 思路
经典**栈**：遇左括号压入其**对应的右括号**；遇右括号时，栈顶必须正好是它，否则无效。最终栈空才有效。

### 代码（Java）
```java
public boolean isValid(String s) {
    Deque<Character> stack = new ArrayDeque<>();
    for (char c : s.toCharArray()) {
        if (c == '(') stack.push(')');
        else if (c == '[') stack.push(']');
        else if (c == '{') stack.push('}');
        // 右括号：栈空或不匹配都非法
        else if (stack.isEmpty() || stack.pop() != c) return false;
    }
    return stack.isEmpty();                 // 有剩余左括号则未闭合
}
```
**复杂度**：时间 O(n)，空间 O(n)。

### 易错点 / 追问
- **最后必须判 `stack.isEmpty()`**：`"((("` 全程不报错但栈非空，应为 false。
- 遇右括号先判 `stack.isEmpty()`，否则空栈 pop 抛异常。
- 用 `ArrayDeque` 作栈，不用过时的 `Stack`（后者同步、有性能与设计问题）。

---

## 8. 爬楼梯 / 斐波那契（Climbing Stairs）· DP 滚动变量

### 题目
每次爬 1 或 2 阶，爬到第 `n` 阶有几种方法。
`n=2` → 2（1+1、2）；`n=3` → 3。本质是斐波那契。

### 思路
到第 `i` 阶只能从 `i-1`（跨1步）或 `i-2`（跨2步）来 → `f(i)=f(i-1)+f(i-2)`。只依赖前两项，用**两个滚动变量**把空间压到 O(1)。

### 代码（Java）
```java
public int climbStairs(int n) {
    if (n <= 2) return n;
    int prev = 1, cur = 2;                  // f(1)=1, f(2)=2
    for (int i = 3; i <= n; i++) {
        int next = prev + cur;
        prev = cur;
        cur = next;
    }
    return cur;
}
```
**复杂度**：时间 O(n)，空间 O(1)。

### 易错点 / 追问
- **别用朴素递归**：`f(n)=f(n-1)+f(n-2)` 无记忆化是 O(2ⁿ)，n 稍大就超时；要么记忆化，要么本篇迭代。
- 初值 `f(1)=1, f(2)=2`（爬楼梯语义），纯斐波那契是 `f(1)=1, f(2)=1`，看题意别搞混。
- 追问变体：一次可爬 1/2/3 阶（三项相加）、每阶有花费的最小花费爬楼梯（`min` 转移）。

---

## 9. 二分查找（Binary Search）· 二分模板

### 题目
升序数组 `nums` 找 `target`，返回下标，不存在返回 -1。进阶：找**第一个**/**最后一个**等于 target 的位置（有重复元素）。

### 思路
标准二分用**闭区间 `[left, right]`**，循环条件 `left <= right`。找左右边界时不立即返回，命中后继续向一侧收缩。

### 代码（Java）
```java
// ① 标准二分：找任一 target 下标
public int search(int[] nums, int target) {
    int left = 0, right = nums.length - 1;      // 闭区间 [left, right]
    while (left <= right) {                      // 注意 <=
        int mid = left + (right - left) / 2;    // 防 left+right 溢出
        if (nums[mid] == target) return mid;
        else if (nums[mid] < target) left = mid + 1;
        else right = mid - 1;
    }
    return -1;
}

// ② 找第一个 == target（左边界）；不存在返回 -1
public int leftBound(int[] nums, int target) {
    int left = 0, right = nums.length - 1, ans = -1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (nums[mid] >= target) {              // 命中也继续往左找
            if (nums[mid] == target) ans = mid;
            right = mid - 1;
        } else {
            left = mid + 1;
        }
    }
    return ans;
}

// ③ 找最后一个 == target（右边界）；不存在返回 -1
public int rightBound(int[] nums, int target) {
    int left = 0, right = nums.length - 1, ans = -1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (nums[mid] <= target) {              // 命中也继续往右找
            if (nums[mid] == target) ans = mid;
            left = mid + 1;
        } else {
            right = mid - 1;
        }
    }
    return ans;
}
```
**复杂度**：时间 O(logn)，空间 O(1)。

### 易错点 / 追问（二分的命门）
- **区间与循环条件配套**：闭区间 `[left,right]` 用 `while(left<=right)`、`right=mid-1`；半开区间 `[left,right)` 用 `while(left<right)`、`right=mid`。**混用是最大死因**（漏判或死循环）。
- **mid 溢出**：写 `left + (right-left)/2`，别写 `(left+right)/2`（大数组两下标之和可能超 `int`）。
- **死循环**：`left`/`right` 每轮必须真正收缩（`mid±1`），否则区间不缩会卡死。
- 左右边界的关键：**命中不立即返回**，记录答案后往目标方向继续收缩。

---

## ✅ 复习检查清单

- [ ] 两数之和为何「先查后放」——能防自己配自己？
- [ ] 无重复子串滑动窗口的 `last.get(c) >= left` 判断作用（`"abba"` 用例）？
- [ ] 三数之和的**三处去重**分别在哪、`i` 与前一个还是后一个比？
- [ ] 接雨水双指针「谁矮移谁」为什么正确？还能说出单调栈解法吗？
- [ ] 最长回文的奇偶两种中心 + `start = i-(len-1)/2` 推导？
- [ ] 合并区间循环后为何要补 `add(cur)`、比较为何用 `Integer.compare`？
- [ ] 有效括号为何最后要判 `stack.isEmpty()`？
- [ ] 爬楼梯朴素递归复杂度 O(2ⁿ)，如何优化到 O(n)/O(1)？
- [ ] 二分：闭区间 `<=` 与半开 `<` 的配套？mid 防溢出写法？左右边界模板？
