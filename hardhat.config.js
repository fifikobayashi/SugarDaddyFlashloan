require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
var HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  solidity: "0.6.12",
  networks: {
    kovan: {
      url: process.env.NODE_HTTP_URL,
      accounts: [`0x`+process.env.MAINNET_PRIVATE_KEY]
    }
  }
};
