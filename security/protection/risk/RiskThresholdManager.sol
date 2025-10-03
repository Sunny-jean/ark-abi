// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRiskThresholdManager {
    event ThresholdSet(string indexed riskType, uint256 threshold);
    event ThresholdExceeded(string indexed riskType, uint256 currentValue, uint256 threshold);

    error UnauthorizedAccess(address caller);
    error InvalidThreshold(uint256 threshold);

    function setThreshold(string memory _riskType, uint256 _threshold) external;
    function getThreshold(string memory _riskType) external view returns (uint256);
    function checkThreshold(string memory _riskType, uint256 _currentValue) external view returns (bool);
}