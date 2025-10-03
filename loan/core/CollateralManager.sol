// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICollateralManager {
    // 抵押品存入與管理
    function deposit(address _collateralAsset, uint256 _amount) external;
    function withdraw(address _collateralAsset, uint256 _amount) external;
    function getCollateralValue(address _user, address _collateralAsset) external view returns (uint256);

    event CollateralDeposited(address indexed user, address indexed collateralAsset, uint256 amount);
    event CollateralWithdrawn(address indexed user, address indexed collateralAsset, uint256 amount);

    error DepositFailed();
    error WithdrawFailed();
}