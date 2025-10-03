// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISecurityIncidentDatabase {
    event IncidentStored(uint256 indexed incidentId, bytes32 indexed incidentHash);

    error UnauthorizedAccess(address caller);
    error IncidentNotFound(uint256 incidentId);

    function storeIncident(bytes32 _incidentHash, string memory _details) external returns (uint256);
    function getIncidentDetails(uint256 _incidentId) external view returns (bytes32 incidentHash, string memory details);
}