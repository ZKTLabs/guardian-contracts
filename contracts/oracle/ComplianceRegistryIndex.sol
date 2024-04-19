// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {RegistryFactory} from "./RegistryFactory.sol";

abstract contract ComplianceRegistryIndex is AccessControl, Initializable {
    bytes32 public constant ADMIN_ROLE =
    keccak256("compliance-registry-index.admin.role");
    bytes32 public constant COMPLIANCE_REGISTRY_STUB_ROLE =
    keccak256("compliance-registry-index.stub.role");

    struct RegistrySlot {
        uint256 maxCumulative;
        uint256 cumulative;
    }

    RegistrySlot public blacklist;
    RegistrySlot public whitelist;
    RegistryFactory public factory;

    function initialize(
        address _admin,
        address _stub,
        address _factory
    ) public initializer {
        _grantRole(ADMIN_ROLE, _admin);
        _grantRole(COMPLIANCE_REGISTRY_STUB_ROLE, _stub);

        _setRoleAdmin(COMPLIANCE_REGISTRY_STUB_ROLE, ADMIN_ROLE);
        slot = RegistrySlot({maxCumulative: 2000, cumulative: 0});
        factory = RegistryFactory(_factory);
    }

    function store(
        address account,
        bool isWhitelist
    ) external onlyRole(COMPLIANCE_REGISTRY_STUB_ROLE) {
        if (isWhitelist) {
            uint256 pivot = whitelist.cumulative / whitelist.maxProposals;
            (address registry, ) = factory.deploy(
                pivot,
                address(this),
                isWhitelist
            );
            IComplianceRegistry(registry).store(account);
        }
    }
}
