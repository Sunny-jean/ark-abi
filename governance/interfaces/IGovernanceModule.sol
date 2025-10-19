// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGovernanceModule {
    function initialize() external;
    function shutdown() external;
    function getStatus() external view returns (bool);

    event Initialized();
    event Shutdown();

    error AlreadyInitialized();
    error NotInitialized();
}
