# CryptoBet: ETH Price Guessing Game

CryptoBet is an Ethereum-based decentralized application (DApp) that allows users to participate in an ETH price guessing game. Users can bet on whether the ETH price will increase or decrease within a specified time frame, using USDC as the betting currency.

## Contract Overview
The Prediction contract is the core of the CryptoBet application. It manages the game rounds, accepts user bets, and distributes rewards based on the price data fetched from Chainlink's decentralized oracle network.

## Key Features

### Fixed Bet Amount: 
Users can place a bet with a fixed amount of 10 USDC per round.

### Bet Positions: 
Users can choose to bet on either an increase (Up) or decrease (Down) in the ETH price.

### Chainlink Integration: 
The contract fetches the latest ETH/USD price data from Chainlink's decentralized oracle network to determine the round winners.

### Game Rounds: 
Each game round lasts for 2 hours, after which the contract locks the round, fetches the latest ETH price, and calculates the winners based on the price change.

### Reward Distribution: 
Winners share the total prize pool of the round proportionally based on their bet amounts.

### Claim Rewards: 
Users can claim their rewards for multiple rounds using a single transaction.

### Security: 
The contract incorporates Openzeppelin's ReentrancyGuard to prevent reentrancy attacks.

## Contract Deployment
The contract is deployed with the following constructor parameters:

1. _priceFeed: The address of the Chainlink ETH/USD price feed contract.
2. _token: The address of the USDC ERC20 token contract.

## Key Functions

### betUp(uint256 betId, uint256 _amount): Users call this function to place a bet on the ETH price increasing.
### betDown(uint256 betId, uint256 _amount): Users call this function to place a bet on the ETH price decreasing.
### claim(uint256[] calldata betIdArray): Users call this function to claim their rewards for one or more rounds.
### _openBet(uint256 currentBetId): The contract owner calls this function to open a new round.
### _lockBet(uint256 currentBetId): The contract owner calls this function to lock the current round and fetch the latest ETH price.
### _closeBet(uint256 currentBetId): The contract owner calls this function to close the current round and prepare for the next round.
### withdraw(uint256 _amount): The contract owner can call this function to withdraw USDC from the contract.

## Getting Started
To interact with the CryptoBet DApp, you'll need an Ethereum-compatible wallet (e.g., MetaMask) and some USDC tokens. Once you have your wallet set up, you can connect to the DApp and start participating in the game rounds.


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


## Hardhat command

```shell
npx hardhat help
npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```
