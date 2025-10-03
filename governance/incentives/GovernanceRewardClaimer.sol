// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGovernanceRewardClaimer {
    // 獎勵領取器
    function claimGovernanceRewards() external;
    function getClaimableRewards(address _user) external view returns (uint256);

    event GovernanceRewardsClaimed(address indexed user, uint256 amount);

    error NoClaimableRewards();
}