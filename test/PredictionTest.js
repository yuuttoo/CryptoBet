const {
  time,
  ether,
  constants,
  BigNumber,
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






 


    return {owner, betUpuser1, betUpuser2, betUpuser3, betDownuser4, betDownuser5, betDownuser6, predictionContract, mockOracle};
  }

  it("should set the aggregator addresses correctly", async function() {//ok
    const {predictionContract, mockOracle} = await loadFixture(deployFixture);
    
    const response = await predictionContract.getPriceFeed();
    assert.equal(response, mockOracle.address);

  })

  it("Should get ETH price from Oracle", async function() {
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
  it("Should update oracle roundID", async function() {
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


  it("Should update ETH price from oracle with newer roundId", async function() {
    const {predictionContract, mockOracle} = await loadFixture(deployFixture);
  
  })

  }  
)
