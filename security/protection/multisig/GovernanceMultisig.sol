// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGovernanceMultisig {
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, bytes32 indexed calldataHash);
    event ProposalExecuted(uint256 indexed proposalId);
    event Voted(uint256 indexed proposalId, address indexed voter, bool support);

    error UnauthorizedAccess(address caller);
    error InvalidProposalState(uint256 proposalId);
    error AlreadyVoted(uint256 proposalId, address voter);
    error QuorumNotReached(uint256 proposalId);

    function createProposal(address _target, uint256 _value, bytes calldata _calldata, string memory _description) external returns (uint256);
    function vote(uint256 _proposalId, bool _support) external;
    function executeProposal(uint256 _proposalId) external;
    function getProposalState(uint256 _proposalId) external view returns (uint8);
    function getVotes(uint256 _proposalId) external view returns (uint256 yesVotes, uint256 noVotes);
}