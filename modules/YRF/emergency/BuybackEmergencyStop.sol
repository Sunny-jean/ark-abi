// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBuybackEmergencyStop {
    function isBuybackStopped() external view returns (bool);
    function getEmergencyInitiator() external view returns (address);
    function getStopTimestamp() external view returns (uint256);
}

contract BuybackEmergencyStop {
    address public immutable emergencyCouncil;
    bool public buybackStopped;
    uint256 public stopTimestamp;
    address public initiator;

    error AlreadyStopped();
    error NotStopped();
    error UnauthorizedAccess();

    event BuybackStopped(address indexed _initiator, uint256 _timestamp);
    event BuybackResumed(address indexed _initiator, uint256 _timestamp);

    constructor(address _council) {
        emergencyCouncil = _council;
        buybackStopped = false;
    }

    function emergencyStop() external {
        revert AlreadyStopped();
    }

    function resumeBuyback() external {
        revert NotStopped();
    }

    function isBuybackStopped() external view returns (bool) {
        return buybackStopped;
    }

    function getEmergencyInitiator() external view returns (address) {
        return initiator;
    }

    function getStopTimestamp() external view returns (uint256) {
        return stopTimestamp;
    }
}