// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IComplianceRegistry} from "../interfaces/IComplianceRegistry.sol";
import {INetworkSupportedRegistry} from "../interfaces/INetworkSupportedRegistry.sol";
import {ProposalLabel} from "../libraries/ProposalLabel.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";

contract ComplianceRegistryV2 is IComplianceRegistry, AccessControl {
    bytes32 public constant ADMIN_ROLE =
        keccak256("compliance-registry.admin.role");
    bytes32 public constant COMPLIANCE_REGISTRY_STUB_ROLE =
        keccak256("compliance-registry.stub.role");

    bool public override isWhitelistRegistry;
    mapping(bytes32 => Compliance) public complianceList;
    INetworkSupportedRegistry public networkRegistry;

    constructor(
        address _admin,
        bool _isWhitelistRegistry,
        address _networkRegistry
    ) {
        _grantRole(ADMIN_ROLE, _admin);
        _setRoleAdmin(COMPLIANCE_REGISTRY_STUB_ROLE, ADMIN_ROLE);
        isWhitelistRegistry = _isWhitelistRegistry;
        networkRegistry = INetworkSupportedRegistry(_networkRegistry);
    }

    function addProposalToList(
        ProposalCommon.Proposal memory proposal
    ) external override onlyRole(COMPLIANCE_REGISTRY_STUB_ROLE) {
        for (uint256 idx = 0; idx < proposal.targets.length; idx++) {
            bytes memory data = proposal.targets[idx];
            (address target, bytes32 networkHash) = decodeBytes(data);
            bytes32 addressKey = getAddressKey(target);
            if (complianceList[addressKey].isInList) continue;
            if (target == address(0)) {
                emit AddProposalToAnotherNetworkList(
                    isWhitelistRegistry,
                    data,
                    networkHash
                );
                continue;
            }
            complianceList[addressKey] = Compliance({
                proposalId: proposal.id,
                isInList: true,
                target: target,
                author: proposal.author
            });
        }
    }

    function getAddressKey(address account) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, "ZKT"));
    }

    function checkAddress(
        address account
    ) external view override returns (bool) {
        return complianceList[getAddressKey(account)].isInList;
    }

    function decodeBytes(
        bytes memory data
    ) public view override returns (address, bytes32) {
        (bytes memory addressBytes, bytes32 networkHash) = abi.decode(
            data,
            (bytes, bytes32)
        );
        if (networkRegistry.isNetworkSupported(networkHash)) {
            address targetAddress = abi.decode(addressBytes, (address));
            return (targetAddress, networkHash);
        } else {
            return (address(0), networkHash);
        }
    }
}