// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {TestComplianceRegistry} from "./TestComplianceRegistry.sol";
import {TestWhitelistRegistry} from "./TestWhitelistRegistry.sol";
import {TestBlacklistRegistry} from "./TestBlacklistRegistry.sol";
import "hardhat/console.sol";

contract TestFactory {
    address _admin;
    uint256 _base;

    constructor(address admin, uint256 base) {
        _admin = admin;
        _base = base;
    }

    function getByteCode(
        bool _isWhitelist
    ) internal pure returns (bytes memory) {
        return
            _isWhitelist
                ? abi.encodePacked(type(TestWhitelistRegistry).creationCode)
                : abi.encodePacked(type(TestBlacklistRegistry).creationCode);
    }

    function getByteCodeHash(
        bool _isWhitelist
    ) internal pure returns (bytes32) {
        return keccak256(getByteCode(_isWhitelist));
    }

    function upsert(
        uint256 index,
        address _stub,
        bool _isWhitelist
    ) external returns (address, bool) {
        bytes32 salt = bytes32(index + _base);
        bytes memory bytecode = getByteCode(_isWhitelist);
        address registry = Create2.computeAddress(salt, keccak256(bytecode));
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(registry)
        }
        if (codeSize == 0) {
            Create2.deploy(0, salt, bytecode);
            TestComplianceRegistry(registry).initialize(
                _admin,
                _stub
            );
            return (registry, true);
        }
        return (registry, false);
    }

    function get(
        uint256 index,
        bool _isWhitelist
    ) public view returns (address, bool) {
        bytes32 salt = bytes32(index + _base);
        bytes32 bytecodeHash = getByteCodeHash(_isWhitelist);
        address registry = Create2.computeAddress(salt, bytecodeHash);
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(registry)
        }
        return (registry, codeSize == 0);
    }
}
