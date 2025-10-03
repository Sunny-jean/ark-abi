// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVotingEscrowIntegration {
    event VoteCast(address indexed voter, uint256 indexed proposalId, uint256 indexed votes, bool support);

    error VotingFailed(string message);

    function castVote(uint256 _proposalId, uint256 _votes, bool _support) external;
    function getVotes(address _voter) external view returns (uint256);
}