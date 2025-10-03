// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISecurityIncidentReporter {
    event IncidentReported(uint256 indexed incidentId, address indexed reporter, string description, uint256 timestamp);

    error UnauthorizedAccess(address caller);
    error EmptyDescription();

    function reportIncident(string memory _description) external returns (uint256);
    function getIncidentDescription(uint256 _incidentId) external view returns (string memory);
}