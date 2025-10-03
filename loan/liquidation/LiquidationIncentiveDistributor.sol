// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILiquidationIncentiveDistributor {
    // 清算獎勵分配器
    function distributeIncentive(address _liquidator, address _asset, uint256 _amount) external;
    function setIncentiveRate(uint256 _rate) external;
    function getIncentiveRate() external view returns (uint256);

    event IncentiveDistributed(address indexed liquidator, address indexed asset, uint256 amount);
    event IncentiveRateSet(uint256 rate);

    error DistributionFailed();
}