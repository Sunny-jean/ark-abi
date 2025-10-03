// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IThresholdNotifier {
    event ThresholdCrossed(string indexed metric, uint256 indexed value, uint256 indexed threshold, uint256 timestamp);

    error NotificationFailed(string message);

    function checkAndNotify(string calldata _metric, uint256 _value, uint256 _threshold) external;
    function getThreshold(string calldata _metric) external view returns (uint256);
}