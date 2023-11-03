pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/comparators.circom";

template MultiSelector(len) {
    signal input array[len];
    signal input index;
    signal output elementAtIndex;
    
    assert(index < len);
    
    component equals[len];
    signal summation[len];
    
    for (var i = 0; i < len; i++) {
        // Check whether each `i` is equal to `index`
        
        equals[i] = IsEqual();
        equals[i].in[0] <== i;
        equals[i].in[1] <== index;
        
        if (i == 0) {
            summation[0] <==  (array[0] * equals[i].out);
        }
        else {
            summation[i] <==  summation[i - 1] + (array[i] * equals[i].out);
        }
    }

    // Returns 0 + ... + item + ... + 0
    elementAtIndex <== summation[len - 1];
}
