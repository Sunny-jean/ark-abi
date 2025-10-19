// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUtilizationBasedModel {
    function calculateBorrowRate(uint256 _utilization) external view returns (uint256);
    function calculateSupplyRate(uint256 _utilization) external view returns (uint256);
    function setKink(uint256 _kink) external;

    event KinkSet(uint256 kink);

    error InvalidKink();
}