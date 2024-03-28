// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IComplianceRegistry} from "../interfaces/IComplianceRegistry.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";

contract ComplianceRegistry is IComplianceRegistry, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant COMPLIANCE_REGISTRY_STUB_ROLE =
        keccak256("COMPLIANCE_REGISTRY_STUB_ROLE");

    bool public isWhitelistRegistry;
    mapping(address => Compliance) public complianceList;

    constructor(bool _isWhitelistRegistry) {
        _setupRole(ADMIN_ROLE, _msgSender());
        _setRoleAdmin(COMPLIANCE_REGISTRY_STUB_ROLE, ADMIN_ROLE);

        isWhitelistRegistry = _isWhitelistRegistry;
    }

    function addProposalToList(
        ProposalCommon.Proposal memory proposal
    ) external override onlyRole(COMPLIANCE_REGISTRY_STUB_ROLE) {
        for (uint256 idx = 0; idx < proposal.targetAddresses.length; idx++) {
            address target = proposal.targetAddresses[idx];
            if (complianceList[target].isInList) continue;
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
}
