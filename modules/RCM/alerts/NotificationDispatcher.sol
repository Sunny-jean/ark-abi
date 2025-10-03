// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface INotificationDispatcher {
    event NotificationDispatched(string indexed platform, string indexed message, uint256 timestamp);

    error DispatchFailed(string message);

    function dispatch(string calldata _platform, string calldata _message) external;
    function setPlatformAddress(string calldata _platform, address _platformAddress) external;
}

contract NotificationDispatcher is INotificationDispatcher, Ownable {
    mapping(string => address) private s_platformAddresses;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function dispatch(string calldata _platform, string calldata _message) external onlyOwner {
        address platformAddr = s_platformAddresses[_platform];
        require(platformAddr != address(0), "Platform address not set.");


        // This would involve external calls or specific integrations.
        bool success = true; // Simulate dispatch success
        if (!success) {
            revert DispatchFailed("Failed to dispatch notification.");
        }
        emit NotificationDispatched(_platform, _message, block.timestamp);
    }

    function setPlatformAddress(string calldata _platform, address _platformAddress) external onlyOwner {
        s_platformAddresses[_platform] = _platformAddress;
    }
}