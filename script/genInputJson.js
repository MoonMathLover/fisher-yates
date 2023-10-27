const fs = require("fs");

function stepwiseFisherYates(entropy, oldArray) {
    if (entropy === 0) {
        console.error("Do not use zero as the entropy");
        process.exit(1);
    }
    
    const newArray = Array.from(oldArray);
    const stepwiseArray = Array();
    
    for (let i = 0; i < newArray.length; i++) {
        const before = Array.from(newArray);
        const pivotIndex = i;
        stepwiseArray.push([before, pivotIndex]);
        
        const j = i + entropy % (newArray.length - i);
        const temp = newArray[i];
        newArray[i] = newArray[j];
        newArray[j] = temp;
    }
    
    stepwiseArray.push([newArray, newArray.length]);
    
    return stepwiseArray;
}

async function main() {
    const e = 123456;
    const a = [];
    for (let i = 0; i < 50; i++) {
        a.push(i);
    }
    
    fs.openSync("./circuits/input.json", "w+");
    fs.writeFileSync(
        "./circuits/input.json",
        JSON.stringify(stepwiseFisherYates(e, a))
    );
}

main()
    .then(() => {
        process.exit(0);
    })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
