// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISecureRandomNumberGenerator {
    event SecureRandomnessRequested(bytes32 indexed requestId, address indexed consumer);
    event SecureRandomnessReceived(bytes32 indexed requestId, uint256 randomNumber);

    error SecureRandomnessGenerationFailed(bytes32 requestId);

    function requestSecureRandomNumber() external returns (bytes32);
    function fulfillSecureRandomNumber(bytes32 _requestId, uint256 _randomNumber) external;
}