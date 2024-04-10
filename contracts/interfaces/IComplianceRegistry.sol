// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ProposalCommon} from "../libraries/ProposalCommon.sol";

interface IComplianceEvent {

    event AddProposalToAnotherNetworkList(bytes data, bytes32 networkHash);
}

interface IComplianceEntry {
    struct Compliance {
        bytes32 proposalId;
        address author;
        string description;
        bool isInList;
    }
}

interface IComplianceRegistry is IComplianceEntry, IComplianceEvent {
    function addProposalToList(
        ProposalCommon.Proposal memory proposal
    ) external;

    function checkAddress(address account) external view returns (bool);

    function revokeCompliance(
        address account,
        address author,
        bytes32 proposalId
    ) external;

    function decodeBytes(bytes memory data) external view returns (address, bytes32);
}
