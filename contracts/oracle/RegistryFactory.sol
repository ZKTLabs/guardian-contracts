// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {WhitelistComplianceRegistry} from "./WhitelistComplianceRegistry.sol";
import {BlacklistComplianceRegistry} from "./BlacklistComplianceRegistry.sol";
import {ComplianceRegistry} from "./ComplianceRegistry.sol";

contract RegistryFactory is AccessControl {
    bytes32 public constant ADMIN_ROLE =
        keccak256("registry-factory.admin.role");
    bytes32 public constant COMPLIANCE_REGISTRY_INDEX =
        keccak256("registry-factory.index.role");

    struct Slot {
        address admin;
        uint256 base;
    }

    Slot private slot;

    constructor(address admin, uint256 base) {
        _grantRole(ADMIN_ROLE, admin);

        _setRoleAdmin(COMPLIANCE_REGISTRY_INDEX, ADMIN_ROLE);
        slot = Slot({admin: admin, base: base});
        require(hasRole(ADMIN_ROLE, admin));
    }

    function getByteCode(
        bool useWhitelist
    ) internal pure returns (bytes memory) {
        return
            useWhitelist
                ? abi.encodePacked(
                    type(WhitelistComplianceRegistry).creationCode
                )
                : abi.encodePacked(
                    type(BlacklistComplianceRegistry).creationCode
                );
    }

    function getByteCodeHash(
        bool useWhitelist
    ) internal pure returns (bytes32) {
        return keccak256(getByteCode(useWhitelist));
    }

    function getSalt(
        uint256 pivot,
        bool useWhitelist
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    bytes32(pivot),
                    slot.admin,
                    useWhitelist,
                    bytes32(slot.base)
                )
            );
    }

    function deploy(
        uint256 pivot,
        address index,
        bool useWhitelist
    ) external onlyRole(COMPLIANCE_REGISTRY_INDEX) returns (address) {
        bytes32 salt = getSalt(pivot, useWhitelist);
        bytes memory bytecode = getByteCode(useWhitelist);
        address registry = Create2.computeAddress(salt, keccak256(bytecode));
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(registry)
        }
//        if (codeSize == 0) {
//            Create2.deploy(0, salt, bytecode);
//            ComplianceRegistry(registry).initialize(index);
//            return registry;
//        }
        return registry;
    }

    function get(
        uint256 pivot,
        bool useWhitelist
    ) public view returns (address, bool) {
        bytes32 salt = getSalt(pivot, useWhitelist);
        bytes32 bytecodeHash = getByteCodeHash(useWhitelist);
        address registry = Create2.computeAddress(salt, bytecodeHash);
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(registry)
        }
        return (registry, codeSize == 0);
    }
}
