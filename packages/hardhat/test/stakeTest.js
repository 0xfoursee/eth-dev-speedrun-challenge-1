const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("My Dapp", function () {
  let Staker;
  let externalContract;
  let myStaker;

  describe("Staker", function () {
    it("Should deploy Staker", async function () {
      const tmpExternal = await ethers.getContractFactory(
        "ExampleExternalContract"
      );
      externalContract = await tmpExternal.deploy();
      Staker = await ethers.getContractFactory("Staker");

      myStaker = await Staker.deploy(externalContract.address);
    });
    describe("expired()", function () {
      // runs some tests
    });
    describe("active()", function () {
      // runs some tests
    });
    describe("stake()", function () {
      it("Should stake successfully", async function () {
        await myStaker.stake({ value: "10"});

        expect(await myStaker.getBalance()).to.equal(10);
      });
      it("Should cum stake successfully", async function () {
        await myStaker.stake({ value: "10"});

        expect(await myStaker.getBalance()).to.equal(20);
      });
    });
    describe("timeLeft()", function () {
      it("Should show the timeLeft successfully", async function () {
        const timeLeft = await myStaker.timeLeft();
        const isPos = timeLeft > 0;

        expect(isPos).to.equal(true);
      });
    });
    // describe("execute()", function () {
    //   it("Should execute successfully", async function () {
    //     myStaker.deadline = 1637655466;
    //     await myStaker.execute();

    //     // expect(await myStaker.getBalance()).to.equal(10);
    //   });
    // });
  });
});
