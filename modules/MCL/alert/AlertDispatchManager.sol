// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IAlertDispatchManager {
    enum AlertType { CapTrigger, SupplyThreshold, EmergencyCap }

    event AlertDispatched(AlertType indexed alertType, string indexed message, address indexed dispatcher);

    error InvalidAlertType();
    error DispatchFailed();

    function dispatchAlert(AlertType _alertType, string calldata _message) external;
    function setDispatcher(AlertType _alertType, address _dispatcher) external;
    function getDispatcher(AlertType _alertType) external view returns (address);
}

contract AlertDispatchManager is IAlertDispatchManager, Ownable {
    mapping(AlertType => address) private s_dispatchers;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function dispatchAlert(AlertType _alertType, string calldata _message) external {
        // In a real scenario, this would call the appropriate external contract/service
        // based on the alert type. For simplicity, we just emit an event.
        require(s_dispatchers[_alertType] != address(0), "No dispatcher set for this alert type");
        // Example: Call an external contract for dispatching
        // IExternalDispatcher(s_dispatchers[_alertType]).send(_message);
        emit AlertDispatched(_alertType, _message, msg.sender);
    }

    function setDispatcher(AlertType _alertType, address _dispatcher) external onlyOwner {
        require(_dispatcher != address(0), "Invalid dispatcher address");
        s_dispatchers[_alertType] = _dispatcher;
    }

    function getDispatcher(AlertType _alertType) external view returns (address) {
        return s_dispatchers[_alertType];
    }
}