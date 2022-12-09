require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();


/** @type import('hardhat/config').HardhatUserConfig */
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

//console.log("Log", ETHERSCAN_API_KEY, GOERLI_PRIVATE_KEY)


module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1
          }
        }
      },
    ],
  },
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: GOERLI_PRIVATE_KEY !== undefined ? [GOERLI_PRIVATE_KEY] : [],
    }
  },
  defaultNetwork: "hardhat",
  etherscan: {
    apiKey: {
        goerli: ETHERSCAN_API_KEY,
    },
  },
  // gasReporter: {
  //   enabled: REPORT_GAS,
  //   currency: "USD",
  //   outputFile: "gas-report.txt",
  //   noColors: true,
  //   // coinmarketcap: process.env.COINMARKETCAP_API_KEY,
  // },
  mocha: {
    timeout: 200000, // 200 seconds max for running tests
  },

};
