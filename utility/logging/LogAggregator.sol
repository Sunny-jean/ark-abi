// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILogAggregator {
    event AggregatedLog(address indexed sourceContract, string indexed logType, bytes logData);

    error UnauthorizedLogSource(address source);

    function aggregateLog(address _sourceContract, string memory _logType, bytes memory _logData) external;
    function getAggregatedLogs(address _sourceContract, string memory _logType) external view returns (bytes[] memory);
}