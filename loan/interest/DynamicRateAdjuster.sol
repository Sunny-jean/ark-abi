// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDynamicRateAdjuster {
    // 動態利率調整器（市場主導）
    function adjustRates() external;
    function setAdjustmentFactor(uint256 _factor) external;
    function getAdjustmentFactor() external view returns (uint256);

    event RatesAdjusted(uint256 newFactor);

    error AdjustmentFailed();
}