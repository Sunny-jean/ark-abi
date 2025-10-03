// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIncidentInvestigationAI {
    event InvestigationStarted(uint256 indexed incidentId, string indexed investigationType);
    event InvestigationCompleted(uint256 indexed incidentId, string analysisResult);

    error UnauthorizedAccess(address caller);
    error IncidentNotFound(uint256 incidentId);

    function startInvestigation(uint256 _incidentId, string memory _investigationType) external;
    function getInvestigationResult(uint256 _incidentId) external view returns (string memory analysisResult);
}