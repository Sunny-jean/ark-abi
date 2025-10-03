// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IErrorLoggingTool {
    event ErrorLogged(address indexed contractAddress, string indexed errorMessage, bytes errorData);

    function logError(string memory _errorMessage, bytes memory _errorData) external;
}