// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIntrusionDetectionSystem {
    event IntrusionDetected(address indexed attacker, string indexed attackType);
    event IntrusionReported(address indexed reporter, address indexed attacker, string attackType);

    error UnauthorizedIDS(address caller);

    function reportIntrusion(address _attacker, string memory _attackType) external;
    function getIntrusionCount(address _attacker) external view returns (uint256);
}