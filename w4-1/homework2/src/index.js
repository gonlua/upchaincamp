const { ethers }  = require("ethers");
const { abi } = require("../data/MyERC721.json")
require("dotenv").config();

async function getLogs() {
    const provider = new ethers.providers.JsonRpcProvider(process.env.PROVIDER_URL);
    let nft = new ethers.Contract(process.env.NFT_ADDR, abi, provider);
    let filter = nft.filters.TransferFrom();
    
    filter.fromBlock = 1;
    filter.toBlack = 1000;
    
    return provider.getLogs(filter);
}

getLogs().then(logs => {
    console.log('logs-----', logs);
});