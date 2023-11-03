pragma circom 2.0.0;

include "./shuffle.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template Main(ARRAY_LEN, MAX_EXTRA_ROUNDS) {
    signal input entropy;
    signal input shuffleHistory[(ARRAY_LEN + 1) + MAX_EXTRA_ROUNDS][ARRAY_LEN];
    signal input extraRounds;
    
    // # of extra shuffling round is up to `ARRAY_LEN`
    component lessEqThanTest = LessEqThan(252);
    lessEqThanTest.in[0] <== extraRounds;
    lessEqThanTest.in[1] <== MAX_EXTRA_ROUNDS;
    lessEqThanTest.out === 1;
    
    // Do the original F-Y shuffle
    component eachShuffle[ARRAY_LEN];
    for (var i = 0;i < ARRAY_LEN; i++) {
        eachShuffle[i] = Shuffle(ARRAY_LEN);
        
        // Input signal assignments
        eachShuffle[i].entropy <== entropy;
        eachShuffle[i].pivotIndex <== i;
        
        for (var j = 0; j < ARRAY_LEN; j++) {
            eachShuffle[i].oldArray[j] <== shuffleHistory[i][j];
            eachShuffle[i].newArray[j] <== shuffleHistory[i + 1][j];
        }
        
        eachShuffle[i].enableFlag <== 1;
    }
    
    // Do the extra round of F-Y shuffle
    component eachExtraShuffle[MAX_EXTRA_ROUNDS];
    component auxiliary[MAX_EXTRA_ROUNDS];
    for (var i = 0; i < MAX_EXTRA_ROUNDS; i++) {
        eachExtraShuffle[i] = Shuffle(ARRAY_LEN);
        auxiliary[i] = LessEqThan(252);
        
        // Input signal assignments
        eachExtraShuffle[i].entropy <== entropy;
        eachExtraShuffle[i].pivotIndex <== i;
        
        for (var j = 0; j < ARRAY_LEN; j++) {
            eachExtraShuffle[i].oldArray[j] <== shuffleHistory[(ARRAY_LEN+i)][j];
            eachExtraShuffle[i].newArray[j] <== shuffleHistory[(ARRAY_LEN+i) + 1][j];
        }
        
        auxiliary[i].in[0] <== i;
        auxiliary[i].in[1] <== extraRounds;
        eachExtraShuffle[i].enableFlag <== auxiliary[i].out;
    }
}
