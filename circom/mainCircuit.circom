pragma circom 2.0.0;

include "./shuffle.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

/**
 * @signal {public} entropy The random source of F-Y shuffle
 * @signal {public} extraRounds The number of rounds that doing extra F-Y shuffle
 * @signal {public} array `array[0]` is the original array and `array[1]` is the shuffled result
 * @signal {private} shuffleHistory A stepwise history of the F-Y shuffle
**/

template Main(ARRAY_LEN, MAX_EXTRA_ROUNDS) {
    signal input entropy;
    signal input extraRounds;
    signal input array[2][ARRAY_LEN];
    signal input shuffleHistory[ARRAY_LEN + MAX_EXTRA_ROUNDS][ARRAY_LEN];
    
    // # of extra shuffling round is up to `ARRAY_LEN`
    signal extraRoundsCheck <== LessEqThan(252)([extraRounds, MAX_EXTRA_ROUNDS]);
    extraRoundsCheck === 1;
    
    // Check the validity of the `shuffleHistory`
    for (var i = 0; i < ARRAY_LEN; i++) {
        array[0][i] === shuffleHistory[0][i];
    }
    
    signal isTheResult[ARRAY_LEN + MAX_EXTRA_ROUNDS];
    signal term1st[ARRAY_LEN + MAX_EXTRA_ROUNDS][ARRAY_LEN];
    signal term2nd[ARRAY_LEN + MAX_EXTRA_ROUNDS][ARRAY_LEN];
    
    for (var i = 0; i < (ARRAY_LEN + MAX_EXTRA_ROUNDS); i++) {
        isTheResult[i] <== IsEqual()([i, ARRAY_LEN + extraRounds - 1]);
        
        for (var j = 0; j < ARRAY_LEN; j++) {
            term1st[i][j] <== isTheResult[i] * array[1][j];
            term2nd[i][j] <== isTheResult[i] * shuffleHistory[i][j];
            term1st[i][j] === term2nd[i][j];
        }
    }
    
    // Do the original F-Y shuffle
    for (var i = 0; i < (ARRAY_LEN - 1); i++) {
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
