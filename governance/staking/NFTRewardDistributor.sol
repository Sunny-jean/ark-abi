// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTRewardDistributor {
    function distributeRewards(address _to, uint256 _amount) external;
    function setRewardToken(address _token) external;
    function getRewardToken() external view returns (address);

    event RewardsDistributed(address indexed to, uint256 amount);
    event RewardTokenSet(address indexed token);

    error DistributionFailed();
}