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
  const tokenERC1155DescriptorFactory = await ethers.getContractFactory("TokenERC1155Descriptor");
  const tokenERC1155Descriptor = await tokenERC1155DescriptorFactory.deploy()
  await tokenERC1155Descriptor.deployed()
  console.log("TokenERC1155Descriptor deployed to: " , tokenERC1155Descriptor.address);

  const tokenERC1155ManagerFactory = await ethers.getContractFactory("TokenERC1155Manager");
  const tokenERC1155Manager = await tokenERC1155ManagerFactory.deploy(tokenERC1155Descriptor.address)
  await tokenERC1155Manager.deployed()

  console.log("TokenERC1155Manager deployed to: " , tokenERC1155Manager.address);

  await new Promise((f) => setTimeout(f, 10000));

  await run('verify:verify', {
    address: tokenERC1155Descriptor.address,
    constructorArguments: [],
  });

  await run('verify:verify', {
    address: tokenERC1155Manager.address,
    constructorArguments: [tokenERC1155Descriptor.address],
  });

}

main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });
