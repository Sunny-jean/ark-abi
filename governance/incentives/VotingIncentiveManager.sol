// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVotingIncentiveManager {
    function provideVotingIncentives(uint256 _proposalId, uint256 _amount) external;
    function setVotingIncentiveRate(uint256 _rate) external;
    function getVotingIncentiveRate() external view returns (uint256);

    event VotingIncentivesProvided(uint256 indexed proposalId, uint256 amount);
    event VotingIncentiveRateSet(uint256 rate);

    error InvalidProposalId();
}