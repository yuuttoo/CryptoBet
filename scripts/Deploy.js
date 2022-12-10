const { ethers } = require("hardhat");


async function main() {
    const GoerliEthUsdAddress = '0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e'

    
    const predictionContractFactory = await ethers.getContractFactory("Prediction");
    const predictionContract = await predictionContractFactory.deploy(GoerliEthUsdAddress);
    await predictionContract.deployed();
    console.log(`prediction Contract deployed to ${predictionContract.address}`)
}

main()
.catch((error)=> {
    console.error(error);
    process.exitCode = 1;
})