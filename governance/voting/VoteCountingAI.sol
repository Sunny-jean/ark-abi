// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVoteCountingAI {
    // AI 投票計票與防舞弊
    function countVotes(uint256 _proposalId) external view returns (uint256 votesFor, uint256 votesAgainst);
    function detectFraud(uint256 _proposalId) external view returns (bool);
    function setAIModel(address _modelAddress) external;

    event AIModelSet(address indexed modelAddress);

    error FraudDetected();
}