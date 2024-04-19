// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {RegistryFactory} from "./RegistryFactory.sol";
import {ComplianceRegistry} from "./ComplianceRegistry.sol";

contract ComplianceRegistryIndex is AccessControl, Initializable {
    bytes32 public constant COMPLIANCE_REGISTRY_STUB_ROLE =
        keccak256("compliance-registry-index.stub.role");

    struct RegistrySlot {
        uint256 stepCumulative;
        uint256 cumulative;
    }

    RegistrySlot public blacklist;
    RegistrySlot public whitelist;
    RegistryFactory public factory;

    function initialize(address _stub, address _factory) public initializer {
        _grantRole(COMPLIANCE_REGISTRY_STUB_ROLE, _stub);

        blacklist = RegistrySlot({stepCumulative: 1000, cumulative: 0});
        whitelist = RegistrySlot({stepCumulative: 1000, cumulative: 0});
        factory = RegistryFactory(_factory);
    }

    function store(
        address account,
        bool useWhitelist
    ) external onlyRole(COMPLIANCE_REGISTRY_STUB_ROLE) {
        uint256 pivot = blacklist.cumulative / blacklist.stepCumulative;
        if (useWhitelist) {
            pivot = whitelist.cumulative / whitelist.stepCumulative;
            whitelist.cumulative++;
        } else {
            blacklist.cumulative++;
        }
        address registry = factory.deploy(pivot, address(this), useWhitelist);
        ComplianceRegistry(registry).store(account);
    }

    function get(
        address account,
        bool useWhitelist
    ) external view returns (bool) {
        uint256 cumulative = blacklist.cumulative;
        uint256 stepCumulative = blacklist.stepCumulative;
        if (useWhitelist) {
            cumulative = whitelist.cumulative;
            stepCumulative = whitelist.stepCumulative;
        }
        for (uint256 idx = 0; idx < cumulative / stepCumulative; idx++) {
            (address registry, bool isZero) = factory.get(idx, useWhitelist);
            if (!isZero) continue;
            if (ComplianceRegistry(registry).check(account)) {
                return true;
            }
        }
        return false;
    }
}
