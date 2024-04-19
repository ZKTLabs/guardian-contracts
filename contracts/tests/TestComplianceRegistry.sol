// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IComplianceRegistry} from "../interfaces/IComplianceRegistry.sol";
import {INetworkSupportedRegistry} from "../interfaces/INetworkSupportedRegistry.sol";
import {ProposalLabel} from "../libraries/ProposalLabel.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";
import "hardhat/console.sol";

abstract contract TestComplianceRegistry is
    IComplianceRegistry,
    AccessControl,
    Initializable
{
    bytes32 public constant ADMIN_ROLE =
        keccak256("compliance-registry.admin.role");
    bytes32 public constant COMPLIANCE_REGISTRY_STUB_ROLE =
        keccak256("compliance-registry.stub.role");

    struct Slot {
        uint256 maxComplianceCount;
        uint256 complianceCount;
    }
    Slot public slot;
    mapping(bytes32 => bool) public compliance;

    function initialize(address _admin, address _stub) public initializer {
        _grantRole(ADMIN_ROLE, _admin);
        _grantRole(COMPLIANCE_REGISTRY_STUB_ROLE, _stub);
        _setRoleAdmin(COMPLIANCE_REGISTRY_STUB_ROLE, ADMIN_ROLE);

        slot = Slot({maxComplianceCount: 100, complianceCount: 0});
    }

    function addProposalToList(
        ProposalCommon.Proposal memory proposal
    ) external override onlyRole(COMPLIANCE_REGISTRY_STUB_ROLE) {
        for (uint256 idx = 0; idx < proposal.targets.length; idx++) {
            bytes memory data = proposal.targets[idx];
            address target = decodeBytes(data);
            bytes32 addressKey = getAddressKey(target);
            if (target == address(0) || compliance[addressKey]) {
                continue;
            }
            compliance[addressKey] = true;
            slot.complianceCount++;
        }
    }

    function getAddressKey(address account) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, "ZKT"));
    }

    function isExceed() external view override returns (bool) {
        return slot.complianceCount >= slot.maxComplianceCount;
    }

    function checkCompliance(
        address account
    ) external view override returns (bool) {
        return compliance[getAddressKey(account)];
    }

    function decodeBytes(
        bytes memory data
    ) public view override returns (address) {
        (bytes memory addressBytes) = abi.decode(
            data,
            (bytes)
        );
        return abi.decode(addressBytes, (address));
    }
}
