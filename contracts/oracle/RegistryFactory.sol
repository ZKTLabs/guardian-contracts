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

    struct Slot {
        address admin;
        uint256 base;
    }

    Slot private slot;

    constructor(address admin, uint256 base) {
        _grantRole(ADMIN_ROLE, admin);

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
        uint256 index,
        bool useWhitelist
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    bytes32(pivot),
                    slot.admin,
                    index,
                    useWhitelist,
                    bytes32(slot.base)
                )
            );
    }

    function deploy(
        uint256 pivot,
        uint256 index,
        address stub,
        bool useWhitelist
    ) external onlyRole(ADMIN_ROLE) returns (address) {
        bytes32 salt = getSalt(pivot, index, useWhitelist);
        bytes memory bytecode = getByteCode(useWhitelist);
        address registry = Create2.computeAddress(salt, keccak256(bytecode));
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(registry)
        }
        if (codeSize == 0) {
            Create2.deploy(0, salt, bytecode);
            ComplianceRegistry(registry).initialize(stub);
            return registry;
        }
        return registry;
    }

    function get(
        uint256 pivot,
        uint256 index,
        bool useWhitelist
    ) public view returns (address, bool) {
        bytes32 salt = getSalt(pivot, index, useWhitelist);
        bytes32 bytecodeHash = getByteCodeHash(useWhitelist);
        address registry = Create2.computeAddress(salt, bytecodeHash);
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(registry)
        }
        return (registry, codeSize == 0);
    }
}
