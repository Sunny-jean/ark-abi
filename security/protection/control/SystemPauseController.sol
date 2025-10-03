// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISystemPauseController {
    event SystemPaused(address indexed pauser);
    event SystemUnpaused(address indexed unpauser);

    error UnauthorizedPause(address caller);
    error SystemAlreadyPaused();
    error SystemNotPaused();

    function pauseSystem() external;
    function unpauseSystem() external;
    function isSystemPaused() external view returns (bool);
}