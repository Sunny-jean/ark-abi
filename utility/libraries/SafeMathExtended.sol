// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISafeMathExtended {
    function add(uint256 a, uint256 b) external pure returns (uint256);
    function sub(uint256 a, uint256 b) external pure returns (uint256);
    function mul(uint256 a, uint256 b) external pure returns (uint256);
    function div(uint256 a, uint256 b) external pure returns (uint256);
    function mod(uint256 a, uint256 b) external pure returns (uint256);
}