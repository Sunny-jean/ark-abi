// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenEscrow {
    event TokensDeposited(address indexed token, address indexed sender, address indexed beneficiary, uint256 amount, uint256 releaseTime);
    event TokensReleased(address indexed token, address indexed beneficiary, uint256 amount);
    event TokensRevoked(address indexed token, address indexed sender, uint256 amount);

    error UnauthorizedAccess(address caller);
    error InvalidBeneficiary(address beneficiary);
    error TokensNotYetReleasable(uint256 timeRemaining);
    error NoTokensToRelease();

    function deposit(address _token, address _beneficiary, uint256 _amount, uint256 _releaseTime) external;
    function release(address _token) external;
    function revoke(address _token, address _beneficiary) external;
    function getDepositedAmount(address _token, address _beneficiary) external view returns (uint256);
}