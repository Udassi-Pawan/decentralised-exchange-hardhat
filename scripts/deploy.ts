import { ethers } from "hardhat";

async function main() {
  // const nftex = await ethers.deployContract("ExchangeNFT");
  // await nftex.waitForDeployment();
  // console.log(`nftex deployed to ${nftex.target}`);

  const MyContract = await ethers.getContractFactory("exchange");
  const cryptex = await MyContract.deploy(
    "0xf3fdBC261db3A2d106c34003d81FFc0eaf06630F"
  );
  await cryptex.waitForDeployment();
  console.log(`cryptex deployed to ${cryptex.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.0xe17EAa6456E5AcF44A5f7d3Ce83F997133867171
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// sepolia = 0x700771a05dA385a564Fa7Bbd4dC68A2416e3fe7F
// mumbai = 0x828b253371c59500a28154B7d136d2b4DF1D142c
