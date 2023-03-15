require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Bank", function () {

  describe("Test Bank", function () {

    it("Test Bank", async function () {

      const Bank = await ethers.getContractFactory("Bank");
      const bank = await Bank.deploy();

      await bank.deployed();

      const [account] = await ethers.getSigners();

      // 给合约转账
      await account.sendTransaction({from: account.address, to: bank.address, value: 10});

      // 查看存款
      expect(await bank.getDeposit()).to.equal(10);

      // 提取存款
      await bank.withdraw()

      expect(await bank.getDeposit()).to.equal(0);

      // 测试无存款时提取
      expect(bank.withdraw()).to.be.revertedWith("No deposit to withdraw!");

    });

  });

});
