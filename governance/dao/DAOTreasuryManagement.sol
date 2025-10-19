// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDAOTreasuryManagement {
    function depositToDAO(address _token, uint256 _amount) external;
    function withdrawFromDAO(address _token, uint256 _amount) external;
    function getDAOBalance(address _token) external view returns (uint256);

    event DepositedToDAO(address indexed token, uint256 amount);
    event WithdrawnFromDAO(address indexed token, uint256 amount);

    error InsufficientDAOBalance();
}