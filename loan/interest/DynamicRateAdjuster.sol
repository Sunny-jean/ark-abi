// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDynamicRateAdjuster {
    function adjustRates() external;
    function setAdjustmentFactor(uint256 _factor) external;
    function getAdjustmentFactor() external view returns (uint256);

    event RatesAdjusted(uint256 newFactor);

    error AdjustmentFailed();
}