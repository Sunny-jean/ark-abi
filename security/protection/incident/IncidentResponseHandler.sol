// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIncidentResponseHandler {
    event IncidentStatusUpdated(uint256 indexed incidentId, uint8 newStatus);
    event IncidentResolved(uint256 indexed incidentId, string resolutionDetails);

    error UnauthorizedAccess(address caller);
    error IncidentNotFound(uint256 incidentId);
    error InvalidStatus(uint8 status);

    function updateIncidentStatus(uint256 _incidentId, uint8 _newStatus) external;
    function resolveIncident(uint256 _incidentId, string memory _resolutionDetails) external;
    function getIncidentStatus(uint256 _incidentId) external view returns (uint8);
}