// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IProbabilityMath {
    function calculateProbability(uint256 favorableOutcomes, uint256 totalOutcomes) external pure returns (uint256);
    function calculateExpectedValue(uint256[] memory values, uint256[] memory probabilities) external pure returns (uint256);
}