// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTAuthorizationRegistry {
    function authorize(address _operator, uint256 _tokenId) external;
    function revokeAuthorization(address _operator, uint256 _tokenId) external;
    function isAuthorized(address _operator, uint256 _tokenId) external view returns (bool);

    event Authorized(address indexed operator, uint256 indexed tokenId);
    event AuthorizationRevoked(address indexed operator, uint256 indexed tokenId);

    error AlreadyAuthorized();
    error NotAuthorized();
}