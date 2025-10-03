// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAdvancedMathUtils {
    function matrixMultiply(uint256[2][] memory matrixA, uint256[2][] memory matrixB) external pure returns (uint256[2][] memory);
    function calculateDerivative(uint256[] memory coefficients, uint256 x) external pure returns (uint256);
}