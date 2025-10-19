// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICollateralFactorManager {
    function setCollateralFactor(address _asset, uint256 _factor) external;
    function getCollateralFactor(address _asset) external view returns (uint256);
    function setLiquidationThreshold(address _asset, uint256 _threshold) external;
    function getLiquidationThreshold(address _asset) external view returns (uint256);

    event CollateralFactorSet(address indexed asset, uint256 factor);
    event LiquidationThresholdSet(address indexed asset, uint256 threshold);

    error InvalidFactor();
}