// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFraudAlertDispatcher {
    event FraudAlert(address indexed suspect, uint256 indexed incidentId, string message);

    error UnauthorizedAccess(address caller);
    error InvalidRecipient(address recipient);

    function dispatchAlert(address _suspect, uint256 _incidentId, string memory _message) external;
}