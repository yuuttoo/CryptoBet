require("@nomicfoundation/hardhat-toolbox");
//import('hardhat/config').HardhatUserConfig
require('dotenv').config();
//console.log("test", process.env); // remove this after you've confirmed it is working



const ALCHEMY_API_KEY_MAINNET = process.env.ALCHEMY_API_KEY_MAINNET; 
const ALCHEMY_GOERLI_RPC_URL = process.env.ALCHEMY_GOERLI_RPC_URL; 

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;



module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        // settings: {
        //   optimizer: {
        //     enabled: true,
        //     runs: 1
        //   }
        // }
      },
    ],
  },
  networks: {// https://eth-goerli.alchemyapi.io/v2
    goerli: {
      url: `${ALCHEMY_GOERLI_RPC_URL}`,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
    },
    hardhat: {
      forking: {
        url: `https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY_MAINNET}`,
      }
    }
  },
  defaultNetwork: "hardhat",
  etherscan: {
    apiKey: {
        goerli: ETHERSCAN_API_KEY,
    },
  },
  mocha: {
    timeout: 200000, // 200 seconds max for running tests
  },

};
