// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGasOptimizationUtils {
    event GasSaved(uint256 amount);

    function optimizeStorage(uint256 _value) external pure returns (uint256);
    function optimizeLoops(uint256 _iterations) external pure returns (uint256);
}