// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUpgradeProposalManager {
    function submitUpgradeProposal(address _newImplementation, string calldata _description) external returns (uint256);
    function approveUpgrade(uint256 _proposalId) external;
    function executeUpgrade(uint256 _proposalId) external;

    event UpgradeProposalSubmitted(uint256 indexed proposalId, address indexed newImplementation, string description);
    event UpgradeApproved(uint256 indexed proposalId);
    event UpgradeExecuted(uint256 indexed proposalId);

    error ProposalNotFound();
    error AlreadyApproved();
    error NotApproved();
}
