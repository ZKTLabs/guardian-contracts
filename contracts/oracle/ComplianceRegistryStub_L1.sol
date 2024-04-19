// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IComplianceRegistryStub} from "../interfaces/IComplianceRegistryStub.sol";
import {IComplianceRegistry} from "../interfaces/IComplianceRegistry.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";
import {RegistryFactory} from "./RegistryFactory.sol";

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

    struct RegistrySlot {
        uint256 maxProposals;
        uint256 cumulative;
    }

    RegistrySlot public blacklist;
    RegistrySlot public whitelist;
    RegistryFactory public factory;

    function initialize(address _admin, address _factory) public initializer {
        _grantRole(ADMIN_ROLE, _admin);
        _setRoleAdmin(MANAGER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(GUARDIAN_NODE, ADMIN_ROLE);

        factory = RegistryFactory(_factory);
        blacklist = RegistrySlot({maxProposals: 10, cumulative: 0});
        whitelist = RegistrySlot({maxProposals: 10, cumulative: 0});
        require(hasRole(ADMIN_ROLE, _admin));
    }

    function confirmProposal(
        ProposalCommon.Proposal memory proposal
    ) external override onlyRole(GUARDIAN_NODE) {
        if (proposal.status != ProposalCommon.ProposalStatus.Approved)
            revert ComplianceRegistryStub_L1__InvalidConfirmProposalStatus();
        if (proposal.isWhitelist) {
            uint256 pivot = whitelist.cumulative / whitelist.maxProposals;
            (address registry, bool isCreated) = factory.deploy(
                pivot,
                address(this),
                true
            );
            IComplianceRegistry(registry).addProposalToList(proposal);
            if (isCreated) {
                whitelist.cumulative++;
            }
            emit AddProposalToRegistryList(
                address(registry),
                true,
                proposal.id
            );
        } else {
            uint256 pivot = blacklist.cumulative / blacklist.maxProposals;
            (address registry, bool isCreated) = factory.deploy(
                pivot,
                address(this),
                false
            );
            IComplianceRegistry(registry).addProposalToList(proposal);
            if (isCreated) {
                blacklist.cumulative++;
            }
            emit AddProposalToRegistryList(
                address(registry),
                true,
                proposal.id
            );
        }
    }

    function isWhitelist(
        address account
    ) external view override returns (bool) {
        for (
            uint256 idx = 0;
            idx < whitelist.cumulative / whitelist.maxProposals;
            idx++
        ) {
            (address registry, bool isZero) = factory.get(idx, true);
            if (!isZero) continue;
            if (IComplianceRegistry(registry).checkCompliance(account)) {
                return true;
            }
        }
        return false;
    }

    function isBlacklist(
        address account
    ) external view override returns (bool) {
        for (
            uint256 idx = 0;
            idx < blacklist.cumulative / blacklist.maxProposals;
            idx++
        ) {
            (address registry, bool isZero) = factory.get(idx, false);
            if (!isZero) continue;
            if (IComplianceRegistry(registry).checkCompliance(account)) {
                return true;
            }
        }
        return false;
    }
}
