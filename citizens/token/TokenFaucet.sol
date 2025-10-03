// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenFaucet {
    event TokensClaimed(address indexed user, address indexed token, uint256 amount);
    event DripRateUpdated(address indexed token, uint256 oldRate, uint256 newRate);

    error InsufficientTimeElapsed(uint256 timeRemaining);
    error NoTokensAvailable(address token);
    error UnauthorizedAccess(address caller);

    function claimTokens(address _token) external;
    function setDripRate(address _token, uint256 _rate) external;
    function getAvailableTokens(address _user, address _token) external view returns (uint256);
}