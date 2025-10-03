// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IParameterGovernance {
    // 參數治理
    function proposeParameterChange(string calldata _parameterName, bytes calldata _newValue) external returns (uint256);
    function approveParameterChange(uint256 _proposalId) external;
    function executeParameterChange(uint256 _proposalId) external;

    event ParameterChangeProposed(uint256 indexed proposalId, string parameterName, bytes newValue);
    event ParameterChangeApproved(uint256 indexed proposalId);
    event ParameterChangeExecuted(uint256 indexed proposalId);

    error ProposalNotFound();
    error AlreadyApproved();
    error NotApproved();
}