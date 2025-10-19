// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDelegationIncentiveManager {
    function provideDelegationIncentives(address _delegator, address _delegatee, uint256 _amount) external;
    function setDelegationIncentiveRate(uint256 _rate) external;
    function getDelegationIncentiveRate() external view returns (uint256);

    event DelegationIncentivesProvided(address indexed delegator, address indexed delegatee, uint256 amount);
    event DelegationIncentiveRateSet(uint256 rate);

    error InvalidDelegation();
}