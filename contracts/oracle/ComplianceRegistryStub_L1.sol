// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";

error ComplianceRegistryStub_L1__InvalidConfirmProposalStatus();
error ComplianceRegistryStub_L1__OnlyAllowScripting();

interface IComplianceRegistry {
    function store(address account) external;
}

interface IComplianceRegistryIndex {
    function store(address account, bool useWhitelist) external;

    function get(address account, bool useWhitelist) external view returns (bool);
}

interface IRegistryFactory {
    function deploy(uint256 pivot, address stub, bool useWhitelist) external returns (address);

    function get(uint256 pivot, bool useWhitelist) external view returns (address, bool);
}

interface IRegistryIndexFactory {
    function deploy(uint256 pivot, address stub) external returns (address);

    function get(uint256 pivot) external view returns (address, bool);
}

contract ComplianceRegistryStub_L1 is AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE =
        keccak256("compliance-registry-stub-l1.admin.role");
    bytes32 public constant MANAGER_ROLE =
        keccak256("compliance-registry-stub-1.manager.role");
    bytes32 public constant GUARDIAN_NODE =
        keccak256("compliance-registry-stub-l1.guardian.role");
    uint256 public constant BASE_MODE = 1000;

    IRegistryFactory public registryFactory;
    IRegistryIndexFactory public registryIndexFactory;
    address private scripting;

    function initialize(
        address _admin,
        address _registryIndexFactory,
        address _registryFactory
    ) public initializer {
        _grantRole(ADMIN_ROLE, _admin);
        _grantRole(GUARDIAN_NODE, _admin);
        _setRoleAdmin(GUARDIAN_NODE, ADMIN_ROLE);

        registryIndexFactory = IRegistryIndexFactory(_registryIndexFactory);
        registryFactory = IRegistryFactory(_registryFactory);
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
            address registryIndex = registryIndexFactory.deploy(
                pivot,
                address(this)
            );
            scripting = registryIndex;
            IComplianceRegistryIndex(registryIndex).store(
                target,
                proposal.isWhitelist
            );
        }
    }

    function callback(
        uint256 pivot,
        address index,
        bool useWhitelist,
        address account
    ) external {
        if (scripting != index)
            revert ComplianceRegistryStub_L1__OnlyAllowScripting();
        address registry = registryFactory.deploy(
            pivot,
            address(this),
            useWhitelist
        );
        IComplianceRegistry(registry).store(account);
    }

    function isWhitelist(address account) external view returns (bool) {
        uint256 pivot = uint160(account) % BASE_MODE;
        (address registryIndex, bool notCreated) = registryIndexFactory.get(pivot);
        if (!notCreated) {
            return IComplianceRegistryIndex(registryIndex).get(account, true);
        } else {
            return false;
        }
    }

    function isBlacklist(address account) external view returns (bool) {
        uint256 pivot = uint160(account) % BASE_MODE;
        (address registryIndex, bool notCreated) = registryIndexFactory.get(pivot);
        if (!notCreated) {
            return IComplianceRegistryIndex(registryIndex).get(account, false);
        } else {
            return false;
        }
    }
}
