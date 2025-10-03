// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILendingPositionTracker {
    // 借貸倉位記錄與使用者狀態
    function getUserBorrowBalance(address _user, address _asset) external view returns (uint256);
    function getUserCollateralBalance(address _user, address _collateralAsset) external view returns (uint256);
    function updateBorrowBalance(address _user, address _asset, uint256 _newBalance) external;
    function updateCollateralBalance(address _user, address _collateralAsset, uint256 _newBalance) external;

    event BorrowBalanceUpdated(address indexed user, address indexed asset, uint256 newBalance);
    event CollateralBalanceUpdated(address indexed user, address indexed collateralAsset, uint256 newBalance);

    error PositionNotFound();
}