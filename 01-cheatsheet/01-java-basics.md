# 01 · Java 基础 速答（Java Basics）

> 面向 Java 后端的**语言基础八股**：基本类型与包装类、String 三兄弟、equals/hashCode 契约、面向对象、异常、泛型/反射、值传递。覆盖 ~22 个高频问，全部「能背出口」。深度原理见 [`../../java-learning`](../../java-learning)。

## 🔥 高频必背（Top 22）

| # | 问题 | 一句话答 |
|---|---|---|
| 1 | Java 有几种基本类型（primitive）？ | **8 种**：`byte/short/int/long`（整型）、`float/double`（浮点）、`char`（字符）、`boolean`。占 1/2/4/8 字节不等；`boolean` 未规定大小。它们不是对象，存**栈**上（或对象字段内）。 |
| 2 | 包装类（Wrapper）是什么？为什么要有？ | 8 个基本类型对应的**对象封装**（`Integer/Long/Boolean`…）。用于泛型、集合（`List<Integer>`）、可为 `null` 表达"无值"、以及提供工具方法（`Integer.parseInt`）。 |
| 3 | 什么是自动装箱/拆箱（Autoboxing）？ | 编译器自动在 primitive 与 Wrapper 间转换：装箱=`Integer.valueOf(i)`，拆箱=`intValue()`。是**语法糖**，运行期真实调用这两个方法。 |
| 4 | `Integer a=127,b=127; a==b`？`128` 呢？ | `127` 为 **`true`**、`128` 为 **`false`**。`Integer` 缓存 `-128~127`，装箱走 `valueOf` 命中缓存返回同一对象；超范围 new 新对象，`==` 比地址就不等。 |
| 5 | 基本类型和包装类 `==` 混用会怎样？ | 只要一边是 primitive，另一边包装类会**自动拆箱**成数值比较，比的是**值**，`Integer 1000 == int 1000` 为 `true`。两边都是包装类才比地址。 |
| 6 | `==` 和 `equals` 区别？ | `==`：基本类型比**值**，引用类型比**地址**（是否同一对象）。`equals`：`Object` 默认也是比地址，但常被重写为比**内容**（如 `String`）。 |
| 7 | String / StringBuilder / StringBuffer 区别？ | `String` **不可变**、每次拼接生成新对象；`StringBuilder` **可变、非线程安全、快**（首选）；`StringBuffer` 可变、`synchronized` **线程安全、略慢**。 |
| 8 | String 为什么不可变（immutable）？ | 内部 `char[]`（JDK9+ `byte[]`）被 `final` 且私有、不暴露修改方法。好处：可安全共享/做常量池、`hashCode` 可缓存、线程安全、适合做 Map key。 |
| 9 | 字符串常量池（String Pool）是什么？ | 存放字面量 `String` 的共享区（JDK7+ 在**堆**）。`"a"` 直接进池；`new String("a")` 在堆另建对象，`.intern()` 可手动入池/返回池中引用。 |
| 10 | `String s=new String("a")` 创建几个对象？ | **1 或 2 个**：常量池若无 `"a"` 会先建 1 个（池中），`new` 再在堆建 1 个；池中已存在则只 new 堆里 1 个。 |
| 11 | 重写 `equals` 为什么必须重写 `hashCode`？ | 契约：**equals 相等则 hashCode 必须相等**。否则两个"相等"对象散到不同桶，`HashMap/HashSet` 会**存重复、查不到**。 |
| 12 | `hashCode` 相等两对象一定 equals 吗？ | **不一定**。哈希会冲突，hashCode 相等只是"可能相等"，还需 `equals` 再确认；但 equals 相等 hashCode 一定相等。 |
| 13 | final / finally / finalize 区别？ | `final`：修饰类（不可继承）/方法（不可重写）/变量（常量）。`finally`：try 块**必执行**的收尾。`finalize`：`Object` 的回收前回调，**已废弃**（JDK9 deprecated），别用。 |
| 14 | 面向对象三大特性？ | **封装**（隐藏细节、暴露接口）、**继承**（复用扩展、is-a）、**多态**（同一调用不同实现，靠重写+向上转型，运行期动态绑定）。 |
| 15 | 重载（Overload）vs 重写（Override）？ | 重载：**同类**同名、**参数列表不同**（编译期静态绑定，与返回值/访问修饰无关）。重写：**子类**覆盖父类方法，签名相同、访问不能更严、异常不能更宽（运行期动态绑定）。 |
| 16 | 接口（interface）vs 抽象类（abstract class）？ | 接口：多实现、只能定义抽象/默认/静态方法（JDK8+）、字段默认 `public static final`；抽象类：单继承、可有构造/普通字段/普通方法、表达"is-a"。**能力用接口，共性模板用抽象类**。 |
| 17 | 4 种访问修饰符范围？ | `private`（本类）< `default`/包私有（同包）< `protected`（同包+子类）< `public`（全局）。默认（不写）是包级私有。 |
| 18 | `static` 关键字用途？ | 属**类**不属对象：静态变量（全类共享）、静态方法（不能访问实例成员/`this`）、静态代码块（类加载时执行一次）、静态内部类。 |
| 19 | 异常体系怎么分？ | 顶层 `Throwable`→ `Error`（JVM 级如 `OOM`，不该 catch）+ `Exception`。Exception 分**受检**（Checked，编译强制处理）和**非受检**（`RuntimeException`，运行期）。 |
| 20 | 受检 vs 非受检异常？ | 受检（`IOException/SQLException`）必须 try 或 `throws` 声明；非受检（`NPE/IllegalArgument/ArrayIndexOOB`）不强制，多是**编程 bug**。 |
| 21 | Java 是值传递还是引用传递？ | **只有值传递**。基本类型传值的拷贝；对象传的是**引用（地址）的拷贝**——能改对象内容，但重新赋值不影响原引用。 |
| 22 | 深拷贝 vs 浅拷贝？ | 浅拷贝：只复制对象本身，内部引用字段仍**指向同一对象**（`Object.clone` 默认）。深拷贝：连引用字段指向的对象也递归复制，两者**完全独立**。 |

## 📌 展开速答

**Q：Integer 缓存到底怎么回事？面试为什么老考 `==`？**
`Integer.valueOf` 内部维护 `-128~127` 的缓存数组（`IntegerCache`），装箱时命中范围返回**同一对象**，所以 `Integer a=100,b=100; a==b` 为 `true`；`127` 之外每次 `new` 新对象，`a==b` 为 `false`。`Long/Short/Byte/Character` 同样有缓存（`Character` 缓存 0~127），`Boolean` 缓存 `TRUE/FALSE`；`Float/Double` **没有缓存**。结论：**比较包装类内容永远用 `equals`，别用 `==`**。上界还能通过 `-XX:AutoBoxCacheMax` 调大。

**Q：为什么 String 拼接推荐 StringBuilder？循环里 `s += ...` 有什么问题？**
`String` 不可变，`s += x` 每次都 `new` 一个新对象再丢弃旧的，循环 N 次产生 N 个中间对象，时间 O(N²)、狂造垃圾。`StringBuilder` 内部维护可扩容 `char[]`，`append` 原地追加，O(N)。注意：**单行**常量拼接如 `"a"+"b"` 编译期就折叠成 `"ab"`（无开销）；**非循环**的少量拼接编译器也会自动用 `StringBuilder` 优化，不用手动改；**只有循环体内拼接**才必须手动 `StringBuilder`。多线程共享同一个可变缓冲区才用 `StringBuffer`，否则一律 `StringBuilder`。

**Q：equals 和 hashCode 的契约具体是什么？重写要注意什么？**
契约三条：①**一致性**——对象没变多次调用返回一致；②**equals 为 true → hashCode 必须相等**；③**hashCode 相等 → equals 不一定 true**（允许冲突）。破坏第②条最致命：`HashMap` 先用 hashCode 定位桶再用 equals 比对，两个业务相等但 hashCode 不同的对象会进不同桶，导致 `map.get(key)` 查不到、`Set` 存进重复元素。重写要点：equals 满足自反/对称/传递/一致/非空，`equals` 用到哪些字段，`hashCode` 就用**相同字段**计算（推荐 `Objects.hash(a,b)` 或 IDE 生成）。深挖 → [`../../java-learning`](../../java-learning)。

