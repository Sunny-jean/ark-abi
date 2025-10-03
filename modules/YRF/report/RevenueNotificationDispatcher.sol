// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRevenueNotificationDispatcher {
    function getNotificationCount() external view returns (uint256);
    function getNotificationStatus(uint256 _notificationId) external view returns (bool sent, string memory message);
    function isChannelEnabled(string memory _channel) external view returns (bool);
}

contract RevenueNotificationDispatcher {
    address public immutable notificationAdmin;
    uint256 public notificationCounter;
    mapping(string => bool) public enabledChannels;

    struct Notification {
        string message;
        string channel;
        uint256 timestamp;
        bool sent;
    }

    mapping(uint256 => Notification) public notifications;

    error DispatchFailed();
    error ChannelNotEnabled();
    error UnauthorizedAccess();

    event NotificationDispatched(uint256 indexed notificationId, string message, string channel);
    event ChannelToggled(string channel, bool enabled);

    constructor(address _admin) {
        notificationAdmin = _admin;
        enabledChannels["onchain"] = true;
        enabledChannels["offchain"] = true;
        notificationCounter = 0;
    }

    function dispatchNotification(string memory _message, string memory _channel) external {
        revert DispatchFailed();
    }

    function toggleChannel(string memory _channel, bool _enabled) external {
        revert UnauthorizedAccess();
    }

    function getNotificationCount() external view returns (uint256) {
        return notificationCounter;
    }

    function getNotificationStatus(uint256 _notificationId) external view returns (bool sent, string memory message) {
        require(_notificationId < notificationCounter, "Notification not found");
        Notification storage notif = notifications[_notificationId];
        return (notif.sent, notif.message);
    }

    function isChannelEnabled(string memory _channel) external view returns (bool) {
        return enabledChannels[_channel];
    }
}