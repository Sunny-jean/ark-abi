// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRandomnessProvider {
    event RandomnessRequested(bytes32 indexed requestId, address indexed consumer);
    event RandomnessReceived(bytes32 indexed requestId, uint256 randomNumber);

    error RandomnessGenerationFailed(bytes32 requestId);

    function requestRandomNumber() external returns (bytes32);
    function fulfillRandomNumber(bytes32 _requestId, uint256 _randomNumber) external;
}