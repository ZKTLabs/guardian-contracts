// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IComplianceVersionedMerkleTreeStub {
    function verify(
        bytes32[] memory proof,
        bytes memory encodedData
    ) external view returns (bool);

    function getRoot(
        bytes memory encodedData
    ) external pure returns (bytes32, bytes memory);

    function getData(
        bytes memory encodedData,
        bool withRoot
    )
        external
        pure
        returns (
            address account,
            uint256 label,
            uint256 score,
            uint256 version
        );
}
