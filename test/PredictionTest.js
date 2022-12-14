const {
  time,
  ether,
  constants,
  BigNumber,
  expectRevert,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect, assert } = require("chai");
const { ethers } = require("hardhat");



describe("Price Prediction", () => {

    
  async function deployFixture() {
    const GoerliEthUsdAddress = '0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e';// ETH/USD報價
    const usdcAddress = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
    const binanceHotWalletAddress = '0xF977814e90dA44bFA03b6295A0616a897441aceC';
    const [owner, betUpuser1, betUpuser2, betUpuser3, betDownuser4, betDownuser5, betDownuser6] = await ethers.getSigners();
    const DECIMALS = "8";//ETH/USD decimals 8
    const INITIAL_PRICE = "100000000000"//設置ETH初始價格1000
    //const INITIAL_PRICE = "60000000000"//設置ETH初始價格1000

    let usdc;

    //部署假chainlink
    const MockOracleFactory = await ethers.getContractFactory("MockV3Aggregator");
    const mockOracle = await MockOracleFactory.connect(owner).deploy(DECIMALS, INITIAL_PRICE);
    await mockOracle.deployed();
    console.log(`mockOracle deployed to ${mockOracle.address}`);

    //部署合約
    const predictionContractFactory = await ethers.getContractFactory("Prediction");
    const predictionContract = await predictionContractFactory.connect(owner).deploy(mockOracle.address,usdcAddress);
    await predictionContract.deployed();
    console.log(`Prediction contract deployed to ${predictionContract.address}`);

    //check forking by getting Binance USDC balance
    usdc = await ethers.getContractAt("ERC20", usdcAddress);
    let USDCofBinance = await usdc.balanceOf(binanceHotWalletAddress);
    console.log(`Binance wallet USDC balance: ${USDCofBinance}`); 

    //取得binance wallet 
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [binanceHotWalletAddress],
    });
  
    const binanceWallet = await ethers.getSigner(binanceHotWalletAddress);  

    //發1000 USDC給user
    let transferAmount = ethers.utils.parseUnits("1000", 6);//1000
    await usdc.connect(binanceWallet).transfer(betUpuser1.address, transferAmount);
    await usdc.connect(binanceWallet).transfer(betUpuser2.address, transferAmount);
    await usdc.connect(binanceWallet).transfer(betUpuser3.address, transferAmount);
    await usdc.connect(binanceWallet).transfer(betDownuser4.address, transferAmount);
    await usdc.connect(binanceWallet).transfer(betDownuser5.address, transferAmount);
    await usdc.connect(binanceWallet).transfer(betDownuser6.address, transferAmount);
    //let usdcOfcUsdc = await usdc.balanceOf(betUpuser1.address);
    //console.log(`USDC in betUpuser1 Amount:  ${usdcOfcUsdc}`);//1000000000
    //approve 合約使用user token
    await usdc.connect(betUpuser1).approve(predictionContract.address, transferAmount);
    await usdc.connect(betUpuser2).approve(predictionContract.address, transferAmount);
    await usdc.connect(betUpuser3).approve(predictionContract.address, transferAmount);
    await usdc.connect(betDownuser4).approve(predictionContract.address, transferAmount);
    await usdc.connect(betDownuser5).approve(predictionContract.address, transferAmount);
    await usdc.connect(betDownuser6).approve(predictionContract.address, transferAmount);


    return {owner, betUpuser1, betUpuser2, betUpuser3, betDownuser4, betDownuser5, betDownuser6, predictionContract, mockOracle, usdc};
  }

  it("should set the aggregator addresses correctly", async function() {//ok
    const {predictionContract, mockOracle} = await loadFixture(deployFixture);
    
    const response = await predictionContract.getPriceFeed();
    assert.equal(response, mockOracle.address);

  })

  it("Should get ETH price from Oracle", async function() {//ok
    const {predictionContract, mockOracle} = await loadFixture(deployFixture);

    //const priceConsumerResult = await predictionContract.getLatestPrice();
    //從合約抓
    const priceConsumerResult = await predictionContract.getLatestPrice();
    const priceConsumerResultPrice = ethers.BigNumber.from(priceConsumerResult[1]);//有兩個response index1才是price
    //console.log("priceConsumerResultPrice", priceConsumerResultPrice);
    
    //從mock oracle抓
    const priceFeedResult = ((await mockOracle.latestRoundData()).answer / 1e8);
    //console.log("ETH Price", priceConsumerResultPrice, priceFeedResult);
    
    assert.equal(priceConsumerResultPrice.toString(), priceFeedResult);

  })

  //檢查兩次oracle的roundId, 新的id需要比舊的大 否則無效
  it("Should update oracle roundID", async function() {//ok
    const {predictionContract, mockOracle} = await loadFixture(deployFixture);
    const priceConsumerResult = await predictionContract.getLatestPrice();
    const priceRoundId = ethers.BigNumber.from(priceConsumerResult[0]);

    const price1100 = 110000000000;//設ETH價格1100
    await mockOracle.updateAnswer(price1100);
    const updatedPriceConsumerResult = await predictionContract.getLatestPrice();
    const updatedPriceRoundId = ethers.BigNumber.from(updatedPriceConsumerResult[0]);

    //console.log("tt", x);
    //assert.equal(updatedPriceRoundId.toString(), priceFeedResult);
    //expect(priceRoundId.toString().toBeLessThan(updatedPriceRoundId.toString()));
    expect(priceRoundId).to.be.below(updatedPriceRoundId);

    //console.log("roundId", priceRoundId, updatedPriceRoundId);
  })


  it("Should transfer user bet amount", async function() {
    const {owner, betUpuser1, betUpuser2, betUpuser3, betDownuser4, betDownuser5, betDownuser6, predictionContract, mockOracle, usdc} = await loadFixture(deployFixture);
    const currentBetId = 0;
    
    await predictionContract.connect(betUpuser1).betUp(currentBetId, ethers.utils.parseUnits("10", 6));//需投注10USDC
    await predictionContract.connect(betUpuser2).betUp(currentBetId, ethers.utils.parseUnits("10", 6));
    await predictionContract.connect(betUpuser3).betUp(currentBetId, ethers.utils.parseUnits("10", 6));
    await predictionContract.connect(betDownuser4).betDown(currentBetId, ethers.utils.parseUnits("10", 6));
    await predictionContract.connect(betDownuser5).betDown(currentBetId, ethers.utils.parseUnits("10", 6));


    let UsdcBalanceOfPredictionContract = await usdc.balanceOf(predictionContract.address);
    //console.log(`USDC in betUpuser1 Amount:  ${UsdcBalanceOfPredictionContract}`); 
    //總投注金額 //5人下注 合約內此時應為50元
    assert.equal(ethers.BigNumber.from(UsdcBalanceOfPredictionContract), 50000000);

  })

  it("Should lock after bet open for 2 hours", async function() {
    const {owner, betUpuser1, betUpuser2, betUpuser3, betDownuser4, betDownuser5, betDownuser6, predictionContract, mockOracle, usdc} = await loadFixture(deployFixture);
    //const price1000 = 100000000000;

    const price800 = 80000000000;
    await mockOracle.updateAnswer(price800);

    const currentBetId = 0;
    // const newerBetId = 1;

    await predictionContract.connect(owner)._openBet(currentBetId);

    await predictionContract.connect(betUpuser1).betUp(currentBetId, ethers.utils.parseUnits("10", 6));//需投注10USDC
    await predictionContract.connect(betUpuser2).betUp(currentBetId, ethers.utils.parseUnits("10", 6));
    await predictionContract.connect(betUpuser3).betUp(currentBetId, ethers.utils.parseUnits("10", 6));
    await predictionContract.connect(betDownuser4).betDown(currentBetId, ethers.utils.parseUnits("10", 6));
    await predictionContract.connect(betDownuser5).betDown(currentBetId, ethers.utils.parseUnits("10", 6));
    

    // advance time by 2 hours and lock bet 
    await ethers.provider.send("evm_increaseTime", [2 * 60 * 60]); 
    await predictionContract.connect(owner)._lockBet(currentBetId);//結算獎勵在此階段處理
    //advance 30 seconds to close bet 
    await ethers.provider.send("evm_increaseTime", [30]); 
    await predictionContract.connect(owner)._closeBet(currentBetId);
  
  })

  it("Should be able to claim reward", async function() {
    const {owner, betUpuser1, betUpuser2, betUpuser3, betDownuser4, betDownuser5, betDownuser6, predictionContract, mockOracle, usdc} = await loadFixture(deployFixture);

    const price800 = 80000000000;
    await mockOracle.updateAnswer(price800);

    const currentBetId = 0;

    await predictionContract.connect(owner)._openBet(currentBetId);

    await predictionContract.connect(betUpuser1).betUp(currentBetId, ethers.utils.parseUnits("10", 6));//需投注10USDC
    await predictionContract.connect(betUpuser2).betUp(currentBetId, ethers.utils.parseUnits("10", 6));
    await predictionContract.connect(betUpuser3).betUp(currentBetId, ethers.utils.parseUnits("10", 6));
    await predictionContract.connect(betDownuser4).betDown(currentBetId, ethers.utils.parseUnits("10", 6));
    await predictionContract.connect(betDownuser5).betDown(currentBetId, ethers.utils.parseUnits("10", 6));
    

    // advance time by 2 hours and lock bet 
    await ethers.provider.send("evm_increaseTime", [2 * 60 * 60]); 
    await predictionContract.connect(owner)._lockBet(currentBetId);//結算獎勵在此階段處理
    //advance 30 seconds to close bet 
    await ethers.provider.send("evm_increaseTime", [30]); 
    await predictionContract.connect(owner)._closeBet(currentBetId);

    //await predictionContract.connect(betDownuser5).claim()
    let usdcOfbetDownuser5Before = await usdc.balanceOf(betDownuser5.address);//原有 990USDC
    //console.log(`betDownuser5 Before USDC balance: ${usdcOfbetDownuser5Before}`); 
    await predictionContract.connect(betDownuser5).claim([0]);
    let usdcOfbetDownuser5After = await usdc.balanceOf(betDownuser5.address);//提領25USDC獎金後 1015USDC
    //console.log(`betDownuser5 After USDC balance: ${usdcOfbetDownuser5After}`); 

    //提領獎金之前餘額 < 提領後
    expect(usdcOfbetDownuser5Before).to.be.below(usdcOfbetDownuser5After);

  
  })

  }  
)
