// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStringMatcher {
    event MatchFound(string indexed pattern, string indexed text);

    function contains(string memory _text, string memory _pattern) external pure returns (bool);
    function startsWith(string memory _text, string memory _pattern) external pure returns (bool);
    function endsWith(string memory _text, string memory _pattern) external pure returns (bool);
    function indexOf(string memory _text, string memory _pattern) external pure returns (int256);
}