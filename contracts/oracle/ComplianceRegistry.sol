// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";

abstract contract ComplianceRegistry is AccessControl, Initializable {
    bytes32 public constant COMPLIANCE_REGISTRY_STUB_ROLE =
        keccak256("compliance-registry.index.role");
    bytes32 public constant ZKT_KEY = keccak256("ZKT");

    mapping(bytes32 => bool) public accounts;

    function initialize(address _index) public initializer {
        _grantRole(COMPLIANCE_REGISTRY_STUB_ROLE, _index);
    }

    function store(
        address account
    ) external onlyRole(COMPLIANCE_REGISTRY_STUB_ROLE) {
        accounts[key(account)] = true;
    }

    function key(address account) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, ZKT_KEY));
    }

    function check(address account) external view returns (bool) {
        return accounts[key(account)];
    }
}
