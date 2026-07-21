# 04 · 智能合约安全 速答（Smart Contract Security）

> Web3 面试**头号重灾区**——合约漏洞 = 真金白银直接被掏空，链上代码不可改、一切公开，面试官要确认你"不会写出一键被抽干的合约"。覆盖 12 类高频漏洞 + CEI/重入锁/最小权限/预言机等防御体系，30+ 考点。
> 深度可运行 PoC（攻击者合约 + 修复对照 + 审计工具）见 [`../../web3-learning/04-smart-contract-security`](../../web3-learning/04-smart-contract-security)。

---

## 🔥 高频必背（漏洞清单 + 一句话原理 + 防御）

| # | 漏洞 | 一句话原理 | 一句话防御 |
|---|---|---|---|
| 1 | **重入 Reentrancy** | 先转账后改状态，外部合约在 `fallback` 里递归回调把余额反复取空 | **CEI 检查-生效-交互** + `nonReentrant` 重入锁 + pull 取代 push |
| 2 | **整数溢出/下溢** | `uint` 越界回绕：`0-1=2²⁵⁶-1`、`max+1=0` | Solidity **0.8+ 默认检查**（回退 revert）；0.8 前用 `SafeMath` |
| 3 | **tx.origin 钓鱼** | 用 `tx.origin` 鉴权，被诱导调用恶意合约时 origin 仍是你 | **鉴权只用 `msg.sender`**，`tx.origin` 仅用于"是否 EOA"判断且慎用 |
| 4 | **权限控制缺失** | 敏感函数无 `onlyOwner`、`initialize` 未加锁、owner 未初始化可被抢占 | 最小权限 + OZ `Ownable`/`AccessControl` + 初始化函数加 `initializer` |
| 5 | **随机数不安全** | `block.timestamp`/`blockhash`/`prevrandao` 可被矿工/验证者操纵或预测 | 链下 **Chainlink VRF**（可验证随机）或 commit-reveal |
| 6 | **DoS 拒绝服务** | 无界循环 gas 耗尽；转账给一个必 revert 的地址阻断整个流程 | 循环改 pull 分批领取；push 转账用 `call` 且失败不阻断主流程 |
| 7 | **delegatecall 风险** | 借调用者存储上下文执行；存储布局错位或 delegatecall 到不可信代码=改你的状态 | 代理与逻辑合约**存储布局严格对齐**；只 delegatecall 可信合约，用 OZ 代理 |
| 8 | **闪电贷攻击** | 同一交易内无抵押借出巨额资金，操纵市场/预言机后原子归还 | 不用可被瞬时操纵的价格源；关键操作加时间维度（TWAP） |
| 9 | **预言机价格操纵** | 直接读 DEX 现货 `getReserves()` 即时价，闪电贷一笔就能拉爆 | **TWAP 时间加权** + Chainlink 去中心化喂价 + 多源取中位数 |
| 10 | **抢跑 Front-running（MEV）** | 交易在 mempool 公开，机器人看到你的高收益交易抢先/夹击（三明治） | commit-reveal 隐藏意图、设滑点上限、私有 mempool（Flashbots） |
| 11 | **未检查返回值** | `.send()`/低级 `call` 失败只返回 false，不 revert，误以为成功 | 检查返回值 `require(ok)`，或用会自动 revert 的方式 |
| 12 | **签名重放 Replay** | 同一签名在多链/多次被重复提交 | 签名内含 `nonce` + `chainid` + 合约地址，用后作废 |

> 背诵口诀：**重入先改状态、算术升 0.8、鉴权用 sender、随机找 VRF、价格用 TWAP、转账走 pull、代理对齐布局、外部查返回值。**

---

## 📌 展开速答（重点漏洞详解）

### 1. 重入攻击 Reentrancy（★最经典，必被问）

**原理**：合约先给外部地址转账、后更新自己的状态。转账（`call`）会把控制权交给对方，若对方是合约，其 `receive`/`fallback` 可在状态更新前**再次调用**取款函数，形成递归，把资金反复抽走。**2016 The DAO 事件**被盗约 360 万 ETH，直接导致以太坊硬分叉（ETH / ETC 分家）。

漏洞版（先转账，后改状态）：

```solidity
function withdraw() external {
    uint bal = balances[msg.sender];
    (bool ok, ) = msg.sender.call{value: bal}("");  // ① 转账 → 回调攻击者
    require(ok);
    balances[msg.sender] = 0;                        // ② 太晚了，已被递归抽空
}
```

