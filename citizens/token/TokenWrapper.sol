// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenWrapper {
    event TokensWrapped(address indexed originalToken, address indexed wrappedToken, address indexed user, uint256 amount);
    event TokensUnwrapped(address indexed wrappedToken, address indexed originalToken, address indexed user, uint256 amount);

    error InvalidToken(address token);
    error InsufficientBalance(uint256 required, uint256 available);
    error UnauthorizedAccess(address caller);

    function wrap(address _token, uint256 _amount) external;
    function unwrap(address _token, uint256 _amount) external;
    function getWrappedToken(address _originalToken) external view returns (address);
}