import hardhat from 'hardhat';
import {BigNumber} from "ethers";
const { run, ethers } = hardhat;

async function main(): Promise<void> {
  // get rpc url -> rpc provider
  // get privKey -> signer
  // new contract ( abi, rpc, signer )

  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);

  console.log('Account balance:', (await deployer.getBalance()).toString());

  // script deploy
  const erc20Factory = await ethers.getContractFactory("TokenERC20");
  const erc20Contract = await erc20Factory.deploy();
  await erc20Contract.deployed();
  console.log("Contract deployed to: ", erc20Contract.address)
  //let tx = await erc20Contract.mint(deployer.address, 0, "");
  //await tx.wait();
  //console.log("MINT ok")

  await run('verify:verify', {
    address: erc20Contract.address,
    constructorArguments: [],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });
