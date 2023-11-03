pragma circom 2.0.0;

include "./shuffle.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template Main(ARRAY_LEN, MAX_EXTRA_ROUNDS) {
    signal input entropy;
    signal input shuffleHistory[ARRAY_LEN + MAX_EXTRA_ROUNDS][ARRAY_LEN];
    signal input extraRounds;
    
    // # of extra shuffling round is up to `ARRAY_LEN`
    signal extraRoundsCheck <== LessEqThan(252)([extraRounds, MAX_EXTRA_ROUNDS]);
    extraRoundsCheck === 1;
    
    // Do the original F-Y shuffle
    for (var i = 0;i < (ARRAY_LEN - 1); i++) {
        Shuffle(ARRAY_LEN)(
            entropy,
            i,
            shuffleHistory[i],
            shuffleHistory[i + 1],
            1
        );
    }
    
    // Do the extra round of F-Y shuffle
    component eachExtraShuffle[MAX_EXTRA_ROUNDS];
    signal auxiliary[MAX_EXTRA_ROUNDS];
    
    for (var i = 0; i < MAX_EXTRA_ROUNDS; i++) {
        auxiliary[i] <== LessThan(252)([i, extraRounds]);
        
        Shuffle(ARRAY_LEN)(
            entropy,
            i,
            shuffleHistory[(ARRAY_LEN - 1) + i],
            shuffleHistory[(ARRAY_LEN - 1) + i + 1],
            auxiliary[i]
        );
    }
}
