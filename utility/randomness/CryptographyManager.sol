// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICryptographyManager {
    event KeyGenerated(bytes32 indexed keyId, bytes publicKey);
    event SignatureVerified(bytes32 indexed dataHash, address indexed signer, bool isValid);

    error KeyGenerationFailed(string reason);
    error SignatureVerificationFailed(bytes32 dataHash);

    function generateKeyPair() external returns (bytes32 keyId, bytes memory publicKey);
    function signData(bytes32 _dataHash, bytes32 _privateKey) external pure returns (bytes memory signature);
    function verifySignature(bytes32 _dataHash, bytes memory _signature, address _signer) external pure returns (bool);
}