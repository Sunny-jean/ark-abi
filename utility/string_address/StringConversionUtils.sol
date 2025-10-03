// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStringConversionUtils {
    error InvalidInput(string message);

    function uintToString(uint256 _value) external pure returns (string memory);
    function stringToUint(string memory _value) external pure returns (uint256);
    function bytes32ToString(bytes32 _value) external pure returns (string memory);
    function stringToBytes32(string memory _value) external pure returns (bytes32);
}