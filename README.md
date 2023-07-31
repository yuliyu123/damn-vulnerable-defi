![](cover.png)

**A set of challenges to learn offensive security of smart contracts in Ethereum.**

Featuring flash loans, price oracles, governance, NFTs, lending pools, smart contract wallets, timelocks, and more!

## Play

Visit [damnvulnerabledefi.xyz](https://damnvulnerabledefi.xyz)

## Help

For Q&A and troubleshooting running Damn Vulnerable DeFi, go [here](https://github.com/tinchoabbate/damn-vulnerable-defi/discussions/categories/support-q-a-troubleshooting).

## Disclaimer

All Solidity code, practices and patterns in this repository are DAMN VULNERABLE and for educational purposes only.

DO NOT USE IN PRODUCTION.

## Solutions

https://github.com/bzpassersby/Damn-Vulnerable-Defi-V3-Solutions/


### 闪电贷相关

### unstoppable

目标：停止vault的合约功能。

vault flashloan 时候检查前后vault balance需要相等。因此向 vault contract 中多转入一个token改变 vault balance 即可.

### naive receiver

goal: drain all eth in user contract.

每次flashloan都会从receiver contract多收取 FIXED_FEE = 1 ether的fee。

receiver contract合约任何人都能调用。


### truster

goal: drain pool approved token.

`flashloan(0, ...)` 的时候可控参数：`amount, borrower, target, bytes calldata data, data` 传入 `IERC20(tokenAddress).approve(address,uint256)` 。
闪电贷函数执行完后再 `transferFrom(poolAddress, msg.sender, amount)` 即可转出所有 `approve` 给 `trusterLenderPool` 中的 `token`。

重点：闪电贷可控参数需要注意。


### side-entrance

goal: 零成本收取高额奖励。

SideEntranceLenderPool.deposit函数为业务代码。闪电贷的时候可以调用该函数，然后获取收益。

重点：闪电贷不能和业务结合在一起。

真实案列：https://github.com/SunWeb3Sec/DeFiHackLabs/tree/main/academy/onchain_debug/06_write_your_own_poc/

defrost_exp.sol


### the-rewarder

flashloan的时候可 rewardpool.deposit再收取奖励。得到奖励后再归还flashloan. 又是闪电贷和业务结合在一起的case.


### 闪电贷结合goverance

### selfie

goal: 合约具有goverance功能。attacker初始资金为0, 转出闪电贷合约中所有token.

闪电贷出半数以上token用于 `governance.queueAction(address(pool), 0, data)`, `data = abi.encodeWithSignature("emergencyExit(address)", player)` , 两天后再 `execute` 即可。


### 预言机相关

### puppet && puppet-v2

goal: 计算价格操纵，可借入更高资产受益。

价格依赖于pair合约的reserves 和token balance, 可通过flashloan pair中相关变量控制。


### puppet-v3

goal: 计算价格操纵，可借入更高资产受益。

https://systemweakness.com/damn-vulnerable-defi-v3-14-puppet-v3-solution-2bfb9f060c4a


### compromised

得到三个oracles中的两个key, 可改变exchange的报价。低价买入nft, 高价卖出。



### NFT相关

### free-rider

goal: 把nft全部转移到dev钱包，获取bounty。

FreeRiderNFTMarketplace.buyMany没有计算总共买的NFT所需要的资金，只计算一个。导致买一个的钱可以买多个。

todo: 为什么在uniswap.swap的回调中多出eth?

