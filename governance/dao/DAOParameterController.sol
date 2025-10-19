// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDAOParameterController {
    function setDAOParameter(string calldata _parameterName, bytes calldata _value) external;
    function getDAOParameter(string calldata _parameterName) external view returns (bytes memory);

    event DAOParameterSet(string parameterName, bytes value);

    error ParameterUpdateFailed();
}