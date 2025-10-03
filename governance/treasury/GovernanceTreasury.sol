// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGovernanceTreasury {
    // 治理金庫
    function deposit(address _token, uint256 _amount) external;
    function withdraw(address _token, uint256 _amount) external;
    function getBalance(address _token) external view returns (uint256);

    event Deposited(address indexed token, uint256 amount);
    event Withdrawn(address indexed token, uint256 amount);

    error InsufficientBalance();
}