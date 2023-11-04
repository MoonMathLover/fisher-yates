// Package
require("dotenv").config();
const ethers = require("ethers");
const shelljs = require("shelljs");

// Constant
const MAX_EXTRA_ROUNDS = 50;
const contractAddress = "";
const contractABI     = [
    "function userContributeSwapTimes() external view returns (uint256)",
    "function randaoRandomness() external view returns (uint256)"
];
const sepoliaRpcUrl   = "https://sepolia.gateway.tenderly.co";


// Main function
async function main() {
    const provider = new ethers.providers.JsonRpcProvider(sepoliaRpcUrl);
    const contract = new ethers.Contract(contractAddress, contractABI, provider);    
    const extraRoundsUint256 = await contract.userContributeSwapTimes();
    const entropyUint256 = await contract.randaoRandomness();
    
    let extraRounds, entropy;
    
    if (!ethers.BigNumber.isBigNumber(extraRoundsUint256)) {
        console.error("Invoking `userContributeSwapTimes()` got wrong");
        process.exit(1);
        
    }
    else {
        extraRounds = (extraRoundsUint256.mod(MAX_EXTRA_ROUNDS)).toNumber();
    }
    
    if (!ethers.BigNumber.isBigNumber(entropyUint256)) {
        console.error("Invoking `userContributeSwapTimes()` got wrong");
        process.exit(1);
    }
    else {
        entropy = entropyUint256.toHexString();
    }
    
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