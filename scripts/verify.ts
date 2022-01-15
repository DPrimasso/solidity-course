import hardhat from 'hardhat';
const { run, ethers } = hardhat;

async function main(): Promise<void> {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);

  console.log('Account balance:', (await deployer.getBalance()).toString());

  await run('verify:verify', {
    address: "0x97E9Dd777dfCa10B0387a1a437481a96A2573e8d",
    constructorArguments: ["Hello world"],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });
