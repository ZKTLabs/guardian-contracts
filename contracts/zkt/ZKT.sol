// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./esZKT.sol";

contract ZKT is
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    AccessControlUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // TODO: Update the max supply
    uint256 public constant MAX_SUPPLY = 2500000000 * 10 ** 18; // Max supply of 2,500,000,000 tokens
    address public esZKTAddress;

    uint256[500] private __gap;

    event EsZKTAddressSet(address indexed newEsZKTAddress);
    event ConvertedToEsZKT(address indexed user, uint256 amount);

    function initialize() public initializer {
        __ERC20_init("ZKT", "ZKT");
        __ERC20Burnable_init();
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);
    }

    function setEsZKTAddress(
        address newEsZKTAddress
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        esZKTAddress = newEsZKTAddress;
        emit EsZKTAddressSet(newEsZKTAddress);
    }

    function mint(
        address to,
        uint256 amount
    ) public onlyRole(MINTER_ROLE) returns (bool) {
        require(
            totalSupply() + amount <= MAX_SUPPLY,
            "Cannot mint beyond max supply"
        ); // not needed for testnet
        _mint(to, amount);
        return true;
    }

    function convertToEsZKT(uint256 amount) public {
        require(esZKTAddress != address(0), "esZKT contract address not set");
        _burn(msg.sender, amount);
        esZKT(esZKTAddress).mint(msg.sender, amount);
        emit ConvertedToEsZKT(msg.sender, amount);
    }
}
