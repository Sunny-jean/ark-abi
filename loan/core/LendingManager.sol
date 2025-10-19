// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILendingManager {
    function borrow(address _asset, uint256 _amount) external;
    function repay(address _asset, uint256 _amount) external;
    function depositCollateral(address _collateralAsset, uint256 _amount) external;
    function withdrawCollateral(address _collateralAsset, uint256 _amount) external;

    event Borrowed(address indexed borrower, address indexed asset, uint256 amount);
    event Repaid(address indexed borrower, address indexed asset, uint256 amount);
    event CollateralDeposited(address indexed depositor, address indexed collateralAsset, uint256 amount);
    event CollateralWithdrawn(address indexed withdrawer, address indexed collateralAsset, uint256 amount);

    error BorrowFailed();
    error RepayFailed();
    error DepositFailed();
    error WithdrawFailed();
}