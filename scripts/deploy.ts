import hardhat from 'hardhat';
import {BigNumber} from "ethers";
const { run, ethers } = hardhat;

let tokenERC20Contract;

let initialBalance: BigNumber = ethers.utils.parseEther("10000")
async function main(): Promise<void> {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);

  console.log('Account balance:', (await deployer.getBalance()).toString());

  // script deploy

  // factory
  const tokenERC20Factory = await ethers.getContractFactory("TokenERC20");
  tokenERC20Contract = await tokenERC20Factory.deploy(initialBalance);
  await tokenERC20Contract.deployed()

  console.log("TokenERC20 is deployed to: " + tokenERC20Contract.address);

  // Verifying contracts
  if (hardhat.network.name !== 'hardhat' && hardhat.network.name !== 'localhost') {
    await new Promise((f) => setTimeout(f, 10000));

    await run('verify:verify', {
      address: tokenERC20Contract.address,
      constructorArguments: [initialBalance],
    });

  }
}

main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });
