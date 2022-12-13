// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "hardhat/console.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//import "./interfaces/AggregatorV3Interface.sol";




contract Prediction is Ownable, ReentrancyGuard { 
    using SafeERC20 for IERC20;
 
    IERC20 public token;  //USDC  //'0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'
    //變數
    AggregatorV3Interface internal priceFeed;
    

    uint256 public constant WAITING_PERIOD = 1 days;
    uint256 public constant gameIntervalSeconds = 30 seconds;//30秒為單位
    uint256 public constant FIXED_BET_AMOUNT = 0.01 ether; //限制每注金額 0.01ether
    //uint256 public constant minBetAmount = 0.01 ether ;//最小賭金 0.01 檢查一下decimal   
    //uint256 public constant maxBetAmount = 100 ether;// 最高賭金  檢查一下decimal               
    uint256 public currentBetId; //紀錄場次
    //uint256 public roundId; //紀錄場次 供oracle判斷次序 需要從betId轉型？
    uint256 public latestOracleRoundId; //從chainlink取得後轉型
    uint256 public totalBalance;//供贏家提領的獎金餘額
    uint256 public smallVault;//存放暫時未用到的資金

   
    mapping(uint256 => mapping(address => UserRecord)) public userBetProof; //總帳本 提供user要領錢的比對證明，儲存玩了哪幾場、累積多少錢可以提領
    mapping(uint256 => EachBetRecord) public allBetRecords;  //紀錄每回合資訊 使用id查詢 1個betId 存一組bet資訊
    mapping(address => uint256[]) public userBets;//user參與過的局次 把參與過的roundId push 進去
    
    
    enum Position {//跌或漲
        Up,
        Down
    }

    //每局開始需要紀錄: 開始時間、預計結束時間、賭金總和、mapping 正方地址、賭金、mapping負方賭金(struct)、上一場的結算price
    // （作為新局的price）
    //如果站在少數方 就會分到比較多 所以不是固定賠率 是把總獎金拿來分給參與人數
    struct EachBetRecord {
        uint256 betId;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 lockTimestamp;
        uint256 lastBetPrice;//前一局的ETH報價
        uint256 currentBetPrice;//本局lock時ETH報價
        uint256 betDownUsers;
        uint256 betUpUsers;
        uint256 lastGameBetAmountBalance;
        uint256 totalReward;//本場總獎金 為lastGameBetAmountBalance 
        uint256 rewardEachWinner;//每位贏家可分得獎金
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
    constructor(//global變數初始化
        address _priceFeed,
        IERC20 _token
        ) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        token = _token;
        currentBetId = 0;
        latestOracleRoundId = 0;
        totalBalance = 0;//供贏家提領的獎金USDC餘額 test時先給一筆錢 設定上限
    }


    //_isContract check 
    //從chainlink拿data 
    //oracle 
    function getLatestPrice() public view returns (uint80, int, uint) {//(uint80, int)
        (
          uint80 roundID, 
          int price, 
          uint startedAt, 
          uint timeStamp,
          uint80 answeredInRound 
        ) = priceFeed.latestRoundData();
        
        return (roundID, price, timeStamp);//目前ETH價格 / 1e8 取到小數點後8位避免波動過小沒有勝負
       
    }


    
    //for user 
    //入金(計算各個錢包地址入金金額）開始玩
    function betUp(uint256 betId, uint256 _amount) external {
        require(betId == currentBetId, "This Bet is not availble");
        require(_amount != FIXED_BET_AMOUNT, "Bet Amount should be 0.01 ETH");
        require(userBetProof[currentBetId][msg.sender].amount == 0, "Can only enter once on each bet");
        
        token.transferFrom(msg.sender, address(this), _amount);

        //更新每局紀錄資訊
        uint256 amount = _amount;
        EachBetRecord storage eachBetRecord = allBetRecords[betId];
        eachBetRecord.totalReward = eachBetRecord.totalReward + amount;
       
        eachBetRecord.betUpUsers += 1;


        //更新user state variable
        //總帳本
        UserRecord storage userRecord = userBetProof[betId][msg.sender];
        userRecord.position = Position.Up;
        userRecord.amount = amount;
        //紀錄user本次參與的賭局id
        userBets[msg.sender].push(betId);
    
    }

    function betDown(uint256 betId, uint256 _amount)  external {
        require(betId == currentBetId, "This Bet is not availble");
        require(_amount != FIXED_BET_AMOUNT, "Bet Amount should be 0.01 ETH");
        require(userBetProof[currentBetId][msg.sender].amount == 0, "Can only enter once on each bet");
        
        token.transferFrom(msg.sender, address(this), _amount);

        //更新每局紀錄資訊
        uint256 amount = _amount;
        EachBetRecord storage eachBetRecord = allBetRecords[betId];
        eachBetRecord.totalReward = eachBetRecord.totalReward + amount;
       
        eachBetRecord.betUpUsers += 1;


        //更新user state variable
        //總帳本
        UserRecord storage userRecord = userBetProof[betId][msg.sender];
        userRecord.position = Position.Up;
        userRecord.amount = amount;
        //紀錄user本次參與的賭局id //之後從這找地址 再回總帳本找資訊
        userBets[msg.sender].push(betId);
    }


    //計時5分鐘or 更長
    // function timeCounter() private {}
    //計算賠率（optional → 根據兩邊user的數量差異計算？）//計算贏家地址與獎金


    function RewardCalculater(uint256 _betId) internal {
        EachBetRecord storage eachBetRecord = allBetRecords[_betId];//抓局數資訊

        uint256 betUpUsersPerGame = eachBetRecord.betUpUsers;//獲取該局投注up人數
        uint256 betDownUsersPerGame = eachBetRecord.betDownUsers;//獲取該局投注down人數
        uint256 rewardPerGame = eachBetRecord.totalReward;//獲取該局總投注獎金
        
        
        //up 方勝 前局price < 此局price
        if(eachBetRecord.lastBetPrice < eachBetRecord.currentBetPrice) {
            //每位投注up的users可分得金額
            eachBetRecord.rewardEachWinner = rewardPerGame / betUpUsersPerGame;
        }
        //down 方勝
        else if(eachBetRecord.lastBetPrice > eachBetRecord.currentBetPrice) {
            //每位投注down的users可分得金額
            eachBetRecord.rewardEachWinner = rewardPerGame / betDownUsersPerGame;
        }
        //和局 (放到公積金smallVault)
        else {
            eachBetRecord.rewardEachWinner = 0;
            smallVault += rewardPerGame;
        }

            
    }
    

    //查詢該局需要發出的獎金， 最後才transfer
    function calim(uint256[] calldata betIdArray) external {//因為user可能玩超過一場，以betId array查詢場次
        uint256 rewardToClaim; //user可領取總金額 
        
        for(uint256 i = 0; i < betIdArray.length; i++) {
            //確認該場次id < 目前場次id 已經過去的局才能領取
            require(allBetRecords[betIdArray[i]].betId < currentBetId, "Bet not start yet");
            require(userBetProof[betIdArray[i]][msg.sender].claimed == false, "Not eligible for claim");
            uint reward; 
            //查詢該局每位贏家可領的reward
            reward = allBetRecords[betIdArray[i]].rewardEachWinner;
            
            //update user紀錄狀態為已提領
            userBetProof[betIdArray[i]][msg.sender].claimed = true;
            //加總獲勝局數可提領的獎金
            rewardToClaim += reward; 
        }
        //for loop 查詢&加總結束 轉錢給user
        if(rewardToClaim > 0) {
            token.transfer(msg.sender, rewardToClaim);
        }
    }


    //查詢user參與場數
    function getUserTotalBets(address user) external view returns (uint256) {
        return userBets[user].length;
    }

    //可開始進行遊戲
    //啟動每一輪遊戲前的狀態管理             
    function _gameOpen(uint256 betId) internal {
        EachBetRecord storage eachBetRecord = allBetRecords[betId];

        eachBetRecord.betId = betId;
        eachBetRecord.startTimestamp = block.timestamp;
        eachBetRecord.lockTimestamp = block.timestamp + gameIntervalSeconds;//30秒處理時間
        eachBetRecord.endTimestamp = block.timestamp + (2 * gameIntervalSeconds);//60秒處理
        


        //從oracle取得目前價格
        // (uint80 currentRoundId, int256 currentPrice) = getLatestPrice();
        // latestOracleRoundId = uint256(currentRoundId);//把oracle的id轉型為uint256

    }


    //賭局(每場賭局的生命週期循環）
    //開賭 可收賭金 處理狀態變數後再調用gameUnlock重新開放
    function _openBet() internal {

    }

    //停收賭金 抓oracle數值 更新本局機制status、莊家帳本、user帳本 
    function _lockBet() internal {}

    //結算 推進機制到下一場 機制歸零、帳本歸零 
    function _closeBet() internal {}


    //機制相關
    //暫停（沒事不會用） 中止倒數機制跟賭局進行
    function onPause() external onlyOwner {}

    //機制 resume(有暫停才會用到）
    function onResume() external onlyOwner {}

    //提領 
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