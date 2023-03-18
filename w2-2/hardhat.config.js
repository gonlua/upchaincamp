require("@nomicfoundation/hardhat-toolbox");

task("score", "Get score of student")
  .addParam("student", "The student's address")
  .addParam("score", "The Score contract's address")
  .setAction(async ({ student, score }) => {
    const scoreContract = await ethers.getContractAt("Score", score);
    console.log(await scoreContract.getScore(student));
  });

task("teacher", "Teacher set score")
  .addParam("teacher", "The Teacher contract's address")
  .addParam("student", "The student's address")
  .addParam("score", "The Score contract's address")
  .setAction(async ({ teacher, student, score }) => {
    const teacherContract = await ethers.getContractAt("Teacher", teacher);
    await teacherContract.setStudentScore(score, student, 90);
    console.log('Set score done.');
  });

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    }
  },
};
