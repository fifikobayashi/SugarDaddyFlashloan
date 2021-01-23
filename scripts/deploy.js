async function main() {

  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploys the SugarDaddy contract passing in the Aave V2 Lending Pool and Protocol Data Provider addresses on Mainnet
  const SugarDaddy = await ethers.getContractFactory("SugarDaddy");
  const deployDaddy = await SugarDaddy.deploy('0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9', '0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d');
  console.log("the SugarDaddys address:", deployDaddy.address);

  // Deploys the Leech contract passing in the Aave V2 LendingPoolAddressesProvider, Lending Pool and Protocol Data Provider addresses on Mainnet
  const theLeech = await ethers.getContractFactory("theLeech");
  const deployLeech = await theLeech.deploy('0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5', '0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9', '0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d');
  console.log("the Leechs address:", deployLeech.address);

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
