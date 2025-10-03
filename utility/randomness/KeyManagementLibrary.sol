// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IKeyManagementLibrary {
    event KeyAdded(bytes32 indexed keyId, address indexed owner);
    event KeyRemoved(bytes32 indexed keyId);
    event KeyRotated(bytes32 indexed oldKeyId, bytes32 indexed newKeyId);

    error KeyNotFound(bytes32 keyId);
    error UnauthorizedKeyOperation(address caller);

    function addKey(bytes32 _keyId, bytes memory _publicKey) external;
    function removeKey(bytes32 _keyId) external;
    function rotateKey(bytes32 _oldKeyId, bytes32 _newKeyId, bytes memory _newPublicKey) external;
    function getPublicKey(bytes32 _keyId) external view returns (bytes memory);
}