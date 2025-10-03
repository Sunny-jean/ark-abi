// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICommunityPollManager {
    // 投票與民調工具
    function createPoll(string calldata _question, string[] calldata _options, uint256 _endTime) external returns (uint256);
    function voteInPoll(uint256 _pollId, uint256 _optionIndex) external;
    function getPollResults(uint256 _pollId) external view returns (uint256[] memory votes);

    event PollCreated(uint256 indexed pollId, string question, uint256 endTime);
    event VotedInPoll(uint256 indexed pollId, address indexed voter, uint256 optionIndex);

    error PollNotFound();
    error PollEnded();
    error InvalidOption();
}