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
    
    component nonZeroTest = IsZero();
    nonZeroTest.in <== entropy;
    nonZeroTest.out === 0;
    
    component lessThanTest = LessThan(252);
    lessThanTest.in[0] <== pivotIndex;
    lessThanTest.in[1] <== len;
    lessThanTest.out === 1;
    
    component mod = Modulo();
    mod.a <== entropy;
    mod.b <== (len - pivotIndex);
    
    // Limit `enableFlag` to 0/1
    enableFlag * (1 - enableFlag) === 0;
    
    // Test the validity of swaping choosing by F-Y algorithm
    var i = pivotIndex;
    var j = pivotIndex + mod.c;
    
    component oldArrayAtI = MultiSelector(len);
    for (var m = 0; m < len; m++) {
        oldArrayAtI.array[m] <== oldArray[m];
    }
    oldArrayAtI.index <== i;
    
    component oldArrayAtJ = MultiSelector(len);
    for (var m = 0; m < len; m++) {
        oldArrayAtJ.array[m] <== oldArray[m];
    }
    oldArrayAtJ.index <== j;
    
    component newArrayAtI = MultiSelector(len);
    for (var m = 0; m < len; m++) {
        newArrayAtI.array[m] <== newArray[m];
    }
    newArrayAtI.index <== i;
    
    component newArrayAtJ = MultiSelector(len);
    for (var m = 0; m < len; m++) {
        newArrayAtJ.array[m] <== newArray[m];
    }
    newArrayAtJ.index <== j;
    
    signal equation1st <== oldArrayAtI.elementAtIndex - newArrayAtJ.elementAtIndex;
    signal equation2nd <== oldArrayAtJ.elementAtIndex - newArrayAtI.elementAtIndex;
    
    equation1st * enableFlag === 0;
    equation2nd * enableFlag === 0;
}