const fs = require("fs");
const path = require("path");

function stepwiseFisherYates(entropy, oldArray) {
    if (entropy === 0) {
        console.error("Do not use zero as the entropy");
        process.exit(1);
    }
    
    const newArray = Array.from(oldArray);
    const stepwiseArray = {"arrayHistory": [], "pivotHistory": []};
    
    for (let i = 0; i < newArray.length; i++) {
        const before = Array.from(newArray);
        const pivotIndex = i;
        
        stepwiseArray.arrayHistory.push(before);
        stepwiseArray.pivotHistory.push(pivotIndex);
        
        const j = i + entropy % (newArray.length - i);
        const temp = newArray[i];
        newArray[i] = newArray[j];
        newArray[j] = temp;
    }
    
    stepwiseArray.arrayHistory.push(newArray);
    stepwiseArray.pivotHistory.push(newArray.length);
    
    return stepwiseArray;
}

async function main() {
    if (process.argv.length !== 4) {
        console.error("Please run the script like $ node genInputJson.js <ARRAY_LEN> <ENTROPY_HEX_STR>");
        process.exit(1)
    }
    
    const len = parseInt(process.argv[2], '10');
    const entropy = parseInt(process.argv[3], '16');
    const array = [...Array(len).keys()];
    const permutationHistory = stepwiseFisherYates(entropy, array);
    
    const filePath = path.join(path.resolve("."), "circom", "mainCircuit.input.json");
       
    fs.writeFileSync(
        fs.openSync(filePath, "w+"),
        JSON.stringify(
        {
            "entropy": entropy,
            "shuffleHistory": permutationHistory.arrayHistory
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
