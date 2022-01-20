import hardhat from 'hardhat';
const { run, ethers } = hardhat;

async function main(): Promise<void> {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);

  console.log('Account balance:', (await deployer.getBalance()).toString());

  await run('verify:verify', {
    address: "0xc4bf2b1b7cb124c64c0e9ba1569d8eb613c2dfad",
    constructorArguments: ["NFTest", "NFT"],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });
