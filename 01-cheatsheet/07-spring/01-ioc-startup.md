# Spring IOC 容器启动流程

> **核心理念：Spring 启动就是一个 `refresh()` 方法，把「加载配置 → 注册 BeanDefinition → 实例化 → 依赖注入 → 初始化」这条流水线走完，最终得到一个装满单例 Bean 的可用容器。**
> 答题方法：先给两大阶段框架 → 讲 `refresh()` 核心步骤 → 下钻单个 Bean 的创建三步 → 补循环依赖。

---

## 一、整体框架（两大阶段，先立骨架）

```
配置(XML/注解) ─┐
                ├─►【阶段A：定义】解析成 BeanDefinition 注册到 BeanFactory（只有"图纸"，没造对象）
                │
                └─►【阶段B：实例化】refresh() 流水线：造对象 → 注入 → 初始化 → 放进单例池
                                                              │
                                                              ▼
                                                    装满单例 Bean 的容器（可用）
```

> 关键区分：**BeanDefinition（图纸）先注册，Bean（对象）后创建**。

---

## 二、核心入口 `refresh()` 的关键步骤（★ 大步骤）

两种容器（`ClassPathXmlApplicationContext` 走 XML、`AnnotationConfigApplicationContext` 走注解）最终都调用 `AbstractApplicationContext.refresh()`。它是**模板方法**，串起 12 步（挑重点）：

| 步 | 方法 | 干什么 |
|---|---|---|
| 1 | `prepareRefresh()` | 准备：记录启动时间、设状态、初始化环境变量 |
| 2 | `obtainFreshBeanFactory()` | 创建 `DefaultListableBeanFactory`，**加载解析配置 → 注册 BeanDefinition**（还没实例化） |
| 3 | `prepareBeanFactory()` | 配置 BeanFactory：类加载器、SpEL 解析器、注册内置 Bean |
| 4 | `postProcessBeanFactory()` | 留给子类扩展 |
| 5 | `invokeBeanFactoryPostProcessors()` | ★ 执行 **BeanFactoryPostProcessor**：`ConfigurationClassPostProcessor` 解析 `@Configuration/@ComponentScan/@Bean`、替换占位符；**可改 BeanDefinition** |
| 6 | `registerBeanPostProcessors()` | ★ 注册（还没执行）**BeanPostProcessor**：如 AOP 的 `AnnotationAwareAspectJAutoProxyCreator`、`@Autowired` 的处理器 |
| 7 | `initMessageSource()` | 国际化 |
| 8 | `initApplicationEventMulticaster()` | 事件广播器 |
| 9 | `onRefresh()` | 子类扩展（**Spring Boot 在这里创建内嵌 Tomcat！**） |
| 10 | `registerListeners()` | 注册事件监听器 |
| 11 | `finishBeanFactoryInitialization()` | ★★ **核心：实例化所有非懒加载单例 Bean**（`preInstantiateSingletons` → `getBean`） |
| 12 | `finishRefresh()` | 收尾：清缓存、发布 `ContextRefreshedEvent` |

> 记忆主线：**2 注册定义 → 5 改定义 → 6 备增强器 → 11 造 Bean → 12 发事件。**

---

## 三、单个 Bean 的创建流程（★ 小步骤：第 11 步内部 `doCreateBean`）

1. **实例化** — 反射调构造器创建对象（`createBeanInstance`），此时是"半成品"
2. **属性填充/依赖注入** — `populateBean`，`@Autowired`/`@Value` 在此注入
3. **初始化** `initializeBean`：
   - **Aware 回调**：`BeanNameAware`/`BeanFactoryAware`/`ApplicationContextAware`
   - **BeanPostProcessor.postProcessBeforeInitialization**（`@PostConstruct` 在此）
   - **初始化方法**：`InitializingBean.afterPropertiesSet` → `init-method`
   - **BeanPostProcessor.postProcessAfterInitialization**（★ **AOP 代理在这里生成**）
4. **放入单例池**（一级缓存 `singletonObjects`）

```
实例化 → 属性注入 → Aware → BPP.before → 初始化方法 → BPP.after(AOP) → 单例池
```

---

## 四、三级缓存与循环依赖（高频追问，简述）

| 缓存 | 存什么 |
|---|---|
| 一级 `singletonObjects` | 成品 Bean |
| 二级 `earlySingletonObjects` | 半成品（已实例化未初始化） |
| 三级 `singletonFactories` | 对象工厂（为提前生成 AOP 代理） |

> 原理：A 依赖 B、B 依赖 A 时，A 实例化后把"半成品引用"提前暴露到三级缓存，B 注入时能拿到 → 打破循环。**只能解决单例的字段/setter 循环依赖，构造器循环依赖无解。**

---

## 五、两种容器实现

| 容器 | 配置方式 | 说明 |
|---|---|---|
| `ClassPathXmlApplicationContext` | XML | 传统 |
| `AnnotationConfigApplicationContext` | 注解/JavaConfig | 主流 |

> 都继承 `AbstractApplicationContext`，核心都是同一个 `refresh()`。

---

> **核心原则：Spring 启动 = `refresh()` 一条流水线：加载 BeanDefinition → 执行 BeanFactoryPostProcessor(改定义) → 注册 BeanPostProcessor(备增强) → 实例化单例(实例化→注入→初始化，AOP 在初始化后置生成) → 发布事件。记住 refresh() 12 步 + Bean 创建三步 + 三级缓存。**

## 🔗 关联
- （待补）Bean 生命周期、循环依赖深挖、AOP 原理、Spring 事务、Spring Boot 自动配置
