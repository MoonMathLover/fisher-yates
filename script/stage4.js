// Package
require("dotenv").config();
const ethers = require("ethers");
const shelljs = require("shelljs");

// Constant
const contractAddress = "";
const contractABI = "";

// Main function
async function main() {
    const provider = new ethers.providers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
    const contract = new ethers.Contract(contractAddress, contractABI, provider);
    const extraRounds = await contract.userContributeSwapTimes();
    const entropy = await contract.randao();
    
    {
        const cmd = `node script/genInputJson.js ${entropy} 50 ${extraRounds} 50`;
        shelljs.exec(cmd);
    }
    
    {
        const cmd = `yarn zkey-manager genProofs -c zkey.config.yml`;
        shelljs.exec(cmd);
    }
    
    {
        const publicJson = "./artifacts/Main_50-50_zkPlayground_groth16.public.json";
        const proofJson = "./artifacts/Main_50-50_zkPlayground_groth16.proof.json";
        const cmd = `yarn snarkjs zkey export soliditycalldata ${publicJson} ${proofJson}`;
        shelljs.exec(cmd);
    }
}

main()
    .then(() => {
        process.exit(0);
    })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });