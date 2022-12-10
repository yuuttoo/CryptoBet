// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/AggregatorV3Interface.sol";



contract Prediction { 
    //變數
    AggregatorV3Interface internal priceFeed;
    uint256 constant entryFee = 0.01 ether;//入場費 可改 



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

    //入金(計算各個錢包地址入金金額）
    function deposit(uint256 _playAmount) public returns(bool){
        require(_playAmount > entryFee, "Minimal Entry Fee is 0.01 ETH");
        //紀錄user的投入金額（可能有人重複投 要++）
        //紀錄這場bet總額 totalSupply

    }
    
    //計時5分鐘or 更長
    function timeCounter() private {}
    //計算賠率（optional → 根據兩邊user的數量差異計算？）//計算贏家地址與獎金
    function winnerRewardCalculater() private {}
    
    //轉出賭金給贏家
    function payWinner() private {}

    //剩下的錢存在合約繼續下一場（或領出）
    function withdraw(uint256 _amout) private {}
}