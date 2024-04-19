// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";
import {RegistryIndexFactory} from "./RegistryIndexFactory.sol";
import {ComplianceRegistryIndex} from "./ComplianceRegistryIndex.sol";

error ComplianceRegistryStub_L1__InvalidConfirmProposalStatus();

contract ComplianceRegistryStub_L1 is AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE =
        keccak256("compliance-registry-stub-l1.admin.role");
    bytes32 public constant MANAGER_ROLE =
        keccak256("compliance-registry-stub-1.manager.role");
    bytes32 public constant GUARDIAN_NODE =
        keccak256("compliance-registry-stub-l1.guardian.role");
    uint256 public constant BASE_MODE = 1000;

    RegistryIndexFactory public factory;

    function initialize(address _admin, address _factory) public initializer {
        _grantRole(ADMIN_ROLE, _admin);
        _grantRole(GUARDIAN_NODE, _admin);
        _setRoleAdmin(MANAGER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(GUARDIAN_NODE, ADMIN_ROLE);

        factory = RegistryIndexFactory(_factory);
        require(hasRole(ADMIN_ROLE, _admin));
    }

    function decodeAddressBytes(
        bytes memory data
    ) public pure returns (address) {
        bytes memory addressBytes = abi.decode(data, (bytes));
        return abi.decode(addressBytes, (address));
    }

    function confirmProposal(
        ProposalCommon.Proposal memory proposal
    ) external onlyRole(GUARDIAN_NODE) {
        if (proposal.status != ProposalCommon.ProposalStatus.Approved)
            revert ComplianceRegistryStub_L1__InvalidConfirmProposalStatus();
        for (uint256 idx = 0; idx < proposal.targets.length; idx++) {
            address target = decodeAddressBytes(proposal.targets[idx]);
            uint256 pivot = uint160(target) % BASE_MODE;
            address registryIndex = factory.deploy(pivot, address(this));
            ComplianceRegistryIndex(registryIndex).store(
                target,
                proposal.isWhitelist
            );
        }
    }

    function isWhitelist(address account) external view returns (bool) {
        uint256 pivot = uint160(account) % BASE_MODE;
        (address registryIndex, bool notCreated) = factory.get(pivot);
        if (!notCreated) {
            return ComplianceRegistryIndex(registryIndex).get(account, true);
        } else {
            return false;
        }
    }

    function isBlacklist(address account) external view returns (bool) {
        uint256 pivot = uint160(account) % BASE_MODE;
        (address registryIndex, bool notCreated) = factory.get(pivot);
        if (!notCreated) {
            return ComplianceRegistryIndex(registryIndex).get(account, false);
        } else {
            return false;
        }
    }
}
