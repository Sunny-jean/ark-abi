// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEmergencyRateLimiter {
    // 利率上限與資金鎖定應對
    function activateEmergencyMode() external;
    function deactivateEmergencyMode() external;
    function isEmergencyModeActive() external view returns (bool);
    function setRateLimit(address _asset, uint256 _limit) external;

    event EmergencyModeActivated();
    event EmergencyModeDeactivated();
    event RateLimitSet(address indexed asset, uint256 limit);

    error AlreadyInEmergencyMode();
}