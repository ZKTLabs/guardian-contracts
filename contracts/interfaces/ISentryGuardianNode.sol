// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ISentryGuardianNodeSlot {
    struct Slot0 {
        uint256 activeNodes;
    }
}

interface ISentryGuardianNode is ISentryGuardianNodeSlot {
    function activeNodes() external view returns (uint256);
}
