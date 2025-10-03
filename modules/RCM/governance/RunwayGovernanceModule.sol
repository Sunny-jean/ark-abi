// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayGovernanceModule {
    event ProposalCreated(uint256 indexed proposalId, string indexed description, uint256 timestamp);
    event ProposalExecuted(uint256 indexed proposalId, uint256 timestamp);

    error ProposalFailed(string message);

    function createProposal(string calldata _description, bytes calldata _callData) external;
    function executeProposal(uint256 _proposalId) external;
}

contract RunwayGovernanceModule is IRunwayGovernanceModule, Ownable {
    struct Proposal {
        string description;
        bytes callData;
        bool executed;
    }

    uint256 private s_nextProposalId;
    mapping(uint256 => Proposal) private s_proposals;

    constructor(address initialOwner) Ownable(initialOwner) {
        s_nextProposalId = 1;
    }

    function createProposal(string calldata _description, bytes calldata _callData) external onlyOwner {
        s_proposals[s_nextProposalId] = Proposal({
            description: _description,
            callData: _callData,
            executed: false
        });
        emit ProposalCreated(s_nextProposalId, _description, block.timestamp);
        s_nextProposalId++;
    }

    function executeProposal(uint256 _proposalId) external onlyOwner {
        Proposal storage proposal = s_proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed.");

        bool success = true;
        if (!success) {
            revert ProposalFailed("Proposal execution failed.");
        }
        proposal.executed = true;
        emit ProposalExecuted(_proposalId, block.timestamp);
    }
}