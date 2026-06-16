import { network } from "hardhat";

const { ethers } = await network.connect({
  network: "sepolia",
  chainType: "l1",
});

const [deployer] = await ethers.getSigners();
console.log("Deploying with:", deployer.address);

// 1. Deploy Token
const Token = await ethers.getContractFactory("CrowdfundToken");
const token = await Token.deploy();
await token.waitForDeployment();
console.log("Token deployed to:", await token.getAddress());

// 2. Deploy Campaign (goal: 0.1 ETH, 7 days)
const Campaign = await ethers.getContractFactory("CrowdfundCampaign");
const campaign = await Campaign.deploy(
  await token.getAddress(),
  ethers.parseEther("0.1"),
  7
);
await campaign.waitForDeployment();
console.log("Campaign deployed to:", await campaign.getAddress());

// 3. Transfer token ownership to campaign so it can mint
await token.transferOwnership(await campaign.getAddress());
console.log("Token ownership transferred to Campaign");

// 4. Deploy DAO (quorum: 500 tokens)
const DAO = await ethers.getContractFactory("CrowdfundDAO");
const dao = await DAO.deploy(
  await token.getAddress(),
  ethers.parseEther("500")
);
await dao.waitForDeployment();
console.log("DAO deployed to:", await dao.getAddress());

console.log("\n--- SAVE THESE ADDRESSES ---");
console.log("Token:   ", await token.getAddress());
console.log("Campaign:", await campaign.getAddress());
console.log("DAO:     ", await dao.getAddress());