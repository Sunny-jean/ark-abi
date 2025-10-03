// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRunwayGovernanceModule {
    event ProposalCreated(uint256 indexed proposalId, string indexed description, uint256 timestamp);
    event ProposalExecuted(uint256 indexed proposalId, uint256 timestamp);

    error ProposalFailed(string message);

    function createProposal(string calldata _description, bytes calldata _callData) external;
    function executeProposal(uint256 _proposalId) external;
}