const fs = require("fs");
const path = require("path");

function stepwiseFisherYates(entropy, oldArray, extraRounds, maxExtraRounds) {
    if (entropy === 0) {
        console.error("Do not use zero as the entropy");
        process.exit(1);
    }
    
    const newArray = Array.from(oldArray);
    const stepwiseArray = {"arrayHistory": [], "pivotHistory": []};
    
    // Do the original F-Y shuffle
    for (let i = 0; i < (newArray.length - 1); i++) {
        const before = Array.from(newArray);
        
        stepwiseArray.arrayHistory.push(before);
        stepwiseArray.pivotHistory.push(i);
        
        const j = i + entropy % (newArray.length - i);
        [newArray[j], newArray[i]] = [newArray[i], newArray[j]];
    }
    
    // Do the extra rounds
    for (let i = 0; i < extraRounds; i++) {
        const before = Array.from(newArray);
        
        stepwiseArray.arrayHistory.push(before);
        stepwiseArray.pivotHistory.push(i);
        
        const j = i + entropy % (newArray.length - i);
        [newArray[j], newArray[i]] = [newArray[i], newArray[j]];
    }
    
    stepwiseArray.arrayHistory.push(newArray);
    stepwiseArray.pivotHistory.push(null);
    
    // Fill up the rest of un-used elements
    for (let i = 0; i < (maxExtraRounds - extraRounds); i++) {
        stepwiseArray.arrayHistory.push([...Array(newArray.length)].map(x => 0));
        stepwiseArray.pivotHistory.push(null);
    }
    
    return stepwiseArray;
}

async function main() {
    if (process.argv.length !== 6) {
        console.error("Please run the script like:\n\n> node genInputJson.js <ENTROPY_HEX_STR> <ARRAY_LEN> <EXTRA_ROUNDS> <MAX_EXTRA_ROUNDS>\n");
        process.exit(1);
    }
    
    const entropy = parseInt(process.argv[2], '16');
    const length = parseInt(process.argv[3], '10');
    const extraRounds = parseInt(process.argv[4], '10');
    const maxExtraRounds = parseInt(process.argv[5], '10');
    
    if ((extraRounds > length) || (extraRounds < 0)) {
        console.error("Extra shuffling rounds must be in [0, the length of the array]");
        process.exit(1);
    }
    
    const array = [...Array(length).keys()].map((x) => (x+1));
    const permutationHistory = stepwiseFisherYates(entropy, array, extraRounds, maxExtraRounds);
    
    const filePath = path.join(path.resolve("."), "circom", "mainCircuit.input.json");
       
    fs.writeFileSync(
        fs.openSync(filePath, "w+"),
        JSON.stringify(
        {
            "entropy": entropy,
            "shuffleHistory": permutationHistory.arrayHistory,
            "extraRounds": extraRounds
        }
    ));
}

main()
    .then(() => {
        process.exit(0);
    })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
