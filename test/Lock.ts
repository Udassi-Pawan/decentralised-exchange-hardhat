import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("nftEx", function () {
  async function deployNftEx() {
    const [owner, otherAccount] = await ethers.getSigners();
    const ExNFT = await ethers.getContractFactory("ExchangeNFT");
    const exNFT = await ExNFT.deploy();

    return { exNFT, owner, otherAccount };
  }
  describe("Deployment", function () {
    it("check Name", async function () {
      const { exNFT, owner } = await loadFixture(deployNftEx);
      expect(await exNFT.name()).to.equal("exchangeNFT");
    });
  });
  describe("check mint", function () {
    it("check uri", async function () {
      const { exNFT, owner, otherAccount } = await loadFixture(deployNftEx);
      await exNFT.connect(otherAccount).safeMint(otherAccount, "abcd");
      expect(await exNFT.tokenURI(0)).to.equal("abcd");
    });
    it("check owner", async function () {
      const { exNFT, owner, otherAccount } = await loadFixture(deployNftEx);
      await exNFT.connect(otherAccount).safeMint(otherAccount, "abcd");
      expect(await exNFT.ownerOf(0)).to.equal(otherAccount.address);
    });
  });
});
