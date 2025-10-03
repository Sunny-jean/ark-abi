// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFinancialMathLibrary {
    function calculateNPV(int256[] memory cashFlows, uint256 discountRate) external pure returns (int256);
    function calculateIRR(int256[] memory cashFlows) external pure returns (int256);
    function calculateDiscountFactor(uint256 rate, uint256 periods) external pure returns (uint256);
}