import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { SimpleBank } from "../typechain-types"

describe("SimpleBank", function () {
  async function deployOneYearLockFixture() {

    const [owner, testAccountOne] = await ethers.getSigners();

    const SimpleBank = await ethers.getContractFactory("SimpleBank");
    const simpleBank = await SimpleBank.deploy();

    return { simpleBank, owner, testAccountOne };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {

      const { simpleBank, owner } = await loadFixture(deployOneYearLockFixture);

      expect(await simpleBank.owner()).to.equal(owner.address);

    });

  });

  describe("Enrollment", function() {

    it("Should receive and store the funds to lock", async function () {

      const { simpleBank, owner, testAccountOne} = await loadFixture(deployOneYearLockFixture);

      await expect(
        simpleBank.connect(testAccountOne).deposit(
          {
            from: testAccountOne.address,
            value: 500000
          }
        )).to.revertedWith("need enrollment")

    });

    it("Should emit enrolled event and get balance 0", async function () {

      const { simpleBank, testAccountOne} = await loadFixture(deployOneYearLockFixture);
      const enrollment = await simpleBank.connect(testAccountOne).enroll()

      expect(enrollment).to.emit(simpleBank, "LogEnrolled")

      expect(await simpleBank.connect(testAccountOne).getBalance()).to.equal(0)

    });

  })

  describe("Deposit", function() {

    it("Should deposit 50000 to balance and change ether balance", async function () {

      const { simpleBank, testAccountOne} = await loadFixture(deployOneYearLockFixture);

      const enrollment = await simpleBank.connect(testAccountOne).enroll()

      expect(enrollment).to.emit(simpleBank, "LogEnrolled")

      const amountToDeposit = 50000

      expect(await simpleBank.connect(testAccountOne).deposit({from: testAccountOne.address, value: amountToDeposit}))
        .to.emit(simpleBank, "LogDepositMade")
        .to.changeEtherBalance(testAccountOne, amountToDeposit)

      expect(await simpleBank.connect(testAccountOne).getBalance())
        .to.equal(amountToDeposit)

    });
  })

  describe("Withdraw", function() {

    it("Should withdraw 25000 and balance reduce to 25000 in contract, and withdrawAll, balance reduce to 0", async function () {
      const { simpleBank, testAccountOne} = await loadFixture(deployOneYearLockFixture);
      await simpleBank.connect(testAccountOne).enroll()
      const amountToDeposit = 50000
      await simpleBank.connect(testAccountOne).deposit({from: testAccountOne.address, value: amountToDeposit})

      expect(await simpleBank.connect(testAccountOne).withdraw(25000))
        .to.emit(simpleBank, "LogWithdraw")
        .to.changeEtherBalance(testAccountOne, 25000)

      expect(await simpleBank.connect(testAccountOne).getBalance())
        .to.equal(25000)

      expect(await simpleBank.connect(testAccountOne).withdrawAll())
        .to.emit(simpleBank, "LogWithdraw")
        .to.changeEtherBalance(testAccountOne, 25000)

      expect(await simpleBank.connect(testAccountOne).getBalance())
        .to.equal(0)

    });

    it("Should withdraw 25000 and require enrollment error", async function () {
      const { simpleBank, testAccountOne} = await loadFixture(deployOneYearLockFixture);

      await expect(simpleBank.connect(testAccountOne).withdraw(25000))
        .to.revertedWith("need enrollment")

    });

    it("Should withdrawAll and require enrollment error", async function () {
      const { simpleBank, testAccountOne} = await loadFixture(deployOneYearLockFixture);

      await expect(simpleBank.connect(testAccountOne).withdrawAll())
        .to.revertedWith("need enrollment")

    });

    it("Should withdraw 50001 but not has balance", async function () {
      const { simpleBank, testAccountOne} = await loadFixture(deployOneYearLockFixture);
      await simpleBank.connect(testAccountOne).enroll()
      const amountToDeposit = 50000
      await simpleBank.connect(testAccountOne).deposit({from: testAccountOne.address, value: amountToDeposit})

      await expect(simpleBank.connect(testAccountOne).withdraw(50001))
        .to.revertedWith("Insufficient balance")

    });

    it("Should withdraw 50001 but not has balance", async function () {
      const { simpleBank, testAccountOne} = await loadFixture(deployOneYearLockFixture);
      await simpleBank.connect(testAccountOne).enroll()
      const amountToDeposit = 50000
      await simpleBank.connect(testAccountOne).deposit({from: testAccountOne.address, value: amountToDeposit})

      await expect(simpleBank.connect(testAccountOne).withdraw(50001))
        .to.revertedWith("Insufficient balance")

      expect(await simpleBank.connect(testAccountOne).getBalance()).to.equal(50000)
    });
  })
});
