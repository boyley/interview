# 05 · 代币标准与 DeFi 速答（Token Standards & DeFi）

> 一句话定位：代币标准（ERC-20/721/1155）是链上资产的"接口协议"，DeFi 是在这些资产之上搭建的无许可金融乐高（做市、借贷、预言机、稳定币、质押）。覆盖 18 个高频考点。

---

## 🔥 高频必背（Top 10）

| # | 考点 | 一句话结论 |
|---|------|-----------|
| 1 | ERC-20 核心接口 | 同质化代币标准：`transfer / approve / transferFrom / allowance / balanceOf / totalSupply` |
| 2 | approve + transferFrom | 两步授权模式：先授权额度、再由第三方合约代扣，让合约能"主动拉钱" |
| 3 | ERC-721 | 非同质化 NFT，每个 `tokenId` 唯一；`ownerOf(id)` 查主人、`tokenURI(id)` 查元数据 |
| 4 | ERC-1155 | 多代币标准，一个合约同时管同质+非同质、支持批量转账、省 gas，游戏道具首选 |
| 5 | 无限授权风险 | `approve(spender, MAX)` 图省事，合约被攻破 = 你钱包被授权额度内的币全部转走 |
| 6 | AMM / 恒定乘积 | Uniswap 用 `x * y = k`，靠公式自动定价做市，取代订单簿 |
| 7 | 无常损失 | LP 提供流动性后，因币价相对变动，相比单纯持币产生的账面亏损 |
| 8 | 超额抵押 + 清算 | 借贷协议要求抵押 > 借出；健康因子跌破阈值触发清算 |
| 9 | 预言机 Oracle | 合约取不到链下数据，靠 Chainlink 喂价；防操纵用 TWAP 时间加权均价 |
| 10 | gas 优化 | `calldata` 代替 `memory`、打包 storage、减少 SSTORE、用 event 代替存储 |

---

## 📌 展开速答

### 一、ERC-20（同质化代币 Fungible Token）

**定位**：每一枚代币完全等价、可互换（1 USDT = 任何另 1 USDT），像货币。

**六个核心接口**：

| 接口 | 作用 |
|------|------|
| `totalSupply()` | 代币总发行量 |
| `balanceOf(addr)` | 查某地址余额 |
| `transfer(to, amt)` | 我把自己的币转给别人 |
| `approve(spender, amt)` | 授权 spender 可动用我 amt 额度 |
| `allowance(owner, spender)` | 查还剩多少授权额度 |
| `transferFrom(from, to, amt)` | spender 从 from 扣款转给 to（消耗额度） |

**approve + transferFrom 两步授权模式（必考）**：

```
为什么不能直接 transfer？
  因为 DeFi 合约需要"主动"从你钱包拉钱（如 Uniswap 换币、存款）。
  但合约不能凭空动你的余额 → 必须你先 approve 给它额度。

流程：
  ① 用户 approve(合约地址, 100)   // 我允许该合约最多花我 100 个
  ② 合约 transferFrom(用户, 池子, 100)  // 合约代扣，额度扣减
```

一句话背：**transfer 是自己转账；approve/transferFrom 是"授权额度 + 第三方代扣"，让智能合约能代替你花钱。**

### 二、ERC-721（非同质化代币 NFT）

**定位**：每个代币独一无二，用 `tokenId` 标识，不可拆分、不可互换（你的加密猫 ≠ 我的加密猫）。

| 接口 | 作用 |
|------|------|
| `ownerOf(tokenId)` | 谁拥有这个 NFT |
| `tokenURI(tokenId)` | 返回元数据 URL（图片/属性 JSON，通常指向 IPFS） |
| `balanceOf(addr)` | 某地址拥有的 NFT 数量（不是余额是个数） |
| `safeTransferFrom` | 安全转移，会检查接收方能否处理 NFT |

**与 ERC-20 区别**：ERC-20 靠 `balanceOf` 记数量；ERC-721 靠 `tokenId → owner` 映射记归属，每个 id 独立、带元数据。

### 三、ERC-1155（多代币标准 Multi-Token）

**定位**：一个合约里同时管理多种代币，既能发同质化（如金币 x1000）又能发非同质化（如唯一装备）。

**三大优势**：
- **一合约多币种**：`balanceOf(addr, id)`，用 `id` 区分不同代币。
- **批量操作**：`balanceOfBatch / safeBatchTransferFrom`，一次转多种，大幅省 gas。
- **游戏道具首选**：金币、材料、限定皮肤统一管理，无需为每种资产单独部署合约。

一句话背：**ERC-1155 = ERC-20 + ERC-721 合体 + 批量转账省 gas。**

### 四、DeFi 核心概念

**AMM 自动做市商（Automated Market Maker）**
- 取代传统订单簿，靠数学公式和流动性池自动定价、即时成交。
- **恒定乘积公式 `x * y = k`**（Uniswap V2）：池中两种代币储备量乘积恒定。买入 X 使 x 减少 → 价格上涨，滑点由此产生。
- **流动性池 LP**：用户存入等值两种币成为 LP，赚交易手续费，凭 LP token 赎回。
- **无常损失（Impermanent Loss）**：当池内两币价格比变动，LP 赎回时的价值 < 单纯持币价值。价格回到存入时点则损失消失（故称"无常"），不回则变永久损失。

