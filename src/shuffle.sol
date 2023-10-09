// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "@vectorized/solady/src/auth/Ownable.sol";

contract Shuffle is Ownable {
    
    uint248 public entropy;
    bytes32 public entropyCommitment;
    bytes32 public shuffledArrayCommitment;
    
    uint248 public smallestElement;
    uint248 public largestElement;
    uint248 public numberOfElement;
    
    constructor() {
        _initializeOwner(msg.sender);
    }
    
    function commitEntropy(bytes32 commitment) external onlyOwner {
        entropyCommitment = commitment;
    }
    
    function revealEntropy(uint248 revealing) external onlyOwner {
        if (entropyCommitment != keccak256(abi.encodePacked(revealing))) {
            revert("Revealing value does not match commitment.");
        }
        
        entropy = revealing;
    }
    
    // Assume elements of the array are ranging from an unique non-decresing continous set
    function commitShuffledArray(
        uint248 smallest,
        uint248 largest,
        uint248 numberOf
    ) external onlyOwner {
        smallestElement = smallest;
        largestElement = largest;
        numberOfElement = numberOf;
    }
    
    function shufflingArray(uint248[] memory array) view public {
        if (entropy == 0) {
            revert("'entropy' have not been set yet.");
        }
        
        uint248 length = uint248(array.length);
        
        for (uint248 i = 0; i < length - 1;) {
            uint248 j = i + uint248(entropy) % (length - i);
            (array[i], array[j]) = (array[j], array[i]);
            unchecked { i++; }
        }
    }
}
