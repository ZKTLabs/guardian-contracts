// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "./ZKT.sol";

contract esZKT is ERC20Upgradeable, ERC20BurnableUpgradeable, AccessControlUpgradeable {

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    EnumerableSetUpgradeable.AddressSet private _whitelist;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address public zkt;
    bool private _redemptionActive;
    mapping(address => RedemptionRequest[]) private _redemptionRequests;

    uint256[500] private __gap;


    struct RedemptionRequest {
        uint256 amount;
        uint256 startTime;
        uint256 duration;
        bool completed;
    }

    event WhitelistUpdated(address account, bool isAdded);
    event RedemptionStarted(address indexed user, uint256 indexed index);
    event RedemptionCancelled(address indexed user, uint256 indexed index);
    event RedemptionCompleted(address indexed user, uint256 indexed index);
    event RedemptionStatusChanged(bool isActive);
    event ZKTAddressChanged(address indexed newZKTAddress);

    function initialize (address _zkt) public initializer {
        __ERC20_init("esZKT", "esZKT");
        __ERC20Burnable_init();
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);
        zkt = _zkt;
        _redemptionActive = false;
    }

    function changeRedemptionStatus(bool isActive) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _redemptionActive = isActive;
        emit RedemptionStatusChanged(isActive);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function changeZKTAddress(address _newZKT) public onlyRole(DEFAULT_ADMIN_ROLE) {
        zkt = _newZKT;
        emit ZKTAddressChanged(_newZKT);
    }

    function addToWhitelist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _whitelist.add(account);
        emit WhitelistUpdated(account, true);
    }

    function removeFromWhitelist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _whitelist.remove(account);
        emit WhitelistUpdated(account, false);
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelist.contains(account);
    }

    function getWhitelistedAddressAtIndex(uint256 index) public view returns (address) {
        require(index < getWhitelistCount(), "Index out of bounds");
        return _whitelist.at(index);
    }

    function getWhitelistCount() public view returns (uint256) {
        return _whitelist.length();
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(_whitelist.contains(msg.sender) || _whitelist.contains(to), "Transfer not allowed: address not in whitelist");
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(_whitelist.contains(from) || _whitelist.contains(to), "Transfer not allowed: address not in whitelist");
        return super.transferFrom(from, to, amount);
    }

    function startRedemption(uint256 amount, uint256 duration) public {
        require(_redemptionActive, "Redemption is currently inactive");
        require(balanceOf(msg.sender) >= amount, "Insufficient esZKT balance");
        require(duration == 15 days || duration == 90 days || duration == 180 days, "Invalid duration");

        _transfer(msg.sender, address(this), amount);

        _redemptionRequests[msg.sender].push(RedemptionRequest(amount, block.timestamp, duration, false));
        emit RedemptionStarted(msg.sender, _redemptionRequests[msg.sender].length - 1);
    }

    function cancelRedemption(uint256 index) public {
        require(_redemptionActive, "Redemption is currently inactive");
        RedemptionRequest storage request = _redemptionRequests[msg.sender][index];
        require(!request.completed, "Redemption already completed");

        _transfer(address(this), msg.sender, request.amount);

        // Mark the redemption request as completed
        request.completed = true;
        emit RedemptionCancelled(msg.sender, index);
    }

    /**
     * @dev Function to complete the redemption process
     * @param index The index of the redemption request to complete.
     */
    function completeRedemption(uint256 index) public {
        require(_redemptionActive, "Redemption is currently inactive");
        RedemptionRequest storage request = _redemptionRequests[msg.sender][index];
        require(!request.completed, "Redemption already completed");
        require(block.timestamp >= request.startTime + request.duration, "Redemption period not yet over");

        // Calculate the conversion ratio based on the duration
        uint256 ratio;
        if (request.duration == 15 days) {
            ratio = 250;
        } else if (request.duration == 90 days) {
            ratio = 625;
        } else {
            ratio = 1000;
        }

        uint256 zktAmount = request.amount * ratio / 1000;

        _burn(address(this), request.amount);

        ZKT(zkt).mint(msg.sender, zktAmount);

        // Mark the redemption request as completed
        request.completed = true;
        emit RedemptionCompleted(msg.sender, index);
    }

    /**
     * @dev Function to get the redemption request at a given index.
     * @param account The address to query.
     * @param index The index of the redemption request.
     * @return The redemption request.
     */
    function getRedemptionRequest(address account, uint256 index) public view returns (RedemptionRequest memory) {
        return _redemptionRequests[account][index];
    }

    /**
     * @dev Function to get the count of redemption requests for a given address.
     * @param account The address to query.
     * @return The count of redemption requests.
     */
    function getRedemptionRequestCount(address account) public view returns (uint256) {
        return _redemptionRequests[account].length;
    }
}