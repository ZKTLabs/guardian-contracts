// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IComplianceRegistryStub} from "../interfaces/IComplianceRegistryStub.sol";
import {IComplianceRegistry} from "../interfaces/IComplianceRegistry.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";

error ComplianceRegistryStub__InvalidConfirmProposalStatus();
error ComplianceRegistryStub__WhitelistRegistryNotEnough();
error ComplianceRegistryStub__BlacklistRegistryNotEnough();

contract ComplianceRegistryStub is
    IComplianceRegistryStub,
    AccessControlUpgradeable
{
    bytes32 public constant ADMIN_ROLE =
        keccak256("compliance-registry-stub.admin.role");
    bytes32 public constant MANAGER_ROLE =
        keccak256("compliance-registry-stub.manager.role");
    bytes32 public constant PROPOSAL_MANAGEMENT_ROLE =
        keccak256("compliance-registry-stub.proposal_management.role");

    IComplianceRegistry[] public whitelistRegistries;
    IComplianceRegistry[] public blacklistRegistries;

    uint256[2] public maxProposalEachRegistries; // 0 - whitelist 1 - blacklist
    uint256[2] public cumulativeProposals; // 0 - whitelist 1 - blacklist

    function initialize(address _admin) public initializer {
        _grantRole(ADMIN_ROLE, _admin);
        _setRoleAdmin(PROPOSAL_MANAGEMENT_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MANAGER_ROLE, ADMIN_ROLE);

        maxProposalEachRegistries[0] = 100;
        maxProposalEachRegistries[1] = 100;
        cumulativeProposals[0] = 0;
        cumulativeProposals[1] = 0;
    }

    function updateMaxProposalEachRegistries(
        uint256[] memory _maxProposalEachRegistries
    ) external onlyRole(MANAGER_ROLE) {
        maxProposalEachRegistries[0] = _maxProposalEachRegistries[0];
        maxProposalEachRegistries[1] = _maxProposalEachRegistries[1];
    }

    function addRegistry(
        IComplianceRegistry registry,
        bool useWhitelist
    ) external onlyRole(MANAGER_ROLE) {
        if (useWhitelist) {
            for (uint256 idx = 0; idx < whitelistRegistries.length; idx++) {
                if (address(whitelistRegistries[idx]) == address(registry)) {
                    return;
                }
            }
            whitelistRegistries.push(registry);
        } else {
            for (uint256 idx = 0; idx < blacklistRegistries.length; idx++) {
                if (address(blacklistRegistries[idx]) == address(registry)) {
                    return;
                }
            }
            blacklistRegistries.push(registry);
        }
        emit AddRegistryToList(address(registry), useWhitelist);
    }

    function confirmProposal(
        ProposalCommon.Proposal memory proposal
    ) external override onlyRole(PROPOSAL_MANAGEMENT_ROLE) {
        if (proposal.status != ProposalCommon.ProposalStatus.Approved)
            revert ComplianceRegistryStub__InvalidConfirmProposalStatus();
        if (proposal.isWhitelist) {
            uint256 pivot = cumulativeProposals[0] /
                maxProposalEachRegistries[0];
            if (pivot > whitelistRegistries.length)
                revert ComplianceRegistryStub__WhitelistRegistryNotEnough();
            IComplianceRegistry whitelistRegistry = whitelistRegistries[pivot];
            whitelistRegistry.addProposalToList(proposal);
            cumulativeProposals[0] += 1;
            emit AddProposalToRegistryList(
                address(whitelistRegistry),
                true,
                proposal.id
            );
        } else {
            uint256 pivot = cumulativeProposals[1] /
                            maxProposalEachRegistries[1];
            if (pivot >= blacklistRegistries.length)
                revert ComplianceRegistryStub__BlacklistRegistryNotEnough();
            IComplianceRegistry blacklistRegistry = blacklistRegistries[pivot];
            blacklistRegistry.addProposalToList(proposal);
            cumulativeProposals[1] += 1;
            emit AddProposalToRegistryList(
                address(blacklistRegistry),
                false,
                proposal.id
            );
        }
    }

    function isWhitelist(
        address account
    ) external view override returns (bool) {
        for (uint256 idx = 0; idx < whitelistRegistries.length; idx++) {
            if (whitelistRegistries[idx].checkAddress(account)) {
                return true;
            }
        }
        return false;
    }

    function isBlacklist(
        address account
    ) external view override returns (bool) {
        for (uint256 idx = 0; idx < blacklistRegistries.length; idx++) {
            if (blacklistRegistries[idx].checkAddress(account)) {
                return true;
            }
        }
        return false;
    }
}
