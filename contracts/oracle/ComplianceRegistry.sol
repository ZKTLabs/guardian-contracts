// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IComplianceRegistry} from "../interfaces/IComplianceRegistry.sol";
import {INetworkSupportedRegistry} from "../interfaces/INetworkSupportedRegistry.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";

contract ComplianceRegistry is IComplianceRegistry, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant COMPLIANCE_REGISTRY_STUB_ROLE =
        keccak256("COMPLIANCE_REGISTRY_STUB_ROLE");

    bool public isWhitelistRegistry;
    mapping(address => Compliance) public complianceList;
    INetworkSupportedRegistry public networkRegistry;

    constructor(
        bool _isWhitelistRegistry,
        address _networkRegistry
    ) {
        _setupRole(ADMIN_ROLE, _msgSender());
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
            if (complianceList[target].isInList) continue;
            if (target == address(0)) {
                emit AddProposalToAnotherNetworkList(data, networkHash);
            }
            complianceList[target] = Compliance({
                proposalId: proposal.id,
                isInList: true,
                author: proposal.author,
                description: proposal.description
            });
        }
    }

    function checkAddress(
        address account
    ) external view override returns (bool) {
        return complianceList[account].isInList;
    }

    function revokeCompliance(
        address account,
        address author,
        bytes32 proposalId
    ) external override onlyRole(COMPLIANCE_REGISTRY_STUB_ROLE) {
        complianceList[account].isInList = false;
        complianceList[account].proposalId = proposalId;
        complianceList[account].description = "revoke";
        complianceList[account].author = author;
        delete complianceList[account];
    }

    function decodeBytes(bytes memory data) public override view returns (address, bytes32)
    {
        (bytes memory addressBytes, bytes32 networkHash) = abi.decode(data, (bytes, bytes32));
        if (networkRegistry.isNetworkSupported(networkHash)) {
            address targetAddress = abi.decode(addressBytes, (address));
            return (targetAddress, networkHash);
        } else {
            return (address(0), networkHash);
        }
    }
}
