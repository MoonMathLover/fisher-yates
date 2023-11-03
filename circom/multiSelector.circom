pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/comparators.circom";

template MultiSelector(len) {
    signal input array[len];
    signal input index;
    signal output elementAtIndex;
    
    assert(index < len);
    
    signal equals[len];
    signal summation[len];
    
    for (var i = 0; i < len; i++) {
        // Check whether each `i` is equal to `index`
        
        equals[i] <== IsEqual()([i, index]);
        
        if (i == 0) {
            summation[0] <== (array[0] * equals[i]);
        }
        else {
            summation[i] <== summation[i - 1] + (array[i] * equals[i]);
        }
    }
    
    // Returns 0 + ... + item + ... + 0
    elementAtIndex <== summation[len - 1];
}
