// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILiquidationExecutor {
    function executeLiquidation(address _user, address _collateralAsset, uint256 _debtAssetAmount) external;
    function setExecutor(address _executor, bool _canExecute) external;
    function canExecute(address _executor) external view returns (bool);

    event LiquidationExecuted(address indexed executor, address indexed user, uint256 debtAssetAmount);
    event ExecutorSet(address indexed executor, bool canExecute);

    error UnauthorizedExecutor();
}