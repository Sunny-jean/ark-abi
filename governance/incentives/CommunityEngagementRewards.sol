// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICommunityEngagementRewards {
    function distributeEngagementRewards(address _user, uint256 _amount) external;
    function setEngagementRewardRate(uint256 _rate) external;
    function getEngagementRewardRate() external view returns (uint256);

    event EngagementRewardsDistributed(address indexed user, uint256 amount);
    event EngagementRewardRateSet(uint256 rate);

    error InsufficientBalance();
}