修复版（CEI：Checks-Effects-Interactions，先改状态再转账）：

```solidity
function withdraw() external nonReentrant {   // 双保险：加重入锁
    uint bal = balances[msg.sender];
    require(bal > 0);            // Checks 检查
    balances[msg.sender] = 0;    // Effects 生效（先清零！）
    (bool ok, ) = msg.sender.call{value: bal}("");  // Interactions 交互（最后）
    require(ok);
}
```

**三层防御**：
1. **CEI 模式**（首选）——所有状态修改放在外部调用之前。
2. **重入锁** OZ `ReentrancyGuard` 的 `nonReentrant` modifier（用一个 status 标志位，进入置锁、退出解锁）。
3. **Pull over Push**——不主动给用户转账，让用户自己来 `withdraw`，把转账分散到独立交易。
- 进阶：**跨函数重入**（withdraw 回调进 transfer）、**只读重入 read-only reentrancy**（回调时读到过期状态被其他协议误用）——所以锁要覆盖同一状态的所有入口。

### 2. 整数溢出 / 下溢 Overflow / Underflow

**原理**：EVM 整数定长回绕。`uint8` 最大 255，`255+1=0`；`0-1=255`。攻击者构造下溢让余额变成天文数字。
- **Solidity 0.8.0 起**：算术默认带溢出检查，越界自动 `revert`——这是分水岭。
- **0.8 之前**：必须用 OpenZeppelin **`SafeMath`**（`add`/`sub`/`mul` 内部 require 检查）。
- **0.8+ 反向坑**：确定安全且要省 gas 时才用 `unchecked { ... }` 块跳过检查——面试常问"为什么用 unchecked"，答"循环计数器等已证明不会溢出的场景省 gas，但要人工确保安全"。

```solidity
// 0.8 前：balances[msg.sender] -= amount;  // amount 超额 → 下溢成巨大值
// 0.8 前修复：balances[msg.sender] = balances[msg.sender].sub(amount); // SafeMath
// 0.8+：直接减，越界自动 revert
```

### 3. tx.origin 钓鱼

**原理**：`tx.origin` = 整条调用链最初的 EOA；`msg.sender` = 直接调用方。用 `tx.origin` 鉴权时，攻击者诱导 owner 调用其恶意合约，恶意合约再回调你的合约，`tx.origin` 仍是 owner，鉴权通过 → 被盗。

```solidity
// 漏洞：require(tx.origin == owner);   ❌ 会被中间恶意合约钓鱼
// 修复：require(msg.sender == owner);  ✅ 只认直接调用方
```

**结论**：**鉴权永远用 `msg.sender`**。`tx.origin` 唯一合理用途是"判断调用者是不是 EOA"（`msg.sender == tx.origin`），且账户抽象普及后连这个也不再可靠。

### 4. 权限控制缺失 Access Control

- **敏感函数忘加修饰符**：铸币/提现/自毁函数没有 `onlyOwner` → 任何人可调用（多起亿级被盗如 Parity 钱包 `selfdestruct`）。
- **初始化函数未加锁**：可升级合约的 `initialize()` 被人抢先调用把 owner 设成自己 → 用 OZ `Initializable` 的 `initializer` modifier。
- **owner 默认零地址**：构造时没设 owner。
- **防御**：OZ `Ownable`（单 owner）/ `AccessControl`（基于角色 RBAC，`onlyRole(MINTER_ROLE)`）；**最小权限原则**；权限变更走 `transferOwnership` 两步确认（`Ownable2Step`）；关键权限交多签 / 时间锁 Timelock。

### 5. 随机数不安全 Unsafe Randomness

**原理**：链上一切确定且公开，`block.timestamp`、`blockhash`、`block.prevrandao`(旧 `difficulty`)、`blockhash(block.number-1)` 都能被**矿工/验证者操纵或提前预测**——用它抽奖/发 NFT 会被薅。

```solidity
// 漏洞：uint r = uint(keccak256(abi.encode(block.timestamp, msg.sender))) % 100; ❌
// 修复：用 Chainlink VRF —— 链下生成随机数 + 密码学证明，回调写回，不可预测不可操纵
```

**防御**：**Chainlink VRF**（Verifiable Random Function，可验证随机数，业界标准）；或 **commit-reveal**（先提交哈希承诺、后揭示，双方都无法单方操纵）。

### 6. DoS 拒绝服务

