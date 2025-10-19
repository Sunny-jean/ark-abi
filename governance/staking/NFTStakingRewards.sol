// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTStakingRewards {
    function stake(uint256 _tokenId) external;
    function unstake(uint256 _tokenId) external;
    function claimRewards(uint256 _tokenId) external;
    function getPendingRewards(uint256 _tokenId) external view returns (uint256);

    event Staked(address indexed user, uint256 indexed tokenId);
    event Unstaked(address indexed user, uint256 indexed tokenId);
    event RewardsClaimed(address indexed user, uint256 indexed tokenId, uint256 amount);

    error AlreadyStaked();
    error NotStaked();
    error NoRewardsToClaim();
}