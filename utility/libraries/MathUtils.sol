// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMathUtils {
    function add(uint256 a, uint256 b) external pure returns (uint256);
    function sub(uint256 a, uint256 b) external pure returns (uint256);
    function mul(uint256 a, uint256 b) external pure returns (uint256);
    function div(uint256 a, uint256 b) external pure returns (uint256);
    function power(uint256 base, uint256 exp) external pure returns (uint256);
    function sqrt(uint256 a) external pure returns (uint256);
}