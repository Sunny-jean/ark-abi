// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPeriodicUpdateNotifier {
    event PeriodicUpdateSent(uint256 indexed updateId, uint256 timestamp);

    function sendUpdate() external;
    function getUpdateInterval() external view returns (uint256);
    function setUpdateInterval(uint256 _newInterval) external;
}