// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTIncidentReporter {
    function reportIncident(uint256 _tokenId, string calldata _description) external;
    function getIncidentDetails(uint256 _incidentId) external view returns (uint256 tokenId, string memory description, uint256 timestamp);

    event IncidentReported(uint256 indexed incidentId, uint256 indexed tokenId, string description, uint256 timestamp);

    error IncidentNotFound();
}