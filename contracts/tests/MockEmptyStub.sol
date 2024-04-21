// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MockEmptyStub {
    function isBlacklist(address) external view returns (bool) {
        return false;
    }

    function isWhitelist(address) external view returns (bool) {
        return true;
    }
}
