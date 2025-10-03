// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGovernanceModule {
    // 治理模組通用介面
    function initialize() external;
    function shutdown() external;
    function getStatus() external view returns (bool);

    event Initialized();
    event Shutdown();

    error AlreadyInitialized();
    error NotInitialized();
}