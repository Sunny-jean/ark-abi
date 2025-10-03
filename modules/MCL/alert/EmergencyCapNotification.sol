// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IEmergencyCapNotification {
    event EmergencyNotificationSent(string indexed message, uint256 timestamp);

    error NotificationFailed();

    function sendEmergencyNotification(string calldata _message) external;
    function setNotificationRecipient(address _recipient) external;
    function getNotificationRecipient() external view returns (address);
}

contract EmergencyCapNotification is IEmergencyCapNotification, Ownable {
    address private s_notificationRecipient;

    constructor(address initialOwner, address initialRecipient) Ownable(initialOwner) {
        require(initialRecipient != address(0), "Invalid recipient");
        s_notificationRecipient = initialRecipient;
    }

    function sendEmergencyNotification(string calldata _message) external onlyOwner {
        // In a real scenario, this would integrate with an off-chain system
        // (e.g., Chainlink Keepers, Gelato, or a custom relayer) to dispatch
        // the notification via webhooks, email, or other channels.
        // For this example, we just emit an event.
        emit EmergencyNotificationSent(_message, block.timestamp);
    }

    function setNotificationRecipient(address _recipient) external onlyOwner {
        require(_recipient != address(0), "Invalid recipient");
        s_notificationRecipient = _recipient;
    }

    function getNotificationRecipient() external view returns (address) {
        return s_notificationRecipient;
    }
}