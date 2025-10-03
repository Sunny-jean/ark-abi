// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOperationalPause {
    event Paused(address account);
    event Unpaused(address account);

    error PausableUnauthorized(address caller);
    error PausablePaused();
    error PausableNotPaused();

    function pause() external;
    function unpause() external;
    function paused() external view returns (bool);
}