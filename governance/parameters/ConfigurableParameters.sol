// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IConfigurableParameters {
    function getParameter(string calldata _parameterName) external view returns (bytes memory);
    function setParameter(string calldata _parameterName, bytes calldata _value) external;

    event ParameterSet(string parameterName, bytes value);

    error ParameterNotFound();
}