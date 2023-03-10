require("@nomicfoundation/hardhat-chai-matchers")
const { expect } = require("chai");

describe("Counter test", function () {
    it("Initial counter should be 0", async function () {
        const Counter = await ethers.getContractFactory("Counter");
        const counter = await Counter.deploy();
        expect(await counter.get()).to.equal(0);
    });
    
    it("Owner could call count", async function () {
        const Counter = await ethers.getContractFactory("Counter");
        const counter = await Counter.deploy();
        await counter.count();
        expect(await counter.get()).to.equal(1);
    });

    it("Other address could not call count", async function () {
        const Counter = await ethers.getContractFactory("Counter");
        const counter = await Counter.deploy();
        const [, otherAccount] = await ethers.getSigners(); // get other accounts
        // await should be outside of expect here, otherwise expect can not catch the exception
        await expect(counter.connect(otherAccount).count()).to.be.revertedWith('You are not the owner!');
    });
});
