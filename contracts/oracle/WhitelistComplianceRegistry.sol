// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ComplianceRegistry} from "./ComplianceRegistry.sol";

contract WhitelistComplianceRegistry is ComplianceRegistry {
    bool private isWhitelist = true;

    function verify() external view returns (bool) {
        return isWhitelist;
    }
}
