# 06 · Web3 / 区块链开发面试 ⛓️

> **定位：程序员做 Web3 / 智能合约开发**该被问的题——不考密码学证明、不推共识数学，考的是**懂原理 + 会写合约 + 知道安全坑 + 能落地 dApp**。
> 深度实现见 [`../../web3-learning`](../../web3-learning)（区块链基础/以太坊/Solidity/合约安全/代币标准/dApp 全栈，12 工程）。本册只做**面试速答 + 怎么答 + 易错加分**。

---

## 🧭 Web3 面试考什么

| 维度 | 说明 |
|---|---|
| **懂原理** | 区块链为什么防篡改、以太坊账户/Gas/EVM、共识 PoW vs PoS |
| **会写合约** | Solidity 语法核心：storage/memory/calldata、可见性、modifier、event、fallback/receive |
| **知道安全** | 重入、整数溢出、tx.origin、权限、随机数、闪电贷——合约漏洞=真金白银损失，安全是重灾区 |
| **能落地** | 代币标准 ERC20/721/1155、DeFi(AMM/预言机)、前端连链、Gas 优化 |

> 一句话：面试官想确认你**不会写出一个能被一键掏空的合约**，并且理解链上"代码即法律、部署不可改、一切公开"的约束。

---

## 📚 题库地图（按主题，⭐=面试频率）

图例：✅ 已写 · ⬜ 待生成（告诉我编号即可按序补）

| 编号 | 文件 | 主题 | 覆盖的高频问题 | 频率 | 状态 |
|---|---|---|---|:--:|:--:|
| 01 | [`01-blockchain-basics.md`](01-blockchain-basics.md) | **区块链基础** | 哈希/区块结构/默克尔树/防篡改/共识 PoW·PoS/去中心化/公私钥/钱包 | ⭐⭐⭐ | ✅ |
| 02 | [`02-ethereum.md`](02-ethereum.md) | **以太坊核心** | 账户模型(EOA vs 合约)/交易/Nonce/Gas·gasPrice/EVM/状态树/L1·L2 | ⭐⭐⭐ | ✅ |
| 03 | [`03-solidity.md`](03-solidity.md) | **Solidity 语言** | 数据位置 storage/memory/calldata、可见性、modifier、event、mapping、fallback/receive、继承 | ⭐⭐⭐ | ✅ |
| 04 | [`04-smart-contract-security.md`](04-smart-contract-security.md) | **合约安全**（★重灾区） | 重入攻击/整数溢出/tx.origin/权限/DoS/随机数/闪电贷/CEI·重入锁防御 | ⭐⭐⭐ | ✅ |
| 05 | [`05-token-defi.md`](05-token-defi.md) | **代币标准与 DeFi** | ERC-20/721/1155/AMM·Uniswap·恒定乘积/预言机/清算/Gas 优化 | ⭐⭐ | ✅ |

---

## 🔗 深度库对照

面试速答里点到为止的原理，去 [`../../web3-learning`](../../web3-learning) 看可运行 demo：
- 区块链基础 → [`01-blockchain-basics`](../../web3-learning/01-blockchain-basics)
- 以太坊 → [`02-ethereum`](../../web3-learning/02-ethereum) · Solidity → [`03-solidity`](../../web3-learning/03-solidity)
- 合约安全 → [`04-smart-contract-security`](../../web3-learning/04-smart-contract-security)
- 代币标准 → [`06-token-standards`](../../web3-learning/06-token-standards)
- 学习路线/教程 → [`00-learning-resources.md`](../../web3-learning/00-learning-resources.md)
