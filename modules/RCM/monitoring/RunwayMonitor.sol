// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayMonitor {
    event RunwayUpdated(uint256 indexed remainingDays, uint256 indexed timestamp);

    error InvalidInput(string message);

    function updateRunway(uint256 _incentivePoolBalance, uint256 _currentROI) external;
    function getRemainingRunway() external view returns (uint256);
}

contract RunwayMonitor is IRunwayMonitor, Ownable {
    uint256 private s_remainingRunwayDays;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function updateRunway(uint256 _incentivePoolBalance, uint256 _currentROI) external onlyOwner {
        if (_incentivePoolBalance == 0 || _currentROI == 0) {
            revert InvalidInput("Incentive pool balance or ROI cannot be zero.");
        }

        // This would involve a more sophisticated model to estimate remaining days.
        s_remainingRunwayDays = (_incentivePoolBalance * _currentROI) / 10000; // Example calculation
        emit RunwayUpdated(s_remainingRunwayDays, block.timestamp);
    }

    function getRemainingRunway() external view returns (uint256) {
        return s_remainingRunwayDays;
    }
}