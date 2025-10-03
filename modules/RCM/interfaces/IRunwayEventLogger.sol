// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRunwayEventLogger {
    event EventLogged(string indexed eventName, address indexed initiator, uint256 timestamp, bytes data);

    function logEvent(string calldata _eventName, address _initiator, bytes calldata _data) external;
    function getEventLog(uint256 _index) external view returns (string memory eventName, address initiator, uint256 timestamp, bytes memory data);
    function getEventCount() external view returns (uint256);
}