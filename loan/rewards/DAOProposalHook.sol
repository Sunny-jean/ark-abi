// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDAOProposalHook {
    function proposeParameterChange(uint256 _paramId, uint256 _newValue) external;
    function executeParameterChange(uint256 _paramId) external;
    function getProposedParameter(uint256 _paramId) external view returns (uint256);

    event ParameterChangeProposed(uint256 indexed paramId, uint256 newValue);
    event ParameterChangeExecuted(uint256 indexed paramId, uint256 newValue);

    error ProposalNotFound();
}