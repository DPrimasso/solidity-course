import hardhat from "hardhat";
const { ethers, upgrades } = hardhat;

import {expect} from 'chai';
import { Contract } from "@ethersproject/contracts";
import { Provider } from "@ethersproject/providers";
import {BigNumber} from "ethers";
let catchRevert = require("./utils/exceptions.ts").catchRevert;
let catchRevertWithoutReason = require("./utils/exceptions.ts").catchRevertWithoutReason;

let MINTER_ROLE = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('MINTER_ROLE'));

let deployer: any;
let account1: any;
let account2: any;
let account3: any;

let tokenERC1155Manager: Contract;
let tokenERC1155Descriptor: Contract;

let maxSupplyToken0 = ethers.utils.parseEther("1000")

before(async function() {
  [deployer, account1, account2, account3] = await ethers.getSigners()

  // Deploy

  const tokenERC1155DescriptorFactory = await ethers.getContractFactory("TokenERC1155Descriptor");
  tokenERC1155Descriptor = await tokenERC1155DescriptorFactory.deploy()

  console.log("TokenERC1155Descriptor deployed to: " , tokenERC1155Descriptor.address);

  const tokenERC1155ManagerFactory = await ethers.getContractFactory("TokenERC1155Manager");
  tokenERC1155Manager = await tokenERC1155ManagerFactory.deploy(tokenERC1155Descriptor.address)

  console.log("TokenERC1155Manager deployed to: " , tokenERC1155Manager.address);

});


describe("Testing... ", async () => {

    describe("Testing something...", async () => {

      it("should test balanceOf", async () => {
        let balanceDeployer = await tokenERC1155Manager.balanceOf(deployer.address, 0);
        console.log({balanceDeployer})
      })

      it("should test balanceOfBatch", async () => {
        let balanceBatch = await tokenERC1155Manager.balanceOfBatch([deployer.address, account1.address], [0, 0]);
        console.log({balanceBatch})
      })

      it('should grant role MINTER_ROLE to deployer', async () => {
        await tokenERC1155Manager.grantRole(MINTER_ROLE, account1.address);
        expect(await tokenERC1155Manager.hasRole(MINTER_ROLE, account1.address)).to.be.true
      });

      it('should add typeId with supply in Descriptor', async () => {
        await tokenERC1155Descriptor.addTypeToken(maxSupplyToken0)
        expect(await tokenERC1155Descriptor.getMaxSupplyByTypeId(0)).to.be.equal(maxSupplyToken0)

      });



      it('should mint ', async () => {
        await tokenERC1155Manager.connect(account1).mint(account1.address, 0, maxSupplyToken0.div(2), []);
        let balanceAccount1 = await tokenERC1155Manager.balanceOf(account1.address, 0);
        expect(balanceAccount1).to.be.equal(maxSupplyToken0.div(2))
      });

      it('should rever if mint over supply ', async () => {
        await catchRevert(tokenERC1155Manager.connect(account1).mint(account1.address, 0, maxSupplyToken0, []));
      });

      it('should add typeId with supply in Descriptor', async () => {
        await tokenERC1155Descriptor.addTypeToken(100)
        await tokenERC1155Descriptor.addTypeToken(0)
        expect(await tokenERC1155Descriptor.getMaxSupplyByTypeId(0)).to.be.equal(maxSupplyToken0)
      });


      it('should mint batch', async () => {
        await tokenERC1155Manager.connect(account1).mintBatch(account2.address, [1,2], [1, 100], []);
        let balanceBatch = await tokenERC1155Manager.balanceOfBatch([account2.address, account2.address], [1,2]);
        expect(balanceBatch[0]).to.be.equal(1)
        expect(balanceBatch[1]).to.be.equal(100)
      });

      it('should mint batch', async () => {
        await catchRevert(tokenERC1155Manager.connect(account1).mintBatch(account2.address, [1,2], [1000, 100], []));
      });

      it('should mint batch', async () => {
        let balanceBatchInitial = await tokenERC1155Manager.balanceOfBatch([account2.address, account2.address], [1,2]);

        await tokenERC1155Manager.connect(account1).mintBatch(account2.address, [1,2], [1, 10000000], []);
        let balanceBatch = await tokenERC1155Manager.balanceOfBatch([account2.address, account2.address], [1,2]);
        expect(balanceBatch[0]).to.be.equal(balanceBatchInitial[0].add(1))
        expect(balanceBatch[1]).to.be.equal(balanceBatchInitial[1].add(10000000))

      });

    })

});


