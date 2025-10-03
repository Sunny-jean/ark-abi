// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEncryptionUtils {
    event Encrypted(bytes32 indexed dataHash, bytes encryptedData);
    event Decrypted(bytes32 indexed dataHash, bytes decryptedData);

    error EncryptionFailed(bytes32 dataHash);
    error DecryptionFailed(bytes32 dataHash);

    function encrypt(bytes memory _data, bytes memory _key) external pure returns (bytes memory);
    function decrypt(bytes memory _encryptedData, bytes memory _key) external pure returns (bytes memory);
}