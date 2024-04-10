// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface INetworkSupportedRegistryEvent {

    event AddNetworkHash(bytes32 networkHash);

    event AddNetworkName(string, bytes32);

    event RevokeNetworkHash(bytes32 networkHash);

    event RevokeNetworkName(string, bytes32);
}

interface INetworkSupportedRegistry is INetworkSupportedRegistryEvent {

    function isNetworkSupported(bytes32 networkHash) external view returns (bool);

    function isNetworkSupported(string memory networkName) external view returns (bool);
}
