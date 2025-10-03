// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFraudCaseManager {
    event CaseOpened(uint256 indexed caseId, address indexed suspect, string description);
    event CaseStatusUpdated(uint256 indexed caseId, uint8 newStatus);
    event CaseClosed(uint256 indexed caseId, bool resolved);

    error UnauthorizedAccess(address caller);
    error CaseNotFound(uint256 caseId);
    error InvalidStatus(uint8 status);

    function openCase(address _suspect, string memory _description) external returns (uint256);
    function updateCaseStatus(uint256 _caseId, uint8 _newStatus) external;
    function closeCase(uint256 _caseId, bool _resolved) external;
    function getCaseStatus(uint256 _caseId) external view returns (uint8);
}