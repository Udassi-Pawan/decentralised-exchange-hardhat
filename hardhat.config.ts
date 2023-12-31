import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const PRIVATE_KEY: string = process.env.PRIVATE_KEY!;

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/" + process.env.SEPOLIA_URL,
      accounts: [PRIVATE_KEY],
    },
    mumbai: {
      url: "https://matic.getblock.io/04f401f9-44f5-4841-b934-71157c95af64/testnet/",
      accounts: [PRIVATE_KEY],
    },
    bsc: {
      url: "https://bsc-testnet.publicnode.com",
      accounts: [PRIVATE_KEY],
    },
  },
};

export default config;

// sepoli = 0x80ba230CF076b22D98668cA8E67e17358E2Cd408
// mumbai = 0xf41b6fA7D8D4c65aC8639654E7175756A75b0074
