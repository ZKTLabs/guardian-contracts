// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

import {IComplianceVersionedMerkleTreeStub} from "../interfaces/IComplianceVersionedMerkleTreeStub.sol";

error ComplianceMerkleTreeStub__RootNotFound();
error ComplianceMerkleTreeStub__RootAlreadyExists();
error ComplianceMerkleTreeStub__InvalidVersion();

contract ComplianceVersionedMerkleTreeStub is
    IComplianceVersionedMerkleTreeStub,
    Ownable,
    Pausable
{
    mapping(bytes32 => uint256) public versionedMerkleTrees;

    constructor(address _initOwner) Ownable(_initOwner) {}

    function updateVersionedMerkleTree(
        bytes32 _root,
        uint256 _version,
        bool isAdd
    ) public onlyOwner {
        if (_version == 0) {
            revert ComplianceMerkleTreeStub__InvalidVersion();
        }
        if (isAdd) {
            if (versionedMerkleTrees[_root] != 0) {
                revert ComplianceMerkleTreeStub__RootAlreadyExists();
            }
            versionedMerkleTrees[_root] = _version;
        } else {
            if (versionedMerkleTrees[_root] == 0) {
                revert ComplianceMerkleTreeStub__RootNotFound();
            }
            delete versionedMerkleTrees[_root];
        }
    }

    function verify(
        bytes32[] memory proof,
        bytes memory encodedData
    ) external view override returns (bool) {
        /// @dev The encodedData is expected to be a concatenation of the following fields:
        /// @dev bytes32, bytes
        /// @dev The first is the root of the merkle tree, and the second is the data to be verified
        (bytes32 _root, bytes memory _subData) = abi.decode(
            encodedData,
            (bytes32, bytes)
        );
        uint256 version = versionedMerkleTrees[_root];
        /// @dev The _subData is expected to be a concatenation of the following fields:
        /// @dev address, uint256, uint256, uint256
        /// @dev The first is user address, the second is the label, the third is the score, and the fourth is the version of the merkle tree
        if (version == 0) {
            revert ComplianceMerkleTreeStub__RootNotFound();
        }
        (, , , uint256 _version) = abi.decode(
            _subData,
            (address, uint256, uint256, uint256)
        );
        if (version != _version) {
            revert ComplianceMerkleTreeStub__InvalidVersion();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(encodedData)));
        return MerkleProof.verify(proof, _root, leaf);
    }
}
