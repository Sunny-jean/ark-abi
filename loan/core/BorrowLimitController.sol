// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBorrowLimitController {
    function checkBorrowLimit(address _user, address _asset, uint256 _amount) external view returns (bool);
    function setBorrowLimit(address _asset, uint256 _limit) external;
    function getBorrowLimit(address _asset) external view returns (uint256);

    event BorrowLimitChecked(address indexed user, address indexed asset, uint256 amount, bool allowed);
    event BorrowLimitSet(address indexed asset, uint256 limit);

    error LimitExceeded();
}