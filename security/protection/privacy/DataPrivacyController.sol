// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDataPrivacyController {
    event DataEncrypted(bytes32 indexed dataHash, address indexed encryptor);
    event DataDecrypted(bytes32 indexed dataHash, address indexed decryptor);

    error UnauthorizedAccess(address caller);
    error DataNotEncrypted(bytes32 dataHash);

    function encryptData(bytes calldata _data) external returns (bytes32 encryptedDataHash);
    function decryptData(bytes32 _encryptedDataHash) external returns (bytes memory decryptedData);
    function isDataEncrypted(bytes32 _dataHash) external view returns (bool);
}