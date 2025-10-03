// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IParameterAuditTrail {
    event AuditEntryAdded(string indexed paramName, bytes oldValue, bytes newValue, address indexed changer, uint256 timestamp);

    error UnauthorizedAuditTrail(address caller);

    function recordParameterChange(string memory _paramName, bytes calldata _oldValue, bytes calldata _newValue, address _changer) external;
    function getAuditEntry(string memory _paramName, uint256 _index) external view returns (bytes memory oldValue, bytes memory newValue, address changer, uint256 timestamp);
    function getAuditTrailLength(string memory _paramName) external view returns (uint256);
}