// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IParameterChangeLogger {
    event ParameterChanged(string indexed paramName, bytes oldValue, bytes newValue, address indexed changer);

    error UnauthorizedLogger(address caller);

    function logParameterChange(string memory _paramName, bytes calldata _oldValue, bytes calldata _newValue) external;
    function getParameterChangeLog(string memory _paramName, uint256 _index) external view returns (bytes memory oldValue, bytes memory newValue, address changer, uint256 timestamp);
}