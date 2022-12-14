# Crypto Bet


## Description
ETH價格競猜遊戲，賭金為USDC。

每場開局後User可以選擇要下注漲或跌，每注金額限制為10USDC。

每兩小時會從Chainlink獲取一次報價(因chainlink目前機制為波動小於0.5%只會每小時報價一次)，並與前次報價相比，最新價格若比前次高，下注Up方的user可以平分本局遊戲下注總獎金。


遊戲開局後會根據timestamp設定2小時後進行鎖定，不能繼續下注，此階段進行獎金結算。
並在鎖定後30秒關閉，此階段獲勝的user可以透過Claim提領獎金。


## Hardhat 指令

```shell
npx hardhat help
npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```
