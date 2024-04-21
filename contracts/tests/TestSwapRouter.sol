// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IComplianceStub {
    function isWhitelist(address account) external view returns (bool);

    function isBlacklist(address account) external view returns (bool);
}

contract TestSwapRouter {
    IComplianceStub stub;

    uint256 random =
        uint256(
            keccak256(
                abi.encodePacked(keccak256("hello, test"), block.timestamp)
            )
        );

    constructor(address _stub) {
        stub = IComplianceStub(_stub);
    }

    function swap() external {
        bool sign = stub.isBlacklist(msg.sender);
        for (uint256 idx = 0; idx < 200; idx++) {
            uint256 mode = random % block.timestamp;
            if (mode % 2 == 1) {
                if (sign) {
                    random -= 11;
                } else {
                    random += 13;
                }
            } else {
                if (sign) {
                    random -= 13;
                } else {
                    random += 11;
                }
            }
        }
    }
}
