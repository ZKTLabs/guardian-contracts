// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ComplianceRegistry} from "./ComplianceRegistry.sol";

contract BlacklistComplianceRegistry is ComplianceRegistry {
    bool private isWhitelist = false;

    function verify() external view returns (bool) {
        return isWhitelist;
    }
}
