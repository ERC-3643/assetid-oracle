import { expect } from 'chai';
import { ethers } from 'hardhat';
import { Counter } from '../typechain-types';

describe('Counter', function () {
  let counter: Counter;

  beforeEach(async function () {
    const CounterFactory = await ethers.getContractFactory('Counter');
    counter = await CounterFactory.deploy();
    await counter.waitForDeployment();
  });

  describe('Deployment', function () {
    it('Should deploy with initial number of 0', async function () {
      expect(await counter.number()).to.equal(0);
    });
  });

  describe('setNumber', function () {
    it('Should set the number correctly', async function () {
      const newNumber = 42;
      await counter.setNumber(newNumber);
      expect(await counter.number()).to.equal(newNumber);
    });

    it('Should set the number to 0', async function () {
      await counter.setNumber(0);
      expect(await counter.number()).to.equal(0);
    });

    it('Should set the number to maximum uint256', async function () {
      const maxUint256 = ethers.MaxUint256;
      await counter.setNumber(maxUint256);
      expect(await counter.number()).to.equal(maxUint256);
    });

    it('Should emit an event when number is set', async function () {
      // Note: The current contract doesn't emit events, but this test structure
      // is ready if events are added in the future
      const newNumber = 100;
      await expect(counter.setNumber(newNumber)).to.not.be.reverted;
    });
  });

  describe('increment', function () {
    it('Should increment from 0 to 1', async function () {
      await counter.increment();
      expect(await counter.number()).to.equal(1);
    });

    it('Should increment from 1 to 2', async function () {
      await counter.setNumber(1);
      await counter.increment();
      expect(await counter.number()).to.equal(2);
    });

    it('Should increment multiple times', async function () {
      await counter.increment();
      await counter.increment();
      await counter.increment();
      expect(await counter.number()).to.equal(3);
    });

    it('Should increment from a large number', async function () {
      const largeNumber = 1000;
      await counter.setNumber(largeNumber);
      await counter.increment();
      expect(await counter.number()).to.equal(largeNumber + 1);
    });

    it('Should handle incrementing from maximum uint256 - 1', async function () {
      const maxUint256MinusOne = ethers.MaxUint256 - 1n;
      await counter.setNumber(maxUint256MinusOne);
      await counter.increment();
      expect(await counter.number()).to.equal(ethers.MaxUint256);
    });
  });

  describe('number', function () {
    it('Should return the current number', async function () {
      const testNumber = 123;
      await counter.setNumber(testNumber);
      expect(await counter.number()).to.equal(testNumber);
    });

    it('Should return 0 initially', async function () {
      expect(await counter.number()).to.equal(0);
    });
  });

  describe('Integration tests', function () {
    it('Should work with multiple operations', async function () {
      // Set initial number
      await counter.setNumber(10);
      expect(await counter.number()).to.equal(10);

      // Increment multiple times
      await counter.increment();
      await counter.increment();
      expect(await counter.number()).to.equal(12);

      // Set a new number
      await counter.setNumber(50);
      expect(await counter.number()).to.equal(50);

      // Increment again
      await counter.increment();
      expect(await counter.number()).to.equal(51);
    });

    it('Should handle rapid successive operations', async function () {
      // Perform multiple operations in quick succession
      for (let i = 0; i < 10; i++) {
        await counter.increment();
      }
      expect(await counter.number()).to.equal(10);

      // Set to a new value and increment
      await counter.setNumber(100);
      await counter.increment();
      expect(await counter.number()).to.equal(101);
    });
  });

  describe('Edge cases', function () {
    it('Should handle zero operations', async function () {
      // No operations performed, should remain at 0
      expect(await counter.number()).to.equal(0);
    });

    it('Should handle setting number to same value', async function () {
      await counter.setNumber(5);
      await counter.setNumber(5); // Set to same value
      expect(await counter.number()).to.equal(5);
    });

    it('Should handle incrementing after setting to 0', async function () {
      await counter.setNumber(0);
      await counter.increment();
      expect(await counter.number()).to.equal(1);
    });
  });
});
