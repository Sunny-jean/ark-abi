// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEmergencyRecoveryModule {
    event RecoveryInitiated(address indexed initiator);
    event RecoveryCompleted(address indexed completer);

    error UnauthorizedRecovery(address caller);
    error RecoveryAlreadyActive();
    error RecoveryNotActive();

    function initiateRecovery() external;
    function completeRecovery() external;
    function isRecoveryActive() external view returns (bool);
}