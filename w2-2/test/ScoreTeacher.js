require("@nomicfoundation/hardhat-chai-matchers");
const { expect } = require("chai");

describe("Test Teacher and Score", function() {
    async function deployFixture() {
        const Teacher = await hre.ethers.getContractFactory("Teacher");
        const teacher = await Teacher.deploy();
        await teacher.deployed();

        const Score = await hre.ethers.getContractFactory("Score");
        const score = await Score.deploy(teacher.address);
        await score.deployed();

        const NotTeacher = await hre.ethers.getContractFactory("NotTeacher");
        const notTeacher = await NotTeacher.deploy();
        await notTeacher.deployed();

        const [student] = await ethers.getSigners();

        return [teacher, score, student, notTeacher];
    }

    it("Teacher set score (in range)", async function() {
        let [teacher, score, student] = await deployFixture();
        await teacher.setStudentScore(score.address, student.address, 100);
        expect(await score.getScore(student.address)).to.equal(100);
    });

    it("Teacher set score (out of range)", async function() {
        let [teacher, score, student] = await deployFixture();
        await expect(teacher.setStudentScore(score.address, student.address, 101)).to.be.reverted;
    });

    it("Only teacher could set score", async function() {
        let [, score, student, notTeacher] = await deployFixture();
        await expect(notTeacher.setStudentScore(score.address, student.address, 90)).to.be.reverted;
    });
});