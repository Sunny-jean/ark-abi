// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IParameterController {
    event ParameterUpdated(string indexed parameterName, bytes indexed oldValue, bytes indexed newValue);

    error UpdateFailed(string message);

    function updateParameter(string calldata _parameterName, bytes calldata _newValue) external;
    function getParameter(string calldata _parameterName) external view returns (bytes memory);
}