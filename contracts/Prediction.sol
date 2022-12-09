// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/AggregatorV3Interface.sol";


contract Prediction { 
    //變數
    AggregatorV3Interface internal priceFeed;


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

    
    


    //計時5分鐘or 更長
    //計算賠率（optional → 根據兩邊user的數量差異計算？）
    //從chainlink拿data //https://www.youtube.com/watch?v=PSJarTvQvtE 
    //計算贏家地址與獎金
    //轉出賭金給贏家
    //剩下的錢存在合約（或領出）
}