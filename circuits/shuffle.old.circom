pragma circom 2.0.0;

template Shuffle(len) {
    signal input entropy;
    // Assume `in_array` is an one-based numbering array
    // signal input in_array[len];
    signal output out_array[len];
    
    // Test `entropy` is nonzero
    signal inv_entropy;
    inv_entropy <-- (entropy == 0) ? 0 : (1 / entropy);
    0 === 1 - entropy * inv_entropy;
    
    var in_array[len];
    for (var i = 0; i < (len - 1); i++) {
        in_array[i] = i + 1; // one-based numbering
    }
    
    for (var i = 0; i < (len - 1); i++) {
        var j = i + entropy % (len - i);
        
        var temp = in_array[i];
        in_array[i] = in_array[j];
        in_array[j] = temp;
    }
    
    for (var i = 0; i < (len - 1); i++) {
        out_array[i] <-- in_array[i];
        out_array[i] === out_array[i];
    }
}