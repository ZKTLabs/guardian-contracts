// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

//import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
//import {IComplianceRegistryStub} from "../interfaces/IComplianceRegistryStub.sol";
//import {IComplianceRegistry} from "../interfaces/IComplianceRegistry.sol";
//import {ProposalCommon} from "../libraries/ProposalCommon.sol";
//import {RegistryFactory} from "./RegistryFactory.sol";
//
//error ComplianceRegistryStub__InvalidConfirmProposalStatus();
//error ComplianceRegistryStub__WhitelistRegistryNotEnough();
//error ComplianceRegistryStub__BlacklistRegistryNotEnough();
//
//contract ComplianceRegistryStub is
//    IComplianceRegistryStub,
//    AccessControlUpgradeable
//{
//    bytes32 public constant ADMIN_ROLE =
//        keccak256("compliance-registry-stub.admin.role");
//    bytes32 public constant PROPOSAL_MANAGEMENT_ROLE =
//        keccak256("compliance-registry-stub.proposal_management.role");
//
//    struct RegistrySlot {
//        uint256 maxProposals;
//        uint256 cumulative;
//    }
//
//    RegistrySlot public blacklist;
//    RegistrySlot public whitelist;
//    RegistryFactory public factory;
//
//    function initialize(
//        address _admin,
//        address _factory,
//        address _proposal_management
//    ) public initializer {
//        _grantRole(ADMIN_ROLE, _admin);
//        _grantRole(PROPOSAL_MANAGEMENT_ROLE, _proposal_management);
//
//        factory = RegistryFactory(_factory);
//        blacklist = RegistrySlot({maxProposals: 10, cumulative: 0});
//        whitelist = RegistrySlot({maxProposals: 10, cumulative: 0});
//        require(hasRole(ADMIN_ROLE, _admin));
//    }
//
//    function confirmProposal(
//        ProposalCommon.Proposal memory proposal
//    ) external override onlyRole(PROPOSAL_MANAGEMENT_ROLE) {
//        if (proposal.status != ProposalCommon.ProposalStatus.Approved)
//            revert ComplianceRegistryStub__InvalidConfirmProposalStatus();
//        if (proposal.isWhitelist) {
//            uint256 pivot = whitelist.cumulative / whitelist.maxProposals;
//            address registry = factory.deploy(pivot, address(this), true);
//            IComplianceRegistry(registry).addProposalToList(proposal);
//            whitelist.cumulative++;
//            emit AddProposalToRegistryList(
//                address(registry),
//                true,
//                proposal.id
//            );
//        } else {
//            uint256 pivot = blacklist.cumulative / blacklist.maxProposals;
//            address registry = factory.deploy(pivot, address(this), false);
//            IComplianceRegistry(registry).addProposalToList(proposal);
//            blacklist.cumulative++;
//            emit AddProposalToRegistryList(
//                address(registry),
//                true,
//                proposal.id
//            );
//        }
//    }
//
//    function isWhitelist(
//        address account
//    ) external view override returns (bool) {
//        for (
//            uint256 idx = 0;
//            idx < whitelist.cumulative / whitelist.maxProposals;
//            idx++
//        ) {
//            (address registry, bool isZero) = factory.get(idx, true);
//            if (!isZero) continue;
//            if (IComplianceRegistry(registry).checkCompliance(account)) {
//                return true;
//            }
//        }
//        return false;
//    }
//
//    function isBlacklist(
//        address account
//    ) external view override returns (bool) {
//        for (
//            uint256 idx = 0;
//            idx < blacklist.cumulative / blacklist.maxProposals;
//            idx++
//        ) {
//            (address registry, bool isZero) = factory.get(idx, false);
//            if (!isZero) continue;
//            if (IComplianceRegistry(registry).checkCompliance(account)) {
//                return true;
//            }
//        }
//        return false;
//    }
//}
