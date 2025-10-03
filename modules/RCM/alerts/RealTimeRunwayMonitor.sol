// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRealTimeRunwayMonitor {
    event RunwayDropDetected(uint256 indexed currentRunwayDays, uint256 indexed previousRunwayDays, uint256 timestamp);

    error MonitoringFailed(string message);

    function monitorRunway(uint256 _currentRunwayDays) external;
    function setDropThreshold(uint256 _threshold) external;
}

contract RealTimeRunwayMonitor is IRealTimeRunwayMonitor, Ownable {
    uint256 private s_previousRunwayDays;
    uint256 private s_dropThreshold;

    constructor(address initialOwner, uint256 initialDropThreshold) Ownable(initialOwner) {
        s_dropThreshold = initialDropThreshold;
    }

    function monitorRunway(uint256 _currentRunwayDays) external onlyOwner {
        if (s_previousRunwayDays > 0 && (s_previousRunwayDays - _currentRunwayDays) >= s_dropThreshold) {
            emit RunwayDropDetected(_currentRunwayDays, s_previousRunwayDays, block.timestamp);
        }
        s_previousRunwayDays = _currentRunwayDays;
    }

    function setDropThreshold(uint256 _threshold) external onlyOwner {
        s_dropThreshold = _threshold;
    }
}