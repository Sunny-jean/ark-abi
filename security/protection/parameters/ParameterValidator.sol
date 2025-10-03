// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IParameterValidator {
    event ParameterValidated(string indexed paramName, bytes value);

    error InvalidParameter(string paramName, bytes value);
    error UnauthorizedValidator(address caller);

    function validateParameter(string memory _paramName, bytes calldata _value) external view returns (bool);
}