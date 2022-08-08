import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

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

});
