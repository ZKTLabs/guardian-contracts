// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {ComplianceRegistryIndex} from "./ComplianceRegistryIndex.sol";

contract RegistryIndexFactory is AccessControl {
    bytes32 public constant ADMIN_ROLE =
        keccak256("registry-index-factory.admin.role");

    struct Slot {
        address admin;
        address registryFactory;
        uint256 base;
    }

    Slot private slot;

    constructor(uint256 base, address admin, address registryFactory) {
        _grantRole(ADMIN_ROLE, admin);

        slot = Slot({
            registryFactory: registryFactory,
            admin: admin,
            base: base
        });
        require(hasRole(ADMIN_ROLE, admin));
    }

    function getByteCode() internal pure returns (bytes memory) {
        return abi.encodePacked(type(ComplianceRegistryIndex).creationCode);
    }

    function getByteCodeHash() internal pure returns (bytes32) {
        return keccak256(getByteCode());
    }

    function getSalt(uint256 pivot) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    bytes32(pivot),
                    slot.admin,
                    slot.registryFactory,
                    bytes32(slot.base)
                )
            );
    }

    function deploy(
        uint256 pivot,
        address stub
    ) external onlyRole(ADMIN_ROLE) returns (address) {
        bytes32 salt = getSalt(pivot);
        bytes memory bytecode = getByteCode();
        address registryIndex = Create2.computeAddress(
            salt,
            keccak256(bytecode)
        );
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(registryIndex)
        }
        if (codeSize == 0) {
            Create2.deploy(0, salt, bytecode);
            ComplianceRegistryIndex(registryIndex).initialize(
                pivot,
                stub,
                slot.registryFactory
            );
            return registryIndex;
        }
        return registryIndex;
    }

    function get(uint256 pivot) external view returns (address, bool) {
        bytes32 salt = getSalt(pivot);
        bytes32 bytecodeHash = getByteCodeHash();
        address registryIndex = Create2.computeAddress(salt, bytecodeHash);
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(registryIndex)
        }
        return (registryIndex, codeSize == 0);
    }
}
