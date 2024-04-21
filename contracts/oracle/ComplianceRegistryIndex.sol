// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "hardhat/console.sol";

interface ICallback {
    function callback(
        uint256 pivot,
        address index,
        bool useWhitelist,
        address account
    ) external;
}

interface IComplianceRegistry {
    function store(address account) external;

    function check(address account) external view returns (bool);

    function verify() external view returns (bool);
}

interface IRegistryFactory {
    function deploy(
        uint256 pivot,
        address index,
        address stub,
        bool useWhitelist
    ) external returns (address);

    function get(
        uint256 pivot,
        address index,
        bool useWhitelist
    ) external view returns (address, bool);
}

contract ComplianceRegistryIndex is AccessControl, Initializable {
    bytes32 public constant COMPLIANCE_REGISTRY_STUB_ROLE =
        keccak256("compliance-registry-index.stub.role");

    struct RegistrySlot {
        uint256 stepCumulative;
        uint256 cumulative;
    }

    uint256 public index;
    RegistrySlot public blacklist;
    RegistrySlot public whitelist;
    IRegistryFactory public registryFactory;

    function initialize(
        uint256 _index,
        address _stub,
        address _registryFactory
    ) public initializer {
        _grantRole(COMPLIANCE_REGISTRY_STUB_ROLE, _stub);

        index = _index;
        blacklist = RegistrySlot({stepCumulative: 1000, cumulative: 0});
        whitelist = RegistrySlot({stepCumulative: 1000, cumulative: 0});
        registryFactory = IRegistryFactory(_registryFactory);
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
        ICallback(_msgSender()).callback(
            pivot,
            address(this),
            useWhitelist,
            account
        );
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
            (address registry, bool isZero) = registryFactory.get(
                idx,
                address(this),
                useWhitelist
            );
            if (!isZero) continue;
            if (IComplianceRegistry(registry).check(account)) {
                return true;
            }
        }
        return false;
    }
}
