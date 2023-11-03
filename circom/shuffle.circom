pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/comparators.circom";
include "./multiSelector.circom";
include "./modulo.circom";

template Shuffle(len) {
    signal input entropy;
    signal input pivotIndex;
    signal input oldArray[len];
    signal input newArray[len];
    signal input enableFlag;
    
    signal entropyCheck <== IsZero()(entropy);
    entropyCheck === 0;
    
    signal pivotIndexCheck <== LessThan(252)([pivotIndex, len]);
    pivotIndexCheck === 1;
    
    enableFlag * (1 - enableFlag) === 0; // `enableFlag` ${\in}$ {0,1}
    
    // Test the validity of swaping choosing by F-Y algorithm
    signal mod <== Modulo()(entropy, (len - pivotIndex));
    var i = pivotIndex;
    var j = pivotIndex + mod;
    
    signal oldArrayAtI <== MultiSelector(len)(oldArray, i);
    signal oldArrayAtJ <== MultiSelector(len)(oldArray, j);
    signal newArrayAtI <== MultiSelector(len)(newArray, i);
    signal newArrayAtJ <== MultiSelector(len)(newArray, j);
    
    signal equation1st <== oldArrayAtI - newArrayAtJ;
    signal equation2nd <== oldArrayAtJ - newArrayAtI;
    
    equation1st * enableFlag === 0;
    equation2nd * enableFlag === 0;
}