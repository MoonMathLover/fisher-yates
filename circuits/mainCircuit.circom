pragma circom 2.0.0;

include "./shuffle.circom";

template Main(len) {
    signal input entropy;
    signal input shuffleHistory[len + 1][len];
    
    component eachShuffle[len + 1];
    for (var i = 0;i < len; i++) {
        eachShuffle[i] = Shuffle(len);
        
        eachShuffle[i].entropy <== entropy;
        eachShuffle[i].pivotIndex <== i;
        
        for (var j = 0; j < len; j++) {
            eachShuffle[i].oldArray[j] <== shuffleHistory[i][j];
            eachShuffle[i].newArray[j] <== shuffleHistory[i+1][j];
        }
    }
}
