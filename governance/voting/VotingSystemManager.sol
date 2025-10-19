// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVotingSystemManager {
    function createProposal(string calldata _description, bytes calldata _calldata) external returns (uint256);
    function vote(uint256 _proposalId, bool _support) external;
    function getProposal(uint256 _proposalId) external view returns (string memory description, uint256 votesFor, uint256 votesAgainst, bool executed);

    event ProposalCreated(uint256 indexed proposalId, string description, bytes data);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support);
    event ProposalExecuted(uint256 indexed proposalId);

    error ProposalNotFound();
    error AlreadyVoted();
    error VotingClosed();
}