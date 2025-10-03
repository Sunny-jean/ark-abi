// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStringSanitizer {
    event StringSanitized(string indexed originalString, string indexed sanitizedString);

    error InvalidCharacter(string character);
    error StringTooLong(uint256 maxLength);

    function sanitize(string memory _input) external pure returns (string memory);
    function validate(string memory _input) external pure returns (bool);
}