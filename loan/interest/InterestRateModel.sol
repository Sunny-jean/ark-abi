// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IInterestRateModel {
    function getBorrowRate(address _asset, uint256 _utilization) external view returns (uint256);
    function getSupplyRate(address _asset, uint256 _utilization) external view returns (uint256);
    function setBaseRate(address _asset, uint256 _rate) external;

    event BaseRateSet(address indexed asset, uint256 rate);

    error InvalidUtilization();
}