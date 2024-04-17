// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IComplianceRegistry} from "../interfaces/IComplianceRegistry.sol";
import {INetworkSupportedRegistry} from "../interfaces/INetworkSupportedRegistry.sol";
import {ProposalLabel} from "../libraries/ProposalLabel.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract ComplianceRegistry is IComplianceRegistry, AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant COMPLIANCE_REGISTRY_STUB_ROLE =
        keccak256("COMPLIANCE_REGISTRY_STUB_ROLE");

    bool public override isWhitelistRegistry;
    mapping(bytes32 => Compliance) public complianceList;
    INetworkSupportedRegistry public networkRegistry;

    function initialize(
        address _admin,
        bool _isWhitelistRegistry,
        address _networkRegistry
    ) public initializer {
        __AccessControl_init();

        _setupRole(ADMIN_ROLE, _admin);
        _setRoleAdmin(COMPLIANCE_REGISTRY_STUB_ROLE, ADMIN_ROLE);
        isWhitelistRegistry = _isWhitelistRegistry;
        networkRegistry = INetworkSupportedRegistry(_networkRegistry);
    }

    function addProposalToList(
        ProposalCommon.Proposal memory proposal
    ) external override onlyRole(COMPLIANCE_REGISTRY_STUB_ROLE) {
        for (uint256 idx = 0; idx < proposal.targets.length; idx++) {
            bytes memory data = proposal.targets[idx];
            (
                address target,
                bytes32 networkHash,
                bytes memory labels
            ) = decodeBytes(data);
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
                author: proposal.author,
                labels: labels
            });
        }
    }

    function getAddressKey(address account) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, "ZKT"));
    }

    function getComplianceLabels(
        address account
    ) public view returns (string[] memory) {
        bytes32 key = getAddressKey(account);
        if (!complianceList[key].isInList) return new string[](0);
        string[] memory labels = ProposalLabel.unpack(
            complianceList[key].labels
        );
        return labels;
    }

    function checkAddress(
        address account
    ) external view override returns (bool) {
        return complianceList[getAddressKey(account)].isInList;
    }

    function decodeBytes(
        bytes memory data
    ) public view override returns (address, bytes32, bytes memory) {
        (
            bytes memory addressBytes,
            bytes32 networkHash,
            bytes memory labels
        ) = abi.decode(data, (bytes, bytes32, bytes));
        if (networkRegistry.isNetworkSupported(networkHash)) {
            address targetAddress = abi.decode(addressBytes, (address));
            return (targetAddress, networkHash, labels);
        } else {
            return (address(0), networkHash, new bytes(0));
        }
    }
}
