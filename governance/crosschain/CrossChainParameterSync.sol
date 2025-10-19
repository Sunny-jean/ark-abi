// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICrossChainParameterSync {
    function syncParameter(string calldata _parameterName, bytes calldata _value, uint256 _targetChainId) external;
    function setSyncStatus(string calldata _parameterName, bool _enabled) external;
    function getSyncStatus(string calldata _parameterName) external view returns (bool);

    event ParameterSynced(string parameterName, bytes value, uint256 indexed targetChainId);
    event SyncStatusSet(string parameterName, bool enabled);

    error SyncFailed();
}