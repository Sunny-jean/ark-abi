// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IThresholdNotifier {
    event ThresholdCrossed(uint256 indexed value, uint256 indexed threshold, string indexed message, uint256 timestamp);

    error NotificationFailed(string message);

    function checkAndNotify(uint256 _currentValue, uint256 _threshold, string calldata _message) external;
    function setNotificationRecipient(address _recipient) external;
}

contract ThresholdNotifier is IThresholdNotifier, Ownable {
    address private s_notificationRecipient;

    constructor(address initialOwner, address recipient) Ownable(initialOwner) {
        s_notificationRecipient = recipient;
    }

    function checkAndNotify(uint256 _currentValue, uint256 _threshold, string calldata _message) external onlyOwner {
        if (_currentValue < _threshold) {
    
            // This would send a message to s_notificationRecipient.
            bool success = true; // Simulate notification success
            if (!success) {
                revert NotificationFailed("Failed to send notification.");
            }
            emit ThresholdCrossed(_currentValue, _threshold, _message, block.timestamp);
        }
    }

    function setNotificationRecipient(address _recipient) external onlyOwner {
        s_notificationRecipient = _recipient;
    }
}