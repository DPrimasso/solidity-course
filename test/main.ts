import hardhat from "hardhat";
const { ethers, upgrades } = hardhat;

import {expect} from 'chai';
import { Contract } from "@ethersproject/contracts";
import { Provider } from "@ethersproject/providers";
import {BigNumber} from "ethers";
let catchRevert = require("./utils/exceptions.ts").catchRevert;
let catchRevertWithoutReason = require("./utils/exceptions.ts").catchRevertWithoutReason;

let deployer: any
let account1: any
let account2: any

let name = "TokenExample"
let symbol = "TKE"
let decimals = 18
let decimalBigNum = BigNumber.from(10000000000).mul(100000000)
//let initialSupply = BigNumber.from(100).pow(decimals);
//let number = 500 / 3
let initialSupply = BigNumber.from("100").mul(decimalBigNum);
//let initialSupply = ethers.utils.parseUnits("100", 18)

let tokenContract: any;
before(async function() {
  [deployer, account1, account2] = await ethers.getSigners()

  // Deploy
  const tokenFactory = await ethers.getContractFactory("TokenExample");
  tokenContract = await tokenFactory.deploy(name, symbol, decimals, initialSupply)
});


describe("Testing... ", async () => {

    describe("Testing something...", async () => {

      it("should test name", async () => {
        let nameContract = await tokenContract.name();
        expect(nameContract).to.be.equal(name)
      })

      it("should test symbol", async () => {
        let symbolContract = await tokenContract.symbol()
        expect(symbolContract).to.be.equal(symbol);
      })

      it("should test decimals", async () => {
        let decimalsContract = await tokenContract.decimals();
        expect(decimalsContract).to.be.equal(decimals);
      })

      it('should test initialSupply', async () => {
        let supply = await tokenContract.totalSupply();
        console.log({supply: supply.toString()})
        console.log({initialSupply: initialSupply.toString()})
        expect(initialSupply).to.be.equal(supply)

        //let decimals = await tokenContract.decimals();
        //let supplyFormat = ethers.utils.formatUnits(supply, decimals);
        let supplyFormat = ethers.utils.formatEther(supply);
        console.log({supplyFormat})
      });

      it('should transfer 10 token to account 1', async () => {
        let amount = ethers.utils.parseEther(BigNumber.from(10).toString())
        await tokenContract.transfer(account1.address, amount);

        let balanceAccount1 = await tokenContract.balanceOf(account1.address);
        console.log({balanceAccount1: ethers.utils.formatEther(balanceAccount1)})
        expect(balanceAccount1).to.be.equal(amount);
      });

      it('should transfer 5 token from account 1 to account2', async () => {
        let balanceAccount1First = await tokenContract.balanceOf(account1.address);

        let amount = ethers.utils.parseEther(BigNumber.from(5).toString())
        await tokenContract.connect(account1).transfer(account2.address, amount);

        let balanceAccount1After = await tokenContract.balanceOf(account1.address);
        console.log({balanceAccount1After: ethers.utils.formatEther(balanceAccount1After)})
        expect(balanceAccount1After).to.be.equal(balanceAccount1First.sub(amount));

        let balanceAccount2 = await tokenContract.balanceOf(account2.address);
        console.log({balanceAccount2: ethers.utils.formatEther(balanceAccount2)})
        expect(balanceAccount2).to.be.equal(amount);

      });

      it('should revert transfer to address(0)', async () => {
        let amount = ethers.utils.parseEther(BigNumber.from(5).toString())
        let address0 = ethers.utils.getAddress("0x0000000000000000000000000000000000000000")
        await catchRevert(tokenContract.transfer(address0, amount))
      });

    })

});