两种典型：
- **无界循环耗 gas**：遍历一个可被无限增长的数组（如所有参与者退款），数组够大时函数永远超区块 gas 上限 → 卡死。**改成 pull 模式**：记账后让每人自己来领。
- **revert 阻断**：给一组地址逐个 push 转账，其中一个是"收到就 revert"的恶意合约 → 整个循环回滚，谁都拿不到。**用 `call` 且单个失败不中断**，或改 pull。
- 还有 **gas 竞价 DoS**、**区块填充**、**外部依赖卡死**（依赖的合约被 `selfdestruct`）。

### 7. delegatecall 风险（代理合约核心）

**原理**：`delegatecall` 借**调用者的存储上下文**执行目标合约代码——`msg.sender`/`msg.value`/storage 都是调用方的。这是**可升级代理**的基石，但两大坑：
- **存储布局错位**：代理和逻辑合约的状态变量顺序/槽位必须严格对齐，错位就会写乱数据（用 EIP-1967 固定槽存 implementation 地址避开冲突；OZ 用 `unstructured storage`）。
- **delegatecall 到不可信/可被替换的合约**：等于把自己存储的写权限交出去，可被改 owner、可 `selfdestruct`（Parity 二次事件冻结 51 万 ETH 就是库合约被人 `selfdestruct`）。

**防御**：用 OZ 经过审计的代理（Transparent / UUPS）；只 delegatecall 可信不可变的逻辑合约；理解并遵守存储布局规则、预留 `__gap`。

### 8. 闪电贷攻击 Flash Loan

**原理**：闪电贷允许在**同一笔交易内**无抵押借出巨额资金，只要交易结束前归还即可（否则整笔回滚）。本身不是漏洞，但它把"操纵市场需要巨额本金"的门槛降为零 → 成为**放大器**：借钱 → 砸盘/拉盘操纵 DEX 现货价 → 攻击读该价格的协议（借贷、清算、铸稳定币）→ 获利 → 原子还款。多起 DeFi 亿级被盗（bZx、Harvest、Cheese Bank…）本质都是"闪电贷 + 预言机操纵"组合拳。

**防御**：核心不是防闪电贷，而是**别用能被单笔交易操纵的价格源**（见 #9）；关键状态引入时间维度；对同区块内的价格突变加保护。

### 9. 预言机价格操纵 Oracle Manipulation

**原理**：合约直接读某个 DEX 池子的**即时现货价**（`getReserves()` 算 `reserve1/reserve0`），而 AMM 现货价可被一笔大额 swap（配合闪电贷）瞬间拉飞 → 依赖此价的清算/借贷被套利。

**防御**：
- **TWAP（Time-Weighted Average Price 时间加权平均价）**——取一段时间的累积均价，操纵一个区块不够，要持续多区块极其昂贵（Uniswap V2/V3 提供累积价格）。
- **去中心化预言机 Chainlink**——多节点聚合链下多交易所价格，喂到链上。
- **多源 + 中位数**、偏离阈值熔断、心跳过期检查。
- 面试金句："**永远不要用单个 DEX 池的现货价当预言机**。"

### 10. 抢跑 Front-running / MEV

**原理**：交易进 mempool 后公开可见，出块前有排序空间。**MEV**（Maximal Extractable Value）机器人可：**抢跑**（复制你的套利交易、加高 gas 抢先）、**三明治夹击 sandwich**（在你买入前后各插一笔，抬价卖给你）、**清算抢跑**。
**防御**：commit-reveal 隐藏交易意图；交易设**滑点上限 `amountOutMin`**、`deadline`；用私有 mempool / Flashbots Protect 提交；批量拍卖（frequent batch auction）；设计上避免"看到即可无风险套利"的窗口。

### 11 & 12. 未检查返回值 / 签名重放（简版）

- **未检查返回值**：`addr.send(x)` 和低级 `addr.call{value:x}("")` 失败**只返回 false 不 revert**，忘检查就误判成功。修复：`(bool ok,)=...; require(ok);`。（`transfer` 会自动 revert 但固定 2300 gas，Istanbul 后不再推荐）。
- **签名重放 Replay**：链下签名授权（如 permit、meta-tx）若不含 `nonce`/`chainid`/合约地址，可被重复提交或跨链重放。修复：签名内容绑定 `nonce`（用后递增作废）+ `block.chainid` + `address(this)`，参考 EIP-712 结构化签名。

---

## ✅ 安全最佳实践清单（可当收尾话术背）

