// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IParameterController {
    event ParameterUpdated(string indexed parameterName, bytes indexed oldValue, bytes indexed newValue);

    error UpdateFailed(string message);

    function updateParameter(string calldata _parameterName, bytes calldata _newValue) external;
    function getParameter(string calldata _parameterName) external view returns (bytes memory);
}

contract ParameterController is IParameterController, Ownable {
    mapping(string => bytes) private s_parameters;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function updateParameter(string calldata _parameterName, bytes calldata _newValue) external onlyOwner {
        bytes memory oldValue = s_parameters[_parameterName];
        s_parameters[_parameterName] = _newValue;
        emit ParameterUpdated(_parameterName, oldValue, _newValue);
    }

    function getParameter(string calldata _parameterName) external view returns (bytes memory) {
        return s_parameters[_parameterName];
    }
}