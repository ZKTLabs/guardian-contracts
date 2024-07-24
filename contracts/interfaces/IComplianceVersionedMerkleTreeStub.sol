// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IComplianceVersionedMerkleTreeStub {
    function verify(
        bytes32[] memory proof,
        bytes memory encodedData
    ) external view returns (bool);
}
