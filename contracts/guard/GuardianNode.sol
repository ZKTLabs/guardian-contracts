// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IGuardianNode} from "../interfaces/IGuardianNode.sol";

contract GuardianNode is IGuardianNode, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    Slot0 public slot0;

    constructor() {
        _grantRole(ADMIN_ROLE, _msgSender());
        _setRoleAdmin(GUARDIAN_ROLE, ADMIN_ROLE);
        slot0 = Slot0({activeNodes: 0});
    }

    function syncActiveNodes(
        uint256 _activeNodes
    ) external onlyRole(GUARDIAN_ROLE) {
        slot0.activeNodes = _activeNodes;
    }

    function activeNodes() external view override returns (uint256) {
        return slot0.activeNodes;
    }

    function voteParticipated(address) external pure returns (uint256) {
        return 0;
    }

    function consecutiveOnlineSession(address) external pure returns (uint256) {
        return 0;
    }

    function zktEarned(address) external pure returns (uint256) {
        return 0;
    }
}
