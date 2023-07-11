import { ethers } from "hardhat";

async function main() {
  // const nftex = await ethers.deployContract("ExchangeNFT");
  // await nftex.waitForDeployment();
  // console.log(`nftex deployed to ${nftex.target}`);

  const cryptex = await ethers.deployContract("exchange");
  await cryptex.waitForDeployment();
  console.log(`cryptex deployed to ${cryptex.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
