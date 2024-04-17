// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IComplianceRegistryStub} from "../interfaces/IComplianceRegistryStub.sol";
import {IComplianceRegistry} from "../interfaces/IComplianceRegistry.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";

error ComplianceRegistryStub_L1__InvalidConfirmProposalStatus();
error ComplianceRegistryStub_L1__WhitelistRegistryNotEnough();
error ComplianceRegistryStub_L1__BlacklistRegistryNotEnough();

contract ComplianceRegistryStub_L1 is
    IComplianceRegistryStub,
    AccessControlUpgradeable
{
    bytes32 public constant ADMIN_ROLE =
        keccak256("compliance-registry-stub-l1.admin.role");
    bytes32 public constant MANAGER_ROLE =
        keccak256("compliance-registry-stub-1.manager.role");
    bytes32 public constant GUARDIAN_NODE =
        keccak256("compliance-registry-stub-l1.guardian.role");

    IComplianceRegistry[] public whitelistRegistries;
    IComplianceRegistry[] public blacklistRegistries;

    uint256[2] public maxProposalEachRegistries; // 0 - whitelist 1 - blacklist
    uint256[2] public cumulativeProposals; // 0 - whitelist 1 - blacklist

    function initialize(address _admin) public initializer {
        _grantRole(ADMIN_ROLE, _admin);
        _setRoleAdmin(MANAGER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(GUARDIAN_NODE, ADMIN_ROLE);

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
        IComplianceRegistry[] storage registries;
        if (useWhitelist) {
            registries = whitelistRegistries;
        } else {
            registries = blacklistRegistries;
        }
        for (uint256 idx = 0; idx < registries.length; idx++) {
            if (address(registries[idx]) == address(registry)) {
                return;
            }
        }
        registries.push(registry);
        emit AddRegistryToList(address(registry), useWhitelist);
    }

    function confirmProposal(
        ProposalCommon.Proposal memory proposal
    ) external override onlyRole(GUARDIAN_NODE) {
        if (proposal.status != ProposalCommon.ProposalStatus.Approved)
            revert ComplianceRegistryStub_L1__InvalidConfirmProposalStatus();
        if (proposal.isWhitelist) {
            uint256 pivot = cumulativeProposals[0] /
                maxProposalEachRegistries[0];
            if (pivot > whitelistRegistries.length)
                revert ComplianceRegistryStub_L1__WhitelistRegistryNotEnough();
            IComplianceRegistry whitelistRegistry = whitelistRegistries[pivot];
            whitelistRegistry.addProposalToList(proposal);
            emit AddProposalToRegistryList(
                address(whitelistRegistry),
                true,
                proposal.id
            );
        } else {
            uint256 pivot = cumulativeProposals[0] /
                maxProposalEachRegistries[0];
            if (pivot > blacklistRegistries.length)
                revert ComplianceRegistryStub_L1__WhitelistRegistryNotEnough();
            IComplianceRegistry blacklistRegistry = blacklistRegistries[pivot];
            blacklistRegistry.addProposalToList(proposal);
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
