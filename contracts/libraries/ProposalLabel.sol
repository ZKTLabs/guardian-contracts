// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library ProposalLabel {
    function pack(string[] memory input) public pure returns (bytes memory) {
        uint256 offset = 0x20;
        bytes memory packedData = new bytes(0);
        for (uint256 idx = 0; idx < input.length; ) {
            bytes memory strBytes = bytes(input[idx]);
            uint256 strLength = strBytes.length;
            require(
                strLength <= 0xFF,
                "ProposalLabel: Each string length cannot exceed 255 bytes"
            );
            packedData = expandTo(packedData, offset + strLength + 1); // +1 for prefix length
            assembly {
                mstore8(add(packedData, offset), strLength) // store string length first.
                let strOffset := add(strBytes, 0x20) // first byte location of strBytes
                let packedOffset := add(add(packedData, offset), 1)
                for {
                    let i := 0
                } lt(i, strLength) {
                    i := add(i, 1)
                } {
                    mstore8(add(packedOffset, i), mload(add(strOffset, i)))
                }
            }
            unchecked {
                offset += strLength + 1;
                idx++;
            }
        }
        return packedData;
    }

    function unpack(
        bytes memory packedData
    ) public pure returns (string[] memory) {
        uint256 offset = 0x20;
        uint256 strCount = count(packedData);

        string[] memory results = new string[](strCount);
        for (uint256 idx = 0; idx < strCount; ) {
            uint256 strLength;
            assembly {
                strLength := mload(add(packedData, offset))
            }
            results[idx] = new string(strLength);
            bytes memory strBytes = bytes(results[idx]);
            assembly {
                let strOffset := add(strBytes, 0x20)
                let packedOffset := add(add(packedData, offset), 1)
                for {
                    let i := 0
                } lt(i, strLength) {
                    i := add(i, 1)
                } {
                    mstore8(add(strOffset, i), mload(add(packedOffset, i)))
                }
            }
            unchecked {
                offset += strLength + 1;
                idx++;
            }
        }
        return results;
    }

    function expandTo(
        bytes memory data,
        uint256 length
    ) private pure returns (bytes memory expandedData) {
        uint256 dataLength = data.length;
        if (length <= dataLength) return data;

        expandedData = new bytes(length);
        assembly {
            let dataOffset := add(data, 0x20)
            let expandedOffset := add(expandedData, 0x20)

            for {
                let i := 0
            } lt(i, dataLength) {
                i := add(i, 0x20)
            } {
                mstore(add(expandedOffset, i), mload(add(dataOffset, i)))
            }
        }
    }

    function count(bytes memory packedData) public pure returns (uint256) {
        uint256 length = packedData.length;
        uint256 offset = 0x20;
        uint256 _count = 0;
        while (offset - 0x20 < length) {
            uint256 strLength;
            assembly {
                strLength := mload(add(packedData, offset))
            }
            offset += strLength + 1;
            _count++;
        }
        return _count;
    }
}
