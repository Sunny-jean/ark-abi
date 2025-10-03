// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILendingHealthChecker {
    // 每筆倉位健康度追蹤
    function getPositionHealth(address _user) external view returns (uint256);
    function checkPositionHealth(address _user) external view returns (bool);
    function setHealthFactorThreshold(uint256 _threshold) external;

    event HealthFactorThresholdSet(uint256 threshold);

    error UnhealthyPosition();
}