**Q：try-catch-finally 中 finally 和 return 的执行顺序？**
`finally` **几乎总会执行**（除非 `System.exit()`、JVM 崩溃、守护线程被杀）。顺序坑点：①`try` 里有 `return`，会**先算好返回值暂存**，再执行 `finally`，最后才真正返回；②若 `finally` 里也 `return`，会**覆盖** try/catch 的返回值（且吞掉异常）——**强烈不推荐在 finally 里 return**；③`try` 返回基本类型时，`finally` 改这个变量**不影响**已暂存的返回值（改的是副本）；返回可变对象引用时，`finally` 改对象内容**会影响**。资源关闭优先用 **try-with-resources**（`AutoCloseable`），比手写 finally 更安全。

**Q：泛型的类型擦除（Type Erasure）是什么？带来哪些坑？**
Java 泛型是**编译期**特性：编译后类型参数被"擦除"，`List<String>` 和 `List<Integer>` 运行期都是 `List`，`<T>` 擦成 `Object`（有界则擦成边界类型）。目的是兼容旧版本。副作用：①运行期拿不到泛型类型，`new T()`、`new T[]`、`T.class` 都不行；②不能 `instanceof List<String>`；③`List<String>` 和 `List<Integer>` 属**同一个** `Class`，不能重载区分；④能靠反射绕过泛型往集合塞异类型。想在运行期保留类型要用 `Class<T>` 参数或 `TypeReference` 技巧。

**Q：反射（Reflection）是什么？有什么代价？**
运行期动态获取类信息并操作：拿 `Class`（`.class`/`getClass()`/`Class.forName()`）后可读字段、调方法、`new` 实例、访问私有成员（`setAccessible(true)`）。是 Spring IoC/AOP、ORM、序列化、注解处理的底座。代价：①**慢**（跳过 JIT 优化、有安全检查，可缓存 `Method` 缓解）；②**破坏封装**、编译期不检查、易出运行时错；③新版模块系统（JPMS）下访问受限。面试加分：说清"框架靠它做动态装配，但业务代码别滥用"。

**Q：值传递再确认——为什么说 Java 没有引用传递？**
Java 方法传参永远拷贝一份**实参的值**。基本类型拷贝数值，方法内改副本不影响外面。对象类型拷贝的是**引用（地址）这个值**：形参和实参指向同一对象，所以方法内 `obj.setX()` 改内容外面可见（常被误认为"引用传递"）；但方法内 `obj = new X()` 只是让副本指向新对象，**原引用不变**——这正是"值传递"的证据。一句话："传的是引用的拷贝，不是引用本身。"

## ⚠️ 易错 / 反问加分

- ⚠️ **`Integer` 用 `==` 比较**是经典坑：`-128~127` 内看着对，超范围就 `false`，生产事故高发。**包装类比较一律 `equals`**（或先拆箱成 primitive）。
- ⚠️ **只重写 equals 不重写 hashCode**：编译不报错，但对象进 `HashMap/HashSet` 就出诡异 bug。用 IDE / `Objects.hash` 同时生成两者。
- ⚠️ **`finalize` 别用**：不保证被调用、不保证时机、拖慢 GC，JDK9 已 deprecated；释放资源用 try-with-resources 或 `Cleaner`。
- ⚠️ **`==` 比 `String` 内容**：`new String("a") == "a"` 为 `false`。比内容用 `equals`；防 NPE 用 `"常量".equals(变量)` 或 `Objects.equals(a,b)`。
- ⚠️ **`float/double` 无缓存也无法精确**：`0.1+0.2 != 0.3`，金额计算用 `BigDecimal`（且用字符串构造 `new BigDecimal("0.1")`）。
- ✅ **加分**：谈 String 不可变时带出"可缓存 hashCode、可做常量池共享、天生线程安全、适合当 Map key"，而不是只说"值不能改"。
- ✅ **加分**：谈泛型擦除时能举"为什么不能 `new T[]`、为什么 `List<String>` 和 `List<Integer>` 不能重载"，显示真踩过坑。
- ✅ **加分**：谈值传递时主动区分"改对象内容 vs 重新赋值引用"两种情况，比背结论强。
- ✅ **加分**：接口 vs 抽象类给一句选型口诀——"**定义能力/多继承用接口，抽公共模板/带状态用抽象类**（模板方法模式）"。
- 🔗 集合底层（HashMap 扩容/红黑树）→ 见 `03-collections`（本目录）；JVM 内存/类加载 → 链接 `../../jvm-learning`。
