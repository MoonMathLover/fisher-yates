pragma circom 2.0.0;

// Perform c <== a % b

template Modulo() {
    signal input a;
    signal input b;
    signal output c;
    
    signal quotient ;
    quotient <-- a \ b;
    
    c <== a - (b * quotient);
}
