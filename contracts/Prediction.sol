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
    uint256 betId = 0; //紀錄場次
    uint256 roundId = 0; //紀錄場次 供oracle判斷次序 需要從betId轉型？
    uint256 totalBalance;//供贏家提領的獎金餘額

    mapping(uint256 => mapping(address => UserRecord)) public userClaimProof; //user要領錢的比對證明，儲存玩了哪幾場、累積多少錢可以提領
    mapping(address => uint256[]) public userBets;//user參與過的局次 把參與過的roundId push 進去
    
    uint256 public constant gameIntervalSeconds = 30 seconds;//每局之間的間隔30秒
    
    enum Position {//跌或漲
        Up,
        Down
    }

    //每局開始需要紀錄: 開始時間、預計結束時間、賭金總和、mapping 正方地址、賭金、mapping負方賭金(struct)、上一場的結算price
    // （作為新局的price）
    struct EachBetRecord {
        uint256 roundId; 
        uint256 startTime;
        uint256 endTime;
        uint256 lockTime;
        uint256 lastBetPrice;
        uint256 betDownUsers;
        uint256 betUpUsers;
        uint256 lastGameBetAmountBalance;
        uint256 totalBetAmount;//玩家投入的賭金 如果這場沒有贏家  會放到下一場
        uint256 totalReward;//本場總獎金 為lastGameBetAmountBalance + totalBetAmount
    }

    struct UserRecord { //user 投注每場的紀錄
        Position position;
        uint256 amount;//金額
        bool claimed; //是否已領取獎金
    }



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
    

    //treasury庫為需要發出的獎金，待user claim時才計算累加的獎金有多少 最後才transfer
    function calim() public {
        //for loop查詢msg.sender的game record 
        //加總每場的reward 
        //require 獎金池比reward 多
        //改user狀態 池子金額
        //transfer 
    }


    //剩下的錢存在合約繼續下一場（或領出）
    function withdraw(uint256 _amount) external onlyOwner { //保留由平台方提領
        totalBalance = IERC20(token).balanceOf(address(this));
        require(totalBalance >= _amount, "withdraw amount should less than total balance");
        IERC20(token).transfer(msg.sender, _amount);
    }

    //only wallet address can play
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }    
}