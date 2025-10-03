// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDebuggingTool {
    event DebugLog(string indexed message, bytes data);

    function log(string memory _message, bytes memory _data) external;
    function trace(bytes memory _callData) external returns (bytes memory);
}