// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const initSettings = {
    name: "AssemblyCat",
    symbol: "AsC",
    payees: [(await ethers.getSigners())[0].address],
    shares: [1],
    itemsURI: "ipfs://DirectoryOfAllComponents/{id}.json",
    baseURI: "ipfs://DirectoryOfAllAssembly/",
    maxSupply: 10000,
    tokenPrice: ethers.utils.parseEther("0.02"),
    featureSpace: "0x0A0A0A0A",  // features: 10 10 10 10
  };

  // We get the contract to deploy
  const assemblableNFTFactory = await ethers.getContractFactory("AssemblableNFT");
  const assemblableNFT = await assemblableNFTFactory.deploy(initSettings);

  await assemblableNFT.deployed();

  console.log("AssemblableNFT deployed to:", assemblableNFT.address);
  console.log("ComponentNFT deployed to:", await assemblableNFT.componentContract());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
