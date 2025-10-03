// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFraudDetectionOracle {
    event FraudReported(address indexed reporter, address indexed suspect, uint256 indexed incidentId, string description);
    event FraudStatusUpdated(uint256 indexed incidentId, uint8 newStatus);

    error UnauthorizedAccess(address caller);
    error IncidentNotFound(uint256 incidentId);
    error InvalidStatus(uint8 status);

    function reportFraud(address _suspect, string memory _description) external returns (uint256);
    function updateFraudStatus(uint256 _incidentId, uint8 _newStatus) external;
    function getFraudStatus(uint256 _incidentId) external view returns (uint8);
    function getFraudDescription(uint256 _incidentId) external view returns (string memory);
}