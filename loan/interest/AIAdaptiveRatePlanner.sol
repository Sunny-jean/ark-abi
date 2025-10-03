// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAIAdaptiveRatePlanner {
    // AI 驅動利率預測與設置
    function predictAndSetRates() external;
    function getPredictedBorrowRate(address _asset) external view returns (uint256);
    function getPredictedSupplyRate(address _asset) external view returns (uint256);

    event RatesPredictedAndSet(address indexed asset, uint256 borrowRate, uint256 supplyRate);

    error PredictionFailed();
}