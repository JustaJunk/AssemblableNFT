import { expect } from "chai";
import { ethers, getNamedAccounts, getUnnamedAccounts, deployments } from "hardhat";

describe("Assemblable NFT", function () {
  it("Mint", async function () {
    // Accounts
    const [,,,user1, user2] = await ethers.getSigners();
    
    // Deployment
    await deployments.fixture(["AssemblableNFT"]);
    const ablyDeployments = await deployments.get("AssemblableNFT");
    const assemblableNFT = await ethers.getContractAt("AssemblableNFT", ablyDeployments.address);
    
    // Settings
    const tokenPrice = ethers.utils.parseEther("0.02");
    
    // Test
    console.log("user1 mint token 0");
    const tx0 = await assemblableNFT.connect(user1).mint({value: tokenPrice});
    await tx0.wait();
    console.log("tokenURI(0):", await assemblableNFT.tokenURI(0), "\n");
    
    console.log("user2 mint token 1");
    const tx1 = await assemblableNFT.connect(user2).mint({value: tokenPrice});
    await tx1.wait();
    console.log("tokenURI(1):", await assemblableNFT.tokenURI(1), "\n");

    console.log("user1 disassemble token 0 with code 0x04070000");
    const tx2 = await assemblableNFT.connect(user1).disassemble(0, "0x04070000");
    await tx2.wait();
    console.log("tokenURI(0):", await assemblableNFT.tokenURI(0), "\n");

    console.log("user2 transfer token 1 to user1")
    const tx3 = await assemblableNFT.connect(user2).transferFrom(user2.address, user1.address, 1);
    await tx3.wait();
    console.log("balance(user1):", (await assemblableNFT.balanceOf(user1.address)).toNumber(), "\n");
    
    console.log("user1 assemble token 1 with code 0x04070000");
    const tx4 = await assemblableNFT.connect(user1).assemble(1, "0x04070000");
    await tx4.wait();
    console.log("tokenURI(1):", await assemblableNFT.tokenURI(1), "\n");
  });
});
