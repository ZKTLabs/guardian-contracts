// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ProposalCommon} from "../libraries/ProposalCommon.sol";

interface IComplianceEvent {
    event AddProposalToAnotherNetworkList(
        bool isWhitelistRegistry,
        bytes data,
        bytes32 networkHash
    );
}

interface IComplianceEntry {
    struct Compliance {
        bytes32 proposalId;
        address target;
        address author;
        bool isInList;
    }
}

interface IComplianceRegistry is IComplianceEntry, IComplianceEvent {
    function addProposalToList(
        ProposalCommon.Proposal memory proposal
    ) external;

    function checkCompliance(address account) external view returns (bool);

    function isExceed() external view returns (bool);

    function decodeBytes(bytes memory data) external view returns (address);
}
