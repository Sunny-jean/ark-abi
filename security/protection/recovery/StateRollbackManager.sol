// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStateRollbackManager {
    event RollbackInitiated(uint256 indexed blockNumber, address indexed initiator);
    event RollbackCompleted(uint256 indexed blockNumber);

    error UnauthorizedRollback(address caller);
    error InvalidBlockNumber(uint256 blockNumber);

    function initiateRollback(uint256 _blockNumber) external;
    function completeRollback() external;
    function isRollbackActive() external view returns (bool);
}