// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IProposalSubmissionManager {
    function submitProposal(string calldata _description, bytes calldata _calldata) external returns (uint256);
    function setSubmissionThreshold(uint256 _threshold) external;
    function getSubmissionThreshold() external view returns (uint256);

    event ProposalSubmitted(uint256 indexed proposalId, string description);
    event SubmissionThresholdSet(uint256 threshold);

    error InsufficientFunds();
}
