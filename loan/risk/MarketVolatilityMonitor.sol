// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMarketVolatilityMonitor {
    function getVolatility(address _asset) external view returns (uint256);
    function setVolatilityThreshold(uint256 _threshold) external;
    function isVolatile(address _asset) external view returns (bool);

    event VolatilityThresholdSet(uint256 threshold);

    error HighVolatility();
}