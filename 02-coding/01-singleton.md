# 01 · 手写单例（Singleton）

> 考点：类加载/线程安全/volatile/指令重排 · 难度 🟢 简单 · 频率 **高频**（几乎必问，重点问 DCL 的 volatile 和枚举）。

## 题目

保证一个类**全局只有一个实例**，并提供一个全局访问点。要求：

- 手写至少 3 种实现（面试常追问「你还知道哪几种」）。
- 线程安全、懒加载（用时才创建）、能抵御反射 / 反序列化破坏。

输入输出示例（语义）：

```text
Singleton a = Singleton.getInstance();
Singleton b = Singleton.getInstance();
a == b  →  true   // 永远同一个对象
```

## 思路

五种写法按「面试价值」排序，核心权衡就三点：**线程安全、是否懒加载、是否防破坏**。

| 写法 | 线程安全 | 懒加载 | 性能 | 防反射/反序列化 | 推荐度 |
|------|:---:|:---:|:---:|:---:|:---:|
| 饿汉式 | ✅ 类加载保证 | ❌ | 高 | ❌ | ⭐⭐⭐ |
| 懒汉式（裸） | ❌ | ✅ | 高 | ❌ | ❌ |
| 懒汉 + synchronized 方法 | ✅ | ✅ | **低**（每次锁） | ❌ | ⭐ |
| **DCL 双重检查锁** | ✅ | ✅ | 高 | ❌ | ⭐⭐⭐⭐ |
| **静态内部类** | ✅ 类加载保证 | ✅ | 高（无锁） | ❌ | ⭐⭐⭐⭐⭐ |
| **枚举** | ✅ | ❌ | 高 | **✅ 天然免疫** | ⭐⭐⭐⭐⭐ |

一句话记忆：**懒加载无锁看「静态内部类」，绝对安全看「枚举」，考点看「DCL 的 volatile」。**

复杂度：`getInstance()` 均摊 O(1) 时间、O(1) 空间；只讨论并发正确性。

## 代码（Java）

### 1. 饿汉式（Eager）—— 类加载即创建

```java
public class Singleton1 {
    // 类加载时就创建，JVM 保证类初始化线程安全，天然不会有并发问题
    private static final Singleton1 INSTANCE = new Singleton1();

    private Singleton1() {}

    public static Singleton1 getInstance() {
        return INSTANCE;
    }
}
```

- 优点：写法最简单；`static final` + 类加载机制保证**线程安全**且只创建一次。
- 缺点：**非懒加载**，只要类被加载就创建实例；若该实例很重（占内存/耗资源）却一直没用到，就是浪费。

### 2. 懒汉式（Lazy）—— 反面教材，两个版本对比

```java
// 2a. 裸懒汉：线程不安全，禁止在生产使用
public class Singleton2 {
    private static Singleton2 instance;

    private Singleton2() {}

    public static Singleton2 getInstance() {
        if (instance == null) {        // 多线程可能同时进入这里
            instance = new Singleton2();// → 创建出多个实例，单例被破坏
        }
        return instance;
    }
}
```

```java
// 2b. 方法加 synchronized：安全但慢
public class Singleton2b {
    private static Singleton2b instance;

    private Singleton2b() {}

    // 整个方法加锁：安全，但每次 getInstance 都要抢锁
    public static synchronized Singleton2b getInstance() {
        if (instance == null) {
            instance = new Singleton2b();
        }
        return instance;
    }
}
```

- 2a 优点：懒加载、简单。缺点：**线程不安全**，并发下会创建多个实例。
- 2b 优点：加锁后线程安全。缺点：实例只需创建一次，但**每次读取都要竞争同一把锁**，高并发下性能差（这正是 DCL 要优化的点）。

### 3. ★ 双重检查锁 DCL（Double-Checked Locking）—— 重点

```java
public class Singleton3 {
    // volatile 不能省！原因见下方讲解
    private static volatile Singleton3 instance;

    private Singleton3() {}

    public static Singleton3 getInstance() {
        if (instance == null) {                 // 第一次检查：绝大多数请求走这里，无锁，快
            synchronized (Singleton3.class) {
                if (instance == null) {         // 第二次检查：拿到锁后再确认，防止重复创建
                    instance = new Singleton3();
                }
            }
        }
        return instance;
    }
}
```

- 优点：只有第一次创建时才加锁，之后走无锁快路径，**兼顾线程安全 + 懒加载 + 高性能**。
- 缺点：写法容易出错（最常见就是漏了 `volatile`）；理解成本高。

**为什么 `volatile` 不能省（必答）：**

`instance = new Singleton3()` 这行**不是原子操作**，JVM 底层大致分三步：

```text
1. 分配内存空间
2. 初始化对象（执行构造函数）
3. 把 instance 引用指向这块内存

正常顺序: 1 → 2 → 3
指令重排后可能: 1 → 3 → 2   ← 引用先指过去，但对象还没初始化完
```

若发生 1→3→2 的**指令重排**：线程 A 执行到「3 已完成、2 未完成」时，
线程 B 在第一次 `if (instance == null)` 判断——此时 `instance` 已非 null，
于是 B 直接 `return instance` 拿到一个**尚未初始化完成的半成品对象**，使用时就会出错（NPE / 脏数据）。

`volatile` 的作用：
1. **禁止指令重排**（写屏障保证 1→2→3 顺序）；
2. 保证**可见性**，一个线程写入后其它线程立即可见。

所以 DCL 必须 `volatile`，否则在极端并发下会拿到破损对象。

### 4. ★ 静态内部类（Holder）—— 推荐写法

```java
public class Singleton4 {

    private Singleton4() {}

    // 静态内部类：只有第一次调用 getInstance() 触发 Holder 类加载时才创建实例
    private static class Holder {
        private static final Singleton4 INSTANCE = new Singleton4();
    }

    public static Singleton4 getInstance() {
        return Holder.INSTANCE;   // 触发 Holder 初始化
    }
}
```

- 原理：**JVM 保证类的 `<clinit>()`（类初始化）只被执行一次且线程安全**（靠加锁初始化标志实现）。外部类加载时不会加载内部类，只有真正调用 `getInstance()` 才加载 `Holder` 并创建实例。
- 优点：**懒加载 + 线程安全 + 无锁高效**，代码优雅。既解决了饿汉不懒加载，又避免了 synchronized 的开销和 DCL 的易错。**Java 里最常用的写法**。
- 缺点：仍无法防御反射/反序列化破坏（见下）。

### 5. ★ 枚举（Enum）—— 最佳（Effective Java 推荐）

```java
public enum Singleton5 {
    INSTANCE;

    // 可以有自己的字段和方法
    public void doSomething() {
        System.out.println("单例干活");
    }
}

// 使用：
// Singleton5.INSTANCE.doSomething();
```

- 优点：
  - 写法极简，天然线程安全（枚举实例由 JVM 在类加载时创建）；
  - **天然防反射攻击**：`Constructor.newInstance()` 对枚举会直接抛 `IllegalArgumentException: Cannot reflectively create enum objects`；
  - **天然防反序列化破坏**：枚举的序列化只写枚举名，反序列化时按名字返回已有实例，**不会 new 出新对象**；
  - 《Effective Java》第 3 条明确推荐「单元素枚举」是实现单例的最佳方式。
- 缺点：非懒加载（类加载即创建，同饿汉）；不能继承其它类；和「一切皆对象」的写法略有割裂，团队接受度看情况。

## 易错点 / 追问

- **DCL 漏 volatile**（最高频扣分点）：能背出「`new` 非原子三步 + 指令重排 → 拿到半初始化对象」，并说明 `volatile` 禁重排 + 保可见。
- **两次 null 检查各是什么作用**：第一次为了性能（无锁快路径），第二次为了正确性（拿锁后防止重复创建）。少任何一次都不对。
- **反射如何破坏普通单例**：私有构造照样能被 `setAccessible(true)` 打开再 `newInstance()`，创建出第二个实例。
  - 防御：在构造函数里判断——若实例已存在就抛异常；或直接用枚举（反射对枚举无效）。
- **反序列化如何破坏普通单例**：反序列化会通过反射 new 出新对象，`a != 反序列化(a)`。
  - 防御：实现 `Serializable` 时提供 `readResolve()` 方法返回已有单例；或直接用枚举（天生免疫）。
- **追问「你项目里用哪种」**：无状态、需要懒加载 → **静态内部类**；要绝对安全防破坏 → **枚举**；配置类等重量级且必然会用 → 饿汉也行。
- **追问「饿汉和静态内部类都靠类加载，区别？」**：饿汉在**外部类加载时**就创建（不懒）；静态内部类把实例挪进 Holder，只有**调用 getInstance 时才加载 Holder**，实现了懒加载。
- **追问「Spring 的单例是这个吗？」**：不是。Spring 的 singleton 是**容器级**——每个 `ApplicationContext` 里 bean 只有一份，靠 Map 缓存（`singletonObjects`）实现，作用域是容器不是 JVM，和这里的 GoF 单例不是一回事。
