// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IProposalManagement} from "../interfaces/IProposalManagement.sol";
import {IComplianceRegistryStub} from "../interfaces/IComplianceRegistryStub.sol";
import {IGuardianNode} from "../interfaces/IGuardianNode.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";

error ProposalManagement__AlreadyExistProposal(bytes32 proposalId);
error ProposalManagement__InvalidSignature();
error ProposalManagement__OnlyVoteForPendingProposal();

contract ProposalManagement is IProposalManagement, AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE =
        keccak256("proposal-management.admin.role");
    bytes32 public constant MANAGER_ROLE =
        keccak256("proposal-management.manager.role");
    bytes32 public constant SPEAKER_ROLE =
        keccak256("proposal-management.speaker.role");
    bytes32 public constant VOTER_ROLE =
        keccak256("proposal-management.voter.role");
    bytes32 public constant GUARDIAN_ROLE =
        keccak256("proposal-management.guardian.role");

    uint256 public constant EXPIRY_DAYS = 7 days;

    bytes32[] public proposalIdList;
    mapping(bytes32 => ProposalCommon.Proposal) public proposals;
    IGuardianNode public sentry;
    mapping(bytes => IComplianceRegistryStub) public stubs;

    function initialize(
        address _admin,
        IGuardianNode guardianNode
    ) public initializer {
        _grantRole(ADMIN_ROLE, _admin);
        _setRoleAdmin(MANAGER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(SPEAKER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(VOTER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(GUARDIAN_ROLE, ADMIN_ROLE);
        sentry = IGuardianNode(guardianNode);
    }

    function updateRegionComplianceRegistryStub(
        string memory region,
        IComplianceRegistryStub stub
    ) external onlyRole(MANAGER_ROLE) {
        bytes memory regionBytes = bytes(region);
        stubs[regionBytes] = stub;

        emit UpdateRegionComplianceRegistryStub(
            region,
            regionBytes,
            address(stub)
        );
    }

    function createProposal(
        bytes32 proposalId,
        bytes[] calldata targets,
        bool isWhitelist,
        string calldata region,
        bytes calldata signature
    ) external override onlyRole(SPEAKER_ROLE) {
        if (
            proposals[proposalId].status !=
            ProposalCommon.ProposalStatus.Unknown
        ) {
            revert ProposalManagement__AlreadyExistProposal(proposalId);
        }
        bytes memory targetBytes;
        for (uint i = 0; i < targets.length; i++) {
            targetBytes = abi.encodePacked(targetBytes, targets[i]);
        }
        bytes32 hash = keccak256(
            abi.encodePacked(proposalId, targetBytes, isWhitelist)
        );
        if (ECDSA.recover(hash, signature) != _msgSender())
            revert ProposalManagement__InvalidSignature();

        // add proposalId into global list
        proposalIdList.push(proposalId);
        proposals[proposalId] = ProposalCommon.Proposal({
            id: proposalId,
            author: _msgSender(),
            targets: targets,
            isWhitelist: isWhitelist,
            region: region,
            timestamp: block.timestamp,
            status: ProposalCommon.ProposalStatus.Pending,
            signature: signature,
            voters: 0,
            activeNodes: sentry.activeNodes()
        });
    }

    function voteAndConfirmProposals(
        bytes32[] calldata proposalIds
    ) external override onlyRole(VOTER_ROLE) {
        for (uint256 idx = 0; idx < proposalIds.length; idx++) {
            bytes32 proposalId = proposalIds[idx];
            if (
                proposals[proposalId].status !=
                ProposalCommon.ProposalStatus.Pending
            ) revert ProposalManagement__OnlyVoteForPendingProposal();
            proposals[proposalId].voters += 1;
            if (
                proposals[proposalId].voters * 2 >
                proposals[proposalId].activeNodes
            ) {
                proposals[proposalId].status = ProposalCommon
                    .ProposalStatus
                    .Approved;
            }
            if (
                proposals[proposalId].status ==
                ProposalCommon.ProposalStatus.Approved
            ) {
                IComplianceRegistryStub stub = stubs[
                    bytes(proposals[proposalId].region)
                ];
                stub.confirmProposal(proposals[proposalId]);
                emit ConfirmProposal(proposalId);
            }
        }
    }

    function rejectExpiredProposals(
        bytes32[] calldata expiredProposalIds
    ) external override onlyRole(GUARDIAN_ROLE) {
        for (uint256 idx = 0; idx < expiredProposalIds.length; idx++) {
            bytes32 proposalId = expiredProposalIds[idx];
            if (
                proposals[proposalId].status !=
                ProposalCommon.ProposalStatus.Pending
            ) continue;
            // double check expired timestamp
            if (
                proposals[proposalId].timestamp + EXPIRY_DAYS >= block.timestamp
            ) {
                proposals[proposalId].status = ProposalCommon
                    .ProposalStatus
                    .Rejected;
                emit RejectProposal(proposalId);
            }
        }
    }
}
