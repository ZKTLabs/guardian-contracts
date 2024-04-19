// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IProposalManagementEvent {
    event ConfirmProposal(bytes32 proposalId);
    event RejectProposal(bytes32 proposalId);
    event UpdateRegionComplianceRegistryStub(string, bytes, address);
}

interface IProposalManagement is IProposalManagementEvent {
    function createProposal(
        bytes32 proposalId,
        bytes[] calldata targets,
        bool isWhitelist,
        string calldata region,
        bytes calldata signature
    ) external;

    function voteAndConfirmProposals(bytes32[] calldata proposalIds) external;

    function rejectExpiredProposals(
        bytes32[] calldata expiredProposalIds
    ) external;
}
