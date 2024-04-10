// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {INetworkSupportedRegistry} from "../interfaces/INetworkSupportedRegistry.sol";

error NetworkSupportedRegistry__NetworkAlreadyExisted();
error NetworkSupportedRegistry__NetworkNotExisted();

contract NetworkSupportedRegistry is INetworkSupportedRegistry, Ownable {
    mapping(bytes32 => bool) private supportedNetworks;

    function isNetworkSupported(
        bytes32 networkHash
    ) external view returns (bool) {
        return supportedNetworks[networkHash];
    }

    function isNetworkSupported(
        string memory networkName
    ) external view returns (bool) {
        return supportedNetworks[keccak256(abi.encode(networkName))];
    }

    function batchAddNetworks(string[] memory networkNames) external {
        for (uint256 idx = 0; idx < networkNames.length; idx++) {
            addNetwork(networkNames[idx]);
        }
    }

    function batchAddNetworks(bytes32[] memory networkHashes) external {
        for (uint256 idx = 0; idx < networkHashes.length; idx++) {
            addNetwork(networkHashes[idx]);
        }
    }

    function batchRevokeNetworks(string[] memory networkNames) external {
        for (uint256 idx = 0; idx < networkNames.length; idx++) {
            revokeNetwork(networkNames[idx]);
        }
    }

    function batchRevokeNetworks(bytes32[] memory networkHashes) external {
        for (uint256 idx = 0; idx < networkHashes.length; idx++) {
            revokeNetwork(networkHashes[idx]);
        }
    }

    function addNetwork(string memory networkName) public onlyOwner {
        bytes32 networkHash = keccak256(abi.encode(networkName));
        if (supportedNetworks[networkHash])
            revert NetworkSupportedRegistry__NetworkAlreadyExisted();
        supportedNetworks[networkHash] = true;
        emit AddNetworkName(networkName, networkHash);
    }

    function addNetwork(bytes32 networkHash) public onlyOwner {
        if (supportedNetworks[networkHash])
            revert NetworkSupportedRegistry__NetworkAlreadyExisted();
        supportedNetworks[networkHash] = true;
        emit AddNetworkHash(networkHash);
    }

    function revokeNetwork(string memory networkName) public onlyOwner {
        bytes32 networkHash = keccak256(abi.encode(networkName));
        if (!supportedNetworks[networkHash])
            revert NetworkSupportedRegistry__NetworkNotExisted();
        supportedNetworks[networkHash] = false;
        emit RevokeNetworkName(networkName, networkHash);
    }

    function revokeNetwork(bytes32 networkHash) public onlyOwner {
        if (!supportedNetworks[networkHash])
            revert NetworkSupportedRegistry__NetworkNotExisted();
        supportedNetworks[networkHash] = false;
        emit RevokeNetworkHash(networkHash);
    }
}