```
1. CEI 模式        —— 状态修改永远在外部调用之前（防重入第一原则）
2. 重入锁          —— 有外部调用/转账的函数加 nonReentrant
3. 最小权限        —— 敏感函数 onlyOwner/onlyRole；关键权限交多签+Timelock
4. 用 OpenZeppelin  —— 别手写 ERC20/Ownable/代理，用审计过的标准库
5. Solidity 0.8+   —— 拿默认溢出检查，unchecked 只在证明安全处用
6. Pull over Push   —— 让用户主动领，别在循环里主动转账（防 DoS+重入）
7. 检查返回值       —— 低级 call/send 后 require(ok)
8. 安全价格源       —— TWAP + Chainlink，杜绝单池现货价
9. 安全随机数       —— Chainlink VRF / commit-reveal
10. 充分测试        —— 单元/分支覆盖 + Foundry 模糊测试(fuzzing) + 不变量测试(invariant)
11. 静态分析        —— Slither / Mythril / Echidna 跑一遍
12. 专业审计+赏金    —— 上线前找审计公司 + 开 bug bounty，主网前先测试网灰度
```

> 工具与实操 PoC 见 [`../../web3-learning/04-smart-contract-security/10-audit-tools`](../../web3-learning/04-smart-contract-security/10-audit-tools)。

---

## ⚠️ 易错 / 反问加分

**易错点：**
- ❌ "0.8 之后就不用管溢出了" → 对，但 `unchecked{}` 块、以及类型**强转截断**（`uint256`→`uint8`）、除法**精度丢失**仍要小心。
- ❌ 把 `transfer`/`send` 当万能防重入 → 它靠 2300 gas 限制"顺带"防了重入，但**不可靠**（gas 成本会变、EIP-1884 已经打破过），正确姿势是 CEI+锁 + 用 `call`。
- ❌ 以为"我 private 变量别人看不到" → 链上存储**全部公开可读**，`private` 只是 Solidity 层面访问控制，不是加密；别往链上存明文密钥/密码。
- ❌ 混淆 `msg.sender` 与 `tx.origin`、混淆 `call`/`delegatecall`/`staticcall` 的上下文。
- ❌ 只测 happy path → 安全 bug 都在边界和恶意路径，要 fuzzing + 不变量测试。
- ❌ 重入只想到 ETH 转账 → **ERC777/回调型代币 `_beforeTokenTransfer`**、NFT `onERC721Received` 都是重入入口；还有**只读重入**。

**反问 / 加分金句：**
- "**代码即法律、部署即不可改**——所以安全左移，宁可上线晚也不带病上主网。"
- "防御纵深：**CEI（设计）→ ReentrancyGuard（代码）→ Slither/Foundry（工具）→ 审计+赏金（流程）→ 多签+Timelock+可暂停 Pausable（运维兜底）**，任何一层都不是银弹。"
- "**可升级性是双刃剑**：能修 bug，也意味着 owner 能改逻辑=中心化风险，所以升级权要交 Timelock+多签、并向社区公示。"
- "安全的本质是**信任边界**：每一次外部调用都是把控制权交出去，都要假设对方是恶意的。"
- 熟悉真实事件能加分：**The DAO（重入）、Parity（access control/delegatecall selfdestruct）、bZx/Harvest（闪电贷+预言机）、Nomad/Wormhole 跨链桥（校验缺陷）**。

---

> 深挖每类漏洞的攻击者合约 PoC 与修复对照：[`../../web3-learning/04-smart-contract-security`](../../web3-learning/04-smart-contract-security)
> · 重入 [`01-reentrancy`](../../web3-learning/04-smart-contract-security/01-reentrancy) · 权限 [`02-access-control`](../../web3-learning/04-smart-contract-security/02-access-control) · 溢出 [`03-integer-issues`](../../web3-learning/04-smart-contract-security/03-integer-issues) · tx.origin [`04-tx-origin-phishing`](../../web3-learning/04-smart-contract-security/04-tx-origin-phishing) · 随机数 [`05-unsafe-randomness`](../../web3-learning/04-smart-contract-security/05-unsafe-randomness) · 抢跑 [`06-front-running`](../../web3-learning/04-smart-contract-security/06-front-running) · DoS [`07-denial-of-service`](../../web3-learning/04-smart-contract-security/07-denial-of-service) · delegatecall [`08-delegatecall-storage`](../../web3-learning/04-smart-contract-security/08-delegatecall-storage) · 返回值 [`09-unchecked-external-call`](../../web3-learning/04-smart-contract-security/09-unchecked-external-call) · 审计工具 [`10-audit-tools`](../../web3-learning/04-smart-contract-security/10-audit-tools)
