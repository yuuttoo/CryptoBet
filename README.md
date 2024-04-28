# Crypto Bet


## Description
ETH Price Guessing Game, with bets placed in USDC.

After each round starts, Users can choose to bet on an increase or decrease, with a maximum bet amount of 10 USDC per bet.

Every two hours, a price quote will be fetched from Chainlink (due to Chainlink's current mechanism of only providing a new quote every hour if the price fluctuation is less than 0.5%), and compared to the previous quote. If the latest price is higher than the previous one, users who bet on Up will share the total prize pool of that round.

After the game starts, it will be locked two hours later based on the timestamp, and no more bets can be placed. During this stage, the prize calculation is performed. The game will close 30 seconds after the lock, during which the winning users can claim their prizes.


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
