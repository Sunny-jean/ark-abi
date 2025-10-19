// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBudgetApprovalSystem {
    function submitBudgetProposal(uint256 _amount, string calldata _description) external returns (uint256);
    function approveBudget(uint256 _proposalId) external;
    function getBudgetStatus(uint256 _proposalId) external view returns (bool approved, uint256 amount, string memory description);

    event BudgetProposalSubmitted(uint256 indexed proposalId, uint256 amount, string description);
    event BudgetApproved(uint256 indexed proposalId);

    error ProposalNotFound();
    error AlreadyApproved();
}