// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICrossChainVoteAggregator {
    // 跨鏈投票聚合
    function aggregateVotes(uint256 _proposalId, uint256 _sourceChainId, uint256 _votesFor, uint256 _votesAgainst) external;
    function getAggregatedVotes(uint256 _proposalId) external view returns (uint256 totalVotesFor, uint256 totalVotesAgainst);

    event VotesAggregated(uint256 indexed proposalId, uint256 indexed sourceChainId, uint256 votesFor, uint256 votesAgainst);

    error AggregationFailed();
}