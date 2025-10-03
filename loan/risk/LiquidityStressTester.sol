// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILiquidityStressTester {
    // 資金流動性壓力測試模組
    function runStressTest() external;
    function getStressTestResult() external view returns (bool);
    function setLiquidityThreshold(uint256 _threshold) external;

    event StressTestCompleted(bool result);
    event LiquidityThresholdSet(uint256 threshold);

    error StressTestFailed();
}