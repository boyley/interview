# 03 · Solidity 语言 速答（Solidity）

> 面向 EVM 的静态类型合约语言：**代码即法律、部署难改、一切公开、每步花 Gas**。写合约的核心就是"省 Gas + 控可见性 + 管好状态"。覆盖 18 个高频考点。
> 深挖可运行 demo → [`../../web3-learning/03-solidity`](../../web3-learning/03-solidity)

---

## 🔥 高频必背（Top 8）

| # | 考点 | 一句话答案 |
|---|---|---|
| 1 | **storage/memory/calldata** | storage 永久上链**最贵**、memory 临时可改、calldata 只读**最省**；函数入参优先 `calldata` |
| 2 | **可见性 4 种** | public/external/internal/private；**private≠私密**，链上数据人人可读 |
| 3 | **payable/receive/fallback** | payable 才能收 ETH；receive 收**无 data** 的纯转账；fallback 兜底（无匹配函数/带 data） |
| 4 | **require/revert/assert** | require 校验入参、revert 主动回滚（**都退剩余 Gas**）；assert 查不变量、失败**耗尽 Gas** |
| 5 | **event + indexed** | 写日志给前端监听，比存 storage **便宜得多**；indexed 字段可被过滤检索（最多 3 个） |
| 6 | **mapping** | 键值表、**不可遍历**、无 length；查不到返回**类型默认值**（不是报错） |
| 7 | **modifier + `_`** | 复用校验逻辑，`_;` 是被修饰函数体的**占位符**；onlyOwner=校验 `msg.sender==owner` |
| 8 | **view/pure** | view 只读状态、pure 连读都不读；外部 call 调用**不花 Gas** |

---

## 📌 展开速答

### 1. 数据位置 storage / memory / calldata

| 位置 | 生命周期 | 可改 | Gas | 用在哪 |
|---|---|:--:|---|---|
| **storage** | 永久，写进链上状态 | ✅ | **最贵**（SSTORE ~20000/写） | 状态变量 |
| **memory** | 函数执行期临时 | ✅ | 中 | 函数内临时变量、返回值 |
| **calldata** | 只读的调用数据区 | ❌ | **最省**（免拷贝） | external 函数的引用类型入参 |

```solidity
// 入参用 calldata 省 gas（少一次 memory 拷贝）
function sum(uint[] calldata a) external pure returns (uint s) {
    for (uint i; i < a.length; i++) s += a[i];
}
// storage 引用是"指针"，改它就是改链上状态
function edit(uint i) external { User storage u = users[i]; u.age++; }
```

> 口诀：**入参 calldata、临时 memory、要留下 storage**。`string/bytes/数组/struct` 才需显式标位置；值类型（uint/bool/address）自动在栈上。

---

### 2. 变量与函数可见性

| 可见性 | 合约内 | 子合约 | 外部 | 备注 |
|---|:--:|:--:|:--:|---|
| **public** | ✅ | ✅ | ✅ | 状态变量自动生成同名 getter |
| **external** | ❌(需 `this.f()`) | — | ✅ | 只能外部调，大 calldata 更省 |
| **internal** | ✅ | ✅ | ❌ | 状态变量默认值 |
| **private** | ✅ | ❌ | ❌ | **仅当前合约**，子合约都不行 |

```solidity
uint private secret = 42; // 链上照样能读！
```

> **反问加分**：`private` 只是**编译期访问限制**，链上 storage 全部公开——任何人可用 `eth_getStorageAt` 读到。敏感数据（密码/密钥）**绝不能明文上链**，要存哈希或链下。

---

### 3. 状态变量与 storage 布局（slot）

- 状态变量按声明顺序打包进 **32 字节 slot（slot 0,1,2…）**。
- 小类型会**紧凑打包**进同一 slot（如两个 `uint128` 共用 1 个 slot）→ 合理排序变量可省 Gas。
- `mapping` / 动态数组的元素位置由 `keccak256(key . slot)` 计算，槽本身只占位。
- `constant` / `immutable` **不占 slot**：constant 编译期内联，immutable 存进字节码（构造时定值）。

