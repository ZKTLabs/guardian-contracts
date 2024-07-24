// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IComplianceVersionedMerkleTreeStub.sol";

abstract contract ComplianceAggregatorV2 {
    IComplianceVersionedMerkleTreeStub public stub;

    constructor(address complianceVersionedMerkleTreeStub) {
        stub = IComplianceVersionedMerkleTreeStub(
            complianceVersionedMerkleTreeStub
        );
    }
}
