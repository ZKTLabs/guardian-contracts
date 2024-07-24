// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "../oracle/ComplianceVersionedMerkleTreeStub.sol";

contract MockComplianceVersionedMerkleTreeStubHook is
    ComplianceVersionedMerkleTreeStub
{
    constructor() ComplianceVersionedMerkleTreeStub(_msgSender()) {}

    function verifyHook(bytes memory data) external view {
        (bytes32[] memory proof, bytes memory encodedData) = abi.decode(
            data,
            (bytes32[], bytes)
        );
        require(
            verify(proof, encodedData),
            "MockComplianceVersionedMerkleTreeStubHook: Invalid proof"
        );
    }

    function abiEncode(
        bytes32[] memory proof,
        bytes memory encodedData
    ) external pure returns (bytes memory) {
        return abi.encode(proof, encodedData);
    }
}
