// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library ProposalCommon {
    enum ProposalStatus {
        Unknown,
        Pending,
        Approved,
        Rejected
    }

    struct Proposal {
        bytes32 id;
        address author;
        address[] targetAddresses;
        bool isWhitelist;
        string description;
        uint256 timestamp;
        ProposalStatus status;
        bytes signature;
        uint256 voters;
        uint256 activeNodes;
    }
}