**DEX vs CEX**

| 维度 | DEX（去中心化，如 Uniswap） | CEX（中心化，如 Binance） |
|------|------|------|
| 资产托管 | 用户自持私钥，非托管 | 交易所托管 |
| 撮合 | 链上合约 / AMM | 中心化订单簿 |
| 门槛 | 无需 KYC，连钱包即用 | 需注册 KYC |
| 风险 | 合约漏洞、无常损失 | 平台跑路/挤兑（FTX） |

**借贷协议（Aave/Compound）**
- **超额抵押**：想借 100 美元，需先抵押 > 100（如 150）美元资产，防坏账。
- **健康因子（Health Factor）**：抵押价值 × 清算阈值 / 借款价值，> 1 安全，< 1 触发清算。
- **清算（Liquidation）**：抵押品价格下跌导致健康因子跌破 1，清算人替借款人还债、折价拿走抵押品，协议给清算人奖励。

**预言机 Oracle**
- **痛点**：智能合约是封闭沙盒，无法主动读取链下数据（币价、天气、比赛结果）。
- **Chainlink**：去中心化预言机网络，多节点聚合喂价上链。
- **价格操纵防御**：单点现货价易被闪电贷瞬间拉盘操纵 → 用 **TWAP（时间加权平均价）**，取一段时间均价，攻击者需长时间维持操纵、成本极高。

**稳定币（Stablecoin）**

| 类型 | 代表 | 锚定机制 |
|------|------|---------|
| 法币抵押 | USDT / USDC | 中心化机构持有等额美元储备 |
| 加密超额抵押 | DAI | 抵押 ETH 等（如 150%）铸造，链上透明、去中心化 |
| 算法（高风险） | UST（已崩） | 靠算法调节供需，脱锚死亡螺旋 |

**质押 Staking**
- PoS 链把代币锁定参与网络共识/安全，获得出块奖励。
- 流动性质押（Lido）：质押 ETH 换 stETH，既拿收益又保留流动性可再参与 DeFi。

### 五、Gas 优化技巧（合约工程必考）

| 技巧 | 原理 |
|------|------|
| 用 `calldata` 代替 `memory` | 外部函数只读参数用 calldata，省去拷贝开销 |
| 打包 storage 变量 | 多个小变量塞进同一个 32 字节槽（如两个 uint128），少占 slot |
| 减少 SSTORE | 存储写入最贵（冷写 ~20000 gas），能算就别存、缓存到 memory 批量处理 |
| 用 event 代替存储 | 只需查询、不需链上计算的数据用 event 记录，log 远比 storage 便宜 |
| 短路 / 缓存数组长度 | 循环里 `arr.length` 提前缓存、避免重复 SLOAD |
| 用 `unchecked` | 确定不溢出时跳过 Solidity 0.8 的自动溢出检查 |

---

## ⚠️ 易错 / 反问加分

- **approve 无限授权是链上头号被盗原因**：很多 DApp 默认让你 `approve(MAX)`，一旦该合约有漏洞/被钓鱼，攻击者可在额度内转走你所有该代币。反问加分：应支持"按需授权"或用 `Permit`（EIP-2612 签名授权，无需单独发 approve 交易）+ 定期在 revoke.cash 撤销授权。
- **无常损失不是"手续费亏损"**：它是相对持币的机会成本，币价单边大涨/大跌时最严重；只有手续费收入 > 无常损失，做 LP 才划算。
- **balanceOf 在 20 和 721 里含义不同**：ERC-20 返回代币数量，ERC-721 返回持有 NFT 的个数（要拿具体归属得用 `ownerOf`）。
- **transfer 直接给合约地址可能丢币**：ERC-20 的 `transfer` 不检查接收方是否能处理代币，转错到不识别的合约会永久锁死；ERC-721/1155 的 `safeTransferFrom` 才有接收方检查（`onERC721Received`）。
- **预言机是 DeFi 最大攻击面**：历史大额被盗多源于喂价被闪电贷操纵（bZx、Harvest）。反问加分：现货价 vs TWAP vs Chainlink 去中心化喂价的取舍。
- **DAI 也可能脱锚**：2023 硅谷银行事件中 USDC 脱锚，因 DAI 大量以 USDC 抵押，DAI 被连带拖累——去中心化稳定币的抵押品若含中心化资产仍有传染风险。
- **区分 approve 授权额度 vs setApprovalForAll**：ERC-721/1155 的 `setApprovalForAll(operator, true)` 是"授权某地址操作你名下全部 NFT"，比 ERC-20 额度授权更危险，OpenSea 挂单钓鱼常利用它。

---

深挖细节见学习笔记：[../../web3-learning/06-token-standards](../../web3-learning/06-token-standards)
