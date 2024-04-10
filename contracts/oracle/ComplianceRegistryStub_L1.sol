// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IComplianceRegistryStub} from "../interfaces/IComplianceRegistryStub.sol";
import {IComplianceRegistry} from "../interfaces/IComplianceRegistry.sol";
import {ProposalCommon} from "../libraries/ProposalCommon.sol";

error ComplianceRegistryStub_L1__InvalidConfirmProposalStatus();

contract ComplianceRegistryStub_L1 is IComplianceRegistryStub, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant GUARDIAN_NODE =
        keccak256("GUARDIAN_NODE");

    constructor(address _whitelistRegistry, address _blacklistRegistry) {
        _setupRole(ADMIN_ROLE, _msgSender());
        _setRoleAdmin(GUARDIAN_NODE, ADMIN_ROLE);

        whitelistRegistry = IComplianceRegistry(_whitelistRegistry);
        blacklistRegistry = IComplianceRegistry(_blacklistRegistry);
    }

    IComplianceRegistry public whitelistRegistry;
    IComplianceRegistry public blacklistRegistry;

    function confirmProposal(
        ProposalCommon.Proposal memory proposal
    ) external override onlyRole(GUARDIAN_NODE) {
        if (proposal.status != ProposalCommon.ProposalStatus.Approved)
            revert ComplianceRegistryStub_L1__InvalidConfirmProposalStatus();
        if (proposal.isWhitelist) {
            whitelistRegistry.addProposalToList(proposal);
            emit AddToWhitelist(proposal.id);

            _revokeCompliance(proposal, blacklistRegistry);
        } else {
            blacklistRegistry.addProposalToList(proposal);
            emit AddToBlacklist(proposal.id);

            _revokeCompliance(proposal, whitelistRegistry);
        }
    }

    function _revokeCompliance(
        ProposalCommon.Proposal memory proposal,
        IComplianceRegistry _registry
    ) internal {
        for (uint256 idx = 0; idx < proposal.targets.length; idx++) {
            bytes memory data = proposal.targets[idx];
            (address target, bytes32 networkHash) = _registry.decodeBytes(data);
            if (target == address(0)) continue;
            if (_registry.checkAddress(target)) {
                _registry.revokeCompliance(
                    target,
                    proposal.author,
                    proposal.id
                );
            }
        }
    }

    function isWhitelist(
        address account
    ) external view override returns (bool) {
        return
            whitelistRegistry.checkAddress(account) &&
            !blacklistRegistry.checkAddress(account);
    }

    function isBlacklist(
        address account
    ) external view override returns (bool) {
        return blacklistRegistry.checkAddress(account);
    }
}