```solidity
uint128 a; uint128 b; // ✅ 同一个 slot（打包）
uint128 c; uint256 d; uint128 e; // ❌ 各占一 slot，浪费
```

---

### 4. 函数修饰符 modifier

```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "not owner"); // 前置校验
    _;                                          // 函数体在此执行
    // 这里还能写后置逻辑
}
function withdraw() external onlyOwner { ... }
```

- `_;` 是**占位符**，代表被修饰函数的原始函数体插入的位置。
- 可放校验前、后或前后都放；多个 modifier 按书写顺序嵌套执行。
- 用途：权限（onlyOwner）、防重入（nonReentrant）、暂停（whenNotPaused）。

---

### 5. payable / receive / fallback（收 ETH）

| 成员 | 触发条件 | 说明 |
|---|---|---|
| **payable** | 函数标记后可随调用收 ETH | 没标 payable 的函数收到 ETH 会 revert |
| **receive()** | `msg.data` 为空的**纯转账** | `external payable`，无参无返回 |
| **fallback()** | 调了不存在的函数，或有 data 但无 receive | **兜底**，可 payable 可不 |

```solidity
receive() external payable {}                 // 纯转账走这里
fallback() external payable { emit Log(msg.data); } // 其它情况兜底
```

分发规则：**有 calldata → fallback；无 calldata → 有 receive 走 receive，否则走 fallback**。合约要能收裸转账，至少得有 `receive` 或 payable 的 `fallback`。

---

### 6. event 与 indexed

```solidity
event Transfer(address indexed from, address indexed to, uint value);
emit Transfer(msg.sender, to, amount);
```

- 日志写进**交易 receipt 的 logs**，前端/后端用 filter 监听，成本远低于 storage。
- `indexed` 字段进 **topics**（可被高效过滤检索），最多 **3 个**；非 indexed 进 data。
- 日志**合约自身读不到**，只供链下消费（The Graph、ethers 监听）。

> 加分：ERC-20 的 `Transfer`/`Approval` 是标准 event，钱包/浏览器靠它显示余额变动。

---

### 7. mapping（映射）

```solidity
mapping(address => uint) public balances; // 自动生成 balances(addr) getter
```

- **不可遍历**、无 `length`、无法取全部 key（要遍历需自己额外存一个数组）。
- 查不存在的 key **返回默认值**（uint→0、bool→false、address→0x0），不报错。
- 只能是 storage，不能作局部/入参/返回；可嵌套 `mapping(a=>mapping(b=>c))`。

---

### 8. require / revert / assert（校验回滚）

| 关键字 | 用途 | Gas 处理 | 场景 |
|---|---|---|---|
| **require(cond, msg)** | 校验输入/前置条件 | **退还**剩余 Gas | 参数、权限、余额 |
| **revert("msg")** / 自定义 error | 主动回滚、复杂分支 | **退还**剩余 Gas | if 分支里手动抛 |
| **assert(cond)** | 检查**永不该失败**的不变量 | **耗尽**全部 Gas（Panic） | 溢出后校验、内部 bug |

```solidity
error Unauthorized(address who);        // 自定义 error 比字符串省 Gas
if (msg.sender != owner) revert Unauthorized(msg.sender);
```

> 记忆：**require/revert 退 Gas（用户错），assert 吃 Gas（合约错，本不该发生）**。0.8+ 溢出/除零会自动触发 Panic（等价 assert）。

---

### 9. constructor（构造函数）

- 部署时**只执行一次**，用来初始化 owner、代币名等；执行完不再存在于合约。
- 可 payable（部署即可注资）；可带参数（部署时传入）。

```solidity
constructor(string memory _name) { owner = msg.sender; name = _name; }
```

---

### 10. 继承与 override / virtual

```solidity
contract A { function f() public virtual returns (uint) { return 1; } }
contract B is A { function f() public override returns (uint) { return 2; } }
```

- 父函数想被重写要标 **`virtual`**，子函数重写要标 **`override`**。
- 多继承线性化：`is A, B` 从右到左，`super.f()` 沿 **C3 线性化**链调用。
- 构造顺序按继承 DAG 从基类到派生类。

---

### 11. view / pure

