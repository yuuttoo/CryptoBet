// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/AggregatorV3Interface.sol";



contract Prediction is Ownable, ReentrancyGuard { 
    using SafeERC20 for IERC20;

    IERC20 public token; 
    //變數
    AggregatorV3Interface internal priceFeed;
    uint256 constant entryFee = 0.01 ether;//基本入場費 
    uint256 roundId = 0; //紀錄場次 供oracle判斷次序
    uint256 totalBalance;
    
    // struct gameRecord {

    // }
    //每局開始需要紀錄: 開始時間、預計結束時間、賭金總和、mapping 正方地址、賭金、mapping負方賭金(struct)、上一場的結算price
    // （作為新局的price）
    
    //treasury庫為需要發出的獎金，待user claim時才計算累加的獎金有多少
    
    
    

    //chainlink地址

    /**
     * Network: Goerli
     * Aggregator: ETH/USD
     * Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
     */
    constructor(address _priceFeed) {
        //ETH / USD 
        priceFeed = AggregatorV3Interface(_priceFeed);
        //priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e)//Goerli
    }


    //_isContract check 
    //從chainlink拿data 
    //oracle 
    function getLatestPrice() public view returns (int) {
        (
          uint roundID, 
          int price, 
          uint startedAt, 
          uint timeStamp,
          uint80 answeredInRound 
        ) = priceFeed.latestRoundData();
        
        return price / 1e8;
    }

    //可開始進行遊戲
    function gameOpen() internal {
        roundId++;
    }

    //停止入金 處理狀態變數後再調用gameUnlock重新開放
    function gameLock() internal {}

    //開放入金 
    function gameUnlock() internal {}

    //一局結算 
    function gameClose() internal {}

    
    //for user 
    //入金(計算各個錢包地址入金金額）開始玩
    function betUp(uint256 _amount) external {
        require(_amount >= entryFee, "Minimal Entry Fee is 0.01 ETH");

    }

    function betDown(uint256 _amount)  external {
        require(_amount >= entryFee, "Minimal Entry Fee is 0.01 ETH");

    }


    //計時5分鐘or 更長
    function timeCounter() private {}
    //計算賠率（optional → 根據兩邊user的數量差異計算？）//計算贏家地址與獎金
    function winnerRewardCalculater() private {}
    
    //轉出賭金給贏家
    function payWinner() external {//要用claim 給user自己做 合約不能自己動作

    }

    //剩下的錢存在合約繼續下一場（或領出）
    function withdraw(uint256 _amount) external onlyOwner {
        totalBalance = IERC20(token).balanceOf(address(this));
        require(totalBalance >= _amount, "withdraw amount should less than total balance");
        IERC20(token).transfer(msg.sender, _amount);
    }

    //only wallet address can play
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }    
}