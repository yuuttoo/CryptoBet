const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Price Prediction", () => {
    
  async function deployFixture() {
    const GoerliEthUsdAddress = '0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e'
    const [deployer, owner, user] = await ethers.getSigners();

    const predictionContractFactory = await ethers.getContractFactory("Prediction");
    const predictionContract = await predictionContractFactory.connect(deployer).deploy(GoerliEthUsdAddress);
    //await predictionContract.deployed();
    console.log(`prediction Contract deployed to ${predictionContract.address}`);


    return {deployer, owner, user, predictionContract};
  }

  it("Should get ETH price from Chainlink Oracle", async function() {
    const {deployer, owner, user, predictionContract} = await loadFixture(deployFixture);
  

    let ethPrice = await predictionContract.connect(deployer).getLatestPrice();
    console.log(ethPrice)



    })
  }  
)