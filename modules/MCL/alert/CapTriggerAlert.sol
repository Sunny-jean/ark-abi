// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ICapTriggerAlert {
    event CapApproaching(uint256 currentMinted, uint256 cap, uint256 threshold);
    event CapReached(uint256 currentMinted, uint256 cap);

    error InvalidThreshold(uint256 threshold);

    function checkAndTriggerAlert(uint256 _currentMinted, uint256 _cap) external;
    function setCapApproachingThreshold(uint256 _threshold) external;
    function getCapApproachingThreshold() external view returns (uint256);
}

contract CapTriggerAlert is ICapTriggerAlert, Ownable {
    uint256 private s_capApproachingThreshold;

    constructor(address initialOwner, uint256 initialThreshold) Ownable(initialOwner) {
        if (initialThreshold == 0 || initialThreshold >= 100) {
            revert InvalidThreshold(initialThreshold);
        }
        s_capApproachingThreshold = initialThreshold;
    }

    function checkAndTriggerAlert(uint256 _currentMinted, uint256 _cap) external {
        require(_cap > 0, "Cap cannot be zero");
        uint256 remaining = _cap - _currentMinted;
        uint256 thresholdAmount = (_cap * s_capApproachingThreshold) / 100;

        if (_currentMinted >= _cap) {
            emit CapReached(_currentMinted, _cap);
        } else if (remaining <= thresholdAmount) {
            emit CapApproaching(_currentMinted, _cap, s_capApproachingThreshold);
        }
    }

    function setCapApproachingThreshold(uint256 _threshold) external onlyOwner {
        if (_threshold == 0 || _threshold >= 100) {
            revert InvalidThreshold(_threshold);
        }
        s_capApproachingThreshold = _threshold;
    }

    function getCapApproachingThreshold() external view returns (uint256) {
        return s_capApproachingThreshold;
    }
}