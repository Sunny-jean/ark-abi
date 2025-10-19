// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILiquidationManager {
    function liquidatePosition(address _user, address _collateralAsset, uint256 _debtAssetAmount) external;
    function getLiquidatablePositions() external view returns (address[] memory);
    function setLiquidationThreshold(uint256 _threshold) external;

    event PositionLiquidated(address indexed user, address indexed collateralAsset, uint256 debtAssetAmount);
    event LiquidationThresholdSet(uint256 threshold);

    error NotLiquidatable();
}