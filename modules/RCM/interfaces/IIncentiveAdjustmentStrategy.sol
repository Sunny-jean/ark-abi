// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIncentiveAdjustmentStrategy {
    event IncentiveAdjusted(string indexed incentiveType, uint256 indexed oldValue, uint256 indexed newValue, uint256 timestamp);

    error AdjustmentFailed(string message);

    function adjustIncentive(string calldata _incentiveType, uint256 _newValue) external;
    function getIncentiveValue(string calldata _incentiveType) external view returns (uint256);
}