// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IComplianceRegistryStub} from "../interfaces/IComplianceRegistryStub.sol";
import {IComplianceRegistry} from "../interfaces/IComplianceRegistry.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";

error ComplianceRegistryStub_L1__InvalidConfirmProposalStatus();
error ComplianceRegistryStub_L1__WhitelistRegistryNotEnough();
error ComplianceRegistryStub_L1__BlacklistRegistryNotEnough();

contract ComplianceRegistryStubV2 is IComplianceRegistryStub, AccessControl {
    bytes32 public constant ADMIN_ROLE =
        keccak256("compliance-registry-stub.admin.role");
    bytes32 public constant MANAGER_ROLE =
        keccak256("compliance-registry-stub.manager.role");
    bytes32 public constant GUARDIAN_NODE =
        keccak256("compliance-registry-stub.guardian.role");

    mapping(uint256 => IComplianceRegistry) public whitelistRegistries;
    mapping(uint256 => IComplianceRegistry) public blacklistRegistries;

    uint256[2] public registriesCount; // 0 - whitelist 1 - blacklist
    uint256[2] public maxProposalEachRegistries; // 0 - whitelist 1 - blacklist
    uint256[2] public cumulativeProposals; // 0 - whitelist 1 - blacklist

    constructor(address _admin) {
        _grantRole(ADMIN_ROLE, _admin);
        _setRoleAdmin(MANAGER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(GUARDIAN_NODE, ADMIN_ROLE);

        maxProposalEachRegistries[0] = 10;
        maxProposalEachRegistries[1] = 10;
        cumulativeProposals[0] = 0;
        cumulativeProposals[1] = 0;
        registriesCount[0] = 0;
        registriesCount[1] = 0;
        require(hasRole(ADMIN_ROLE, _admin));
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
            whitelistRegistries[registriesCount[0]] = registry;
            registriesCount[0]++;
        } else {
            blacklistRegistries[registriesCount[1]] = registry;
            registriesCount[1]++;
        }
        emit AddRegistryToList(address(registry), useWhitelist);
    }

    function replaceRegistry(
        IComplianceRegistry registry,
        bool useWhitelist,
        uint256 index
    ) external onlyRole(MANAGER_ROLE) {
        if (useWhitelist) {
            require(index < registriesCount[0]);
            whitelistRegistries[index] = registry;
        } else {
            require(index < registriesCount[1]);
            blacklistRegistries[index] = registry;
        }
        emit ReplaceRegistry(address(registry), useWhitelist, index);
    }

    function confirmProposal(
        ProposalCommon.Proposal memory proposal
    ) external override onlyRole(GUARDIAN_NODE) {
        if (proposal.status != ProposalCommon.ProposalStatus.Approved)
            revert ComplianceRegistryStub_L1__InvalidConfirmProposalStatus();
        if (proposal.isWhitelist) {
            uint256 pivot = cumulativeProposals[0] /
                maxProposalEachRegistries[0];
            if (pivot >= registriesCount[0])
                revert ComplianceRegistryStub_L1__WhitelistRegistryNotEnough();
            IComplianceRegistry whitelistRegistry = whitelistRegistries[pivot];
            whitelistRegistry.addProposalToList(proposal);
            cumulativeProposals[0]++;
            emit AddProposalToRegistryList(
                address(whitelistRegistry),
                true,
                proposal.id
            );
        } else {
            uint256 pivot = cumulativeProposals[1] /
                maxProposalEachRegistries[1];
            if (pivot >= registriesCount[1])
                revert ComplianceRegistryStub_L1__BlacklistRegistryNotEnough();
            IComplianceRegistry blacklistRegistry = blacklistRegistries[pivot];
            blacklistRegistry.addProposalToList(proposal);
            cumulativeProposals[1]++;
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
        for (uint256 idx = 0; idx < registriesCount[0]; idx++) {
            if (whitelistRegistries[idx].checkAddress(account)) {
                return true;
            }
        }
        return false;
    }

    function isBlacklist(
        address account
    ) external view override returns (bool) {
        for (uint256 idx = 0; idx < registriesCount[1]; idx++) {
            if (blacklistRegistries[idx].checkAddress(account)) {
                return true;
            }
        }
        return false;
    }
}
