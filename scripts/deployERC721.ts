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
  const erc721Factory = await ethers.getContractFactory("TokenERC721");
  const erc721Contract = await erc721Factory.deploy("NFTest", "NFT")
  console.log("Contract deployed to: ", erc721Contract.address)
  let tx = await erc721Contract.mint(deployer.address, 0, "");
  await tx.wait();
  console.log("MINT ok")
}

main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });
