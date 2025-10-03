// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILendingRewardController {
    // 借貸雙邊激勵（借出/借入）
    function distributeBorrowRewards(address _user, uint256 _amount) external;
    function distributeSupplyRewards(address _user, uint256 _amount) external;
    function setBorrowRewardRate(uint256 _rate) external;
    function setSupplyRewardRate(uint256 _rate) external;

    event BorrowRewardsDistributed(address indexed user, uint256 amount);
    event SupplyRewardsDistributed(address indexed user, uint256 amount);
    event BorrowRewardRateSet(uint256 rate);
    event SupplyRewardRateSet(uint256 rate);

    error RewardDistributionFailed();
}