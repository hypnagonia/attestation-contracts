// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library KeyValueParser {
    struct KeyValueMap {
        mapping(string => string) data;
    }

    error KeysAndValuesEqualLength();

    function parseKeyValue(
        KeyValueMap storage self,
        string[] memory keys,
        string[] memory values
    ) public {
        require(
            keys.length == values.length,
            "Keys and values must have equal length"
        );

        for (uint256 i = 0; i < keys.length; i++) {
            self.data[keys[i]] = values[i];
        }
    }

    function getValueByKey(
        KeyValueMap storage self,
        string memory key
    ) public view returns (string memory) {
        return self.data[key];
    }
}
