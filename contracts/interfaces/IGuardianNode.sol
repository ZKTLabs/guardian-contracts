// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ISentryGuardianNodeSlot {
    struct Slot0 {
        uint256 activeNodes;
    }
}

interface IGuardianNode is ISentryGuardianNodeSlot {
    function activeNodes() external view returns (uint256);
    function voteParticipated(address addr) external view returns (uint256);
    function consecutiveOnlineSession(
        address addr
    ) external view returns (uint256);
    function zktEarned(address addr) external view returns (uint256);
}
