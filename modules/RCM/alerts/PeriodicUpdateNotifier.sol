// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IPeriodicUpdateNotifier {
    event UpdateSent(uint256 indexed timestamp, string indexed updateType, string indexed message);

    error NotificationFailed(string message);

    function sendUpdate(string calldata _updateType, string calldata _message) external;
    function setUpdateInterval(uint256 _interval) external;
}

contract PeriodicUpdateNotifier is IPeriodicUpdateNotifier, Ownable {
    uint256 private s_updateInterval;
    uint256 private s_lastUpdateTime;

    constructor(address initialOwner, uint256 initialInterval) Ownable(initialOwner) {
        s_updateInterval = initialInterval;
        s_lastUpdateTime = block.timestamp;
    }

    function sendUpdate(string calldata _updateType, string calldata _message) external onlyOwner {
        require(block.timestamp >= s_lastUpdateTime + s_updateInterval, "Update interval not yet passed.");

        bool success = true; // Simulate update success
        if (!success) {
            revert NotificationFailed("Failed to send update.");
        }
        s_lastUpdateTime = block.timestamp;
        emit UpdateSent(block.timestamp, _updateType, _message);
    }

    function setUpdateInterval(uint256 _interval) external onlyOwner {
        s_updateInterval = _interval;
    }
}