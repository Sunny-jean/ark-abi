// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDynamicParameterAdjuster {
    event ParameterAdjusted(string indexed paramName, bytes newValue, address indexed adjuster);

    error UnauthorizedAdjuster(address caller);
    error InvalidAdjustment(string paramName, bytes value);

    function adjustParameter(string memory _paramName, bytes calldata _newValue) external;
    function getParameter(string memory _paramName) external view returns (bytes memory);
}