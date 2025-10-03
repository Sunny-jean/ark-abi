// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEventLogger {
    event Log(string indexed eventName, bytes data);

    function logEvent(string memory _eventName, bytes memory _data) external;
}