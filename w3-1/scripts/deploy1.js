// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const MyERC20 = await hre.ethers.getContractFactory("MyERC20");
  const myERC20 = await MyERC20.deploy();

  await myERC20.deployed();

  console.log("MyERC20 deployed to " + myERC20.address);

  const Vault = await hre.ethers.getContractFactory("Vault");
  const vault = await Vault.deploy(myERC20.address);

  await vault.deployed();

  console.log("Vault deployed to " + vault.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
