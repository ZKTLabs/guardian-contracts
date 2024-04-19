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
    bytes32 public constant COMPLIANCE_REGISTRY_STUB_ROLE =
        keccak256("registry-factory.stub.role");

    struct Slot {
        address admin;
        uint256 base;
    }

    Slot slot;

    constructor(address admin, uint256 base) {
        _grantRole(ADMIN_ROLE, admin);

        _setRoleAdmin(COMPLIANCE_REGISTRY_STUB_ROLE, ADMIN_ROLE);
        slot = Slot({admin: admin, base: base});
        require(hasRole(ADMIN_ROLE, admin));
    }

    function getByteCode(
        bool _isWhitelist
    ) internal pure returns (bytes memory) {
        return
            _isWhitelist
                ? abi.encodePacked(
                    type(WhitelistComplianceRegistry).creationCode
                )
                : abi.encodePacked(
                    type(BlacklistComplianceRegistry).creationCode
                );
    }

    function getByteCodeHash(
        bool _isWhitelist
    ) internal pure returns (bytes32) {
        return keccak256(getByteCode(_isWhitelist));
    }

    function deploy(
        uint256 index,
        address _stub,
        bool _isWhitelist
    ) external onlyRole(COMPLIANCE_REGISTRY_STUB_ROLE) returns (address, bool) {
        bytes32 salt = bytes32(index + slot.base);
        bytes memory bytecode = getByteCode(_isWhitelist);
        address registry = Create2.computeAddress(salt, keccak256(bytecode));
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(registry)
        }
        if (codeSize == 0) {
            Create2.deploy(0, salt, bytecode);
            ComplianceRegistry(registry).initialize(slot.admin, _stub);
            return (registry, true);
        }
        return (registry, false);
    }

    function get(
        uint256 index,
        bool _isWhitelist
    ) public view returns (address, bool) {
        bytes32 salt = bytes32(index + slot.base);
        bytes32 bytecodeHash = getByteCodeHash(_isWhitelist);
        address registry = Create2.computeAddress(salt, bytecodeHash);
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(registry)
        }
        return (registry, codeSize == 0);
    }
}
