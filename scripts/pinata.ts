import hardhat from 'hardhat';
import {BigNumber} from "ethers";
import * as fs from "fs";
const { run, ethers } = hardhat;

const pinataSDK = require('@pinata/sdk');

async function main(): Promise<void> {
  const [deployer] = await ethers.getSigners();
  const { API_KEY_PINATA, API_SECRET_PINATA } = process.env;

  const pinata = pinataSDK(API_KEY_PINATA, API_SECRET_PINATA);

  await pinata.testAuthentication().then(async (result: any) => {

    const readableStream = await fs.createReadStream('./asset/image1.jpg')

    const options = {
    }
    let rawData: any = await fs.readFileSync('./asset/uriJsonStandard.json')
    const uriJsonParsed = JSON.parse(rawData)

    await pinata.pinFileToIPFS(readableStream, options).then(async (result: any) => {
      console.log({result})
      uriJsonParsed.image = "ipfs://" + result.IpfsHash;

      uriJsonParsed.attributes[0].value = "Primo mint"
      uriJsonParsed.attributes[1].value = "image online"

      const options = {
        name: "image1"
      }
      await pinata.pinJSONToIPFS(uriJsonParsed, options).then(async (result: any) => {

        console.log(result)
        // contractNFT.mint(idPlyaer, season, scarcity.... , tokenURI)
      })

    })
  });


}

main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });
