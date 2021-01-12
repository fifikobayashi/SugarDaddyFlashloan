async function main() {

  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deployes the SugarDaddy contract passing in the Aave V2 Lending Pool and Protocol Data Provider addresses on Kovan
  const SugarDaddy = await ethers.getContractFactory("SugarDaddy");
  const deployDaddy = await SugarDaddy.deploy('0x9FE532197ad76c5a68961439604C037EB79681F0', '0x744C1aaA95232EeF8A9994C4E0b3a89659D9AB79');
  console.log("SugarDaddy address:", deployDaddy.address);

  // Deployes the SugarBaby contract passing in the Aave V2 ILendingPoolAddressesProvider, Lending Pool and Protocol Data Provider addresses on Kovan
  const SugarBaby = await ethers.getContractFactory("SugarBaby");
  const deployBaby = await SugarBaby.deploy('0x652B2937Efd0B5beA1c8d54293FC1289672AFC6b', '0x9FE532197ad76c5a68961439604C037EB79681F0', '0x744C1aaA95232EeF8A9994C4E0b3a89659D9AB79');
  console.log("SugarBaby address:", deployBaby.address);

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