| 修饰 | 能否读状态 | 能否写状态 | 外部调用 Gas |
|---|:--:|:--:|:--:|
| **view** | ✅ | ❌ | 免费（eth_call） |
| **pure** | ❌ | ❌ | 免费 |
| 普通 | ✅ | ✅ | 花 Gas |

> 注意：view/pure 只有**外部直接调**才免费；**合约内部调用**它们仍在同一交易里，一样耗 Gas。

---

### 12. address 与 address payable

- `address`：20 字节地址，有 `.balance`、`.code`。
- `address payable`：**能收 ETH**，多了 `.transfer()` / `.send()`。
- 转账三方式：`transfer`(2300 gas，失败 revert)、`send`(2300 gas，返 bool)、**`call{value:x}("")`**(转发全部 gas，**当前推荐**，需自查返回值 + 防重入)。

```solidity
(bool ok, ) = payable(to).call{value: amount}("");
require(ok, "transfer failed");
```

---

### 13. 全局变量：msg / block / tx

| 变量 | 含义 |
|---|---|
| `msg.sender` | **直接调用方**（EOA 或合约）；经过中转合约会变，别用 tx.origin 做鉴权 |
| `msg.value` | 本次调用附带的 ETH（wei），函数需 payable |
| `msg.data` | 完整 calldata |
| `block.timestamp` | 区块时间（秒）；矿工可小幅操纵，**别当随机数**/精确计时 |
| `block.number` | 区块高度 |
| `tx.origin` | 交易最初发起的 EOA；**钓鱼风险，禁用于权限判断** |

---

### 14. interface 与 abstract

| 类型 | 有实现 | 有状态变量 | 构造函数 | 用途 |
|---|:--:|:--:|:--:|---|
| **interface** | ❌ 全是声明 | ❌ | ❌ | 定义外部合约调用协议（如 IERC20） |
| **abstract** | 部分实现 | ✅ | ✅ | 提供部分逻辑+留抽象方法给子类 |

```solidity
interface IERC20 { function transfer(address to, uint amt) external returns (bool); }
IERC20(token).transfer(to, 100); // 按接口调用别人的合约
```

---

## ⚠️ 易错 / 反问加分

| 坑 / 追问 | 正解 |
|---|---|
| `private` 是隐私保护？ | ❌ 只是访问限制，链上 storage 全公开，`eth_getStorageAt` 直接读 |
| 用 `block.timestamp`/`blockhash` 做随机数？ | ❌ 可被矿工/攻击者操纵，链上无安全随机数，用 Chainlink VRF |
| 用 `tx.origin` 判断 owner？ | ❌ 钓鱼合约可冒充；鉴权一律用 `msg.sender` |
| 入参数组用 `memory`？ | external 函数用 **calldata** 更省（免拷贝）；只在需要修改时才 memory |
| assert 和 require 混用？ | require 校验外部输入（退 Gas）；assert 只查内部不变量（吃 Gas） |
| 循环里遍历 mapping？ | mapping **不可遍历**；需要遍历得额外维护 key 数组（注意 DoS 与 Gas 上限） |
| `transfer` 一定安全？ | 固定 2300 gas，接收合约逻辑复杂会失败；新代码用 `call` + **CEI/重入锁** |
| 状态变量顺序随便写？ | 小类型相邻可打包进同一 slot，乱序会多占 slot 浪费 Gas |
| 收不到别人转的 ETH？ | 缺 `receive`/payable `fallback`，裸转账会 revert |
| `string` 比较用 `==`？ | ❌ 不支持，需 `keccak256(bytes(a)) == keccak256(bytes(b))` |

**Gas 心智模型（一句话）**：storage 写最贵（尽量少写、能打包就打包）→ 用 event 代替不必要的存储 → 入参用 calldata → 常量用 constant/immutable → 自定义 error 替代 require 字符串。

---

> 深度实现 / 可运行合约 → [`../../web3-learning/03-solidity`](../../web3-learning/03-solidity)
> 上一册：[`02-ethereum.md`](02-ethereum.md) · 下一册（安全重灾区）：[`04-smart-contract-security.md`](04-smart-contract-security.md)
