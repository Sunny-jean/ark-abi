// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOracleSecurityVerifier {
    event DataVerified(address indexed oracleAddress, bytes32 indexed dataHash);

    error VerificationFailed(address oracleAddress, bytes32 dataHash);

    function verifyData(address _oracleAddress, bytes memory _data, bytes memory _signature) external view returns (bool);
}