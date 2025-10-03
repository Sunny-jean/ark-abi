// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITreasuryManagementStrategy {
    event TreasuryAction(string indexed actionType, uint256 indexed amount, uint256 timestamp);

    error ActionFailed(string message);

    function executeTreasuryAction(string calldata _actionType, uint256 _amount) external;
    function setTreasuryAddress(address _treasuryAddress) external;
}