# Sugar Daddy Flashloan

## Overview
> TLDR: You execute the flash loan, and the obligation to repay the flash debt at the end of the Tx is atomically tokenized onto someone else's contract.

From a high level perspective, you're essentially leveraging Aave V2's native credit delegation functionalities to execute a flash loan WITHOUT repaying the loan by the end of the tx. 

You instead atomically INCUR the debt repayment onto someone else (the SugarDaddy), whereby the repayment is tokenized onto the Sugardaddy in the form of a collateralized debt obligation (not to be confused with a wallstreet CDO), allowing you to 'settle' your flash loan and be on your merry ways, while daddy can pay it off in subsequent blocks.

![](https://github.com/fifikobayashi/SugarDaddyFlashloan/blob/main/SugarDaddyOverview_.PNG)

> Update: The Aave folks reached out to note that the call to setUserUseReserveAsCollateral() is redundant in V2 as it is called as part of the depositing process where appropriate. Code, diagram and readme updated.


## Execution Flow
From a technical perspective, the sequence of events are as follows:
1. The Sugarbaby and Sugardaddy both deploy their respective contracts
2. Sugardaddy calls the configureSugardaddy() function on their contract, passing in the following parameters:
```
address _sugarbaby : who they're benefacting for
address _flashAsset : the reserve asset to be delegated and also the collateral to be deposited
uint256 _depositAmount : the amount of collateral to be deposited by the sugardaddy
address _debtAsset : the corresponding debt token for the reserve asset to be incurred
uint256 _delegateAmount : sugardaddy's designated limit for the sugarbaby's spending spree
```
This function effectively deposits the specified asset into the lending pool, activates it for use as a collateral and then approves debt delegation from the Sugar Baby contract address against this collateral.

3. Sugarbaby calls executeFlashloan() on their contract, where the flash loan is set to mode 1 and onBehalfOf set to the Sugardaddy's contract address. This signals to the Aave platform that you're executing a non-traditional flash loan where the repayment will be incurred elsewhere under a stable interest rate.
4. Once the flashloan is complete, the Sugardaddy contract will now contain the debt tokens signifying the debt repayment obligation, which accrues interest over time.
5. The final step, which is up for you to code, is a timelock mechanism which enforces the Sugarbaby to return the flashloan capital back to the Sugardaddy, along with an additional yield on top, plus a 300bps cut of the net profit gained as part of this transaction.


## Getting Started
I switched from Truffle to Hardhat for this repo so if you haven't used it before have a look at their [quick start tutorial](https://hardhat.org/getting-started).

1. git clone https://github.com/fifikobayashi/SugarDaddyFlashloan
2. Install/configure hardhat
```
npm install --save-dev hardhat
then create your own .env file with your infura ID and Pk
```
3. Install dependencies
```
npm install --save-dev @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers
npm install dotenv
npm install --save truffle-hdwallet-provider
```
4. Compile the repo
```
npx hardhat compile
```
5. Deploy to Kovan
```
npx hardhat run scripts/deploy.js --network kovan
```
6. Send 4000 DAI to the SugarDaddy contract via metamask or something
7. Jump onto the kovan testnet
```
npx hardhat console --network kovan
```
8. Instantiate and configure SugarDaddy by depositing 2000 DAI to the lending pool, activating it as collateral but only approving half of it as debt delegation to Sugar Baby
```
const SugarDaddy = await ethers.getContractFactory("SugarDaddy")
const sugardaddyInstance = await SugarDaddy.attach("INSERT deployed SugarDaddy contract address")
await sugardaddyInstance.configureSugardaddy("INSERT deployed SugarBaby contract address", "0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD","2000000000000000000000", "0x447a1cC578470cc2EA4450E0b730FD7c69369ff3", "1000000000000000000000")
```
9. Instantiate SugarBaby and execute this non-traditional flashloan by flashing 1000 DAI and incuring the repayment debt onto Sugar Daddy
```
const SugarBaby = await ethers.getContractFactory("SugarBaby")
const sugarbabyInstance = await SugarBaby.attach("INSERT deployed SugarBaby contract address")
await sugarbabyInstance.executeFlashloan("0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD","1000000000000000000000","INSERT deployed SugarDaddy contract address")
```

## Conclusion

A successful execution on Kovan [looks like this](https://kovan.etherscan.io/tx/0x2270d6c9a068e1cfd5e0f17cb164f20351b91c18838cbb8dedef6ebbe776bde2), nothing _too_ exciting, but underneath the Aave V2 hood there's so much going on it's like a silent disco.

And as with all my samples, call rugPull() to drain all test ETH and tokens from the contract for subsequent reuse.

Anyway, have a go and if you run into any issues just jump on the Aave discord, I'm loitering in there every now and again.

If you've found this useful and would like to send me some gas money:


```
0xef03254aBC88C81Cb822b5E4DCDf22D55645bCe6
```

Thanks, @fifikobayashi.
