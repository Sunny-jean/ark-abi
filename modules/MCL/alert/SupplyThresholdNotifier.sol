// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ISupplyThresholdNotifier {
    event ThresholdExceeded(uint256 currentSupply, uint256 threshold);
    event ThresholdSet(uint256 oldThreshold, uint256 newThreshold);

    error InvalidThreshold(uint256 threshold);

    function checkAndNotify(uint256 _currentSupply) external;
    function setSupplyThreshold(uint256 _threshold) external;
    function getSupplyThreshold() external view returns (uint256);
}

contract SupplyThresholdNotifier is ISupplyThresholdNotifier, Ownable {
    uint256 private s_supplyThreshold;

    constructor(address initialOwner, uint256 initialThreshold) Ownable(initialOwner) {
        if (initialThreshold == 0) {
            revert InvalidThreshold(0);
        }
        s_supplyThreshold = initialThreshold;
    }

    function checkAndNotify(uint256 _currentSupply) external {
        if (_currentSupply > s_supplyThreshold) {
            emit ThresholdExceeded(_currentSupply, s_supplyThreshold);
        }
    }

    function setSupplyThreshold(uint256 _threshold) external onlyOwner {
        if (_threshold == 0) {
            revert InvalidThreshold(0);
        }
        emit ThresholdSet(s_supplyThreshold, _threshold);
        s_supplyThreshold = _threshold;
    }

    function getSupplyThreshold() external view returns (uint256) {
        return s_supplyThreshold;
    }
}