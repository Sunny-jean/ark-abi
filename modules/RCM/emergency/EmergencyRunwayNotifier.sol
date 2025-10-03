// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IEmergencyRunwayNotifier {
    event NotificationSent(string indexed recipient, string indexed message, uint256 timestamp);

    error NotificationFailed(string message);

    function notifyGovernance(string calldata _message) external;
    function notifyCommunity(string calldata _message) external;
}

contract EmergencyRunwayNotifier is IEmergencyRunwayNotifier, Ownable {
    constructor(address initialOwner) Ownable(initialOwner) {}

    function notifyGovernance(string calldata _message) external onlyOwner {
        bool success = true; // Simulate notification success
        if (!success) {
            revert NotificationFailed("Failed to notify governance.");
        }
        emit NotificationSent("Governance", _message, block.timestamp);
    }

    function notifyCommunity(string calldata _message) external onlyOwner {
        bool success = true; // Simulate notification success
        if (!success) {
            revert NotificationFailed("Failed to notify community.");
        }
        emit NotificationSent("Community", _message, block.timestamp);
    }
}