// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ProposalCommon} from "../libraries/ProposalCommon.sol";

interface IComplianceRegistryStubEvent {
    event AddToBlacklist(bytes32);

    event AddToWhitelist(bytes32);
}

interface IComplianceRegistryStub is IComplianceRegistryStubEvent {
    function confirmProposal(ProposalCommon.Proposal memory proposal) external;

    function isWhitelist(address account) external view returns (bool);

    function isBlacklist(address account) external view returns (bool);
}
