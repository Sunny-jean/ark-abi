// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRecoveryKeyManager {
    event RecoveryKeySet(address indexed user, bytes32 indexed keyHash);
    event RecoveryKeyUsed(address indexed user, address indexed newAddress);

    error UnauthorizedKeyManager(address caller);
    error InvalidKey(bytes32 keyHash);

    function setRecoveryKey(bytes32 _keyHash) external;
    function useRecoveryKey(address _newAddress, bytes32 _keyHash) external;
    function hasRecoveryKey(address _user) external view returns (bool);
}