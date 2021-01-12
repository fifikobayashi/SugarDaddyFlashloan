require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
var HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  solidity: "0.6.12",
  networks: {
    kovan: {
      url: `https://kovan.infura.io/v3/` + process.env.INFURA_PROJECT_ID,
      accounts: [`0x`+process.env.KOVAN_PRIVATE_KEY]
    }
  }
};
