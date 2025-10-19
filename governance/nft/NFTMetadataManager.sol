// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTMetadataManager {
    function setTokenURI(uint256 _tokenId, string calldata _uri) external;
    function getTokenURI(uint256 _tokenId) external view returns (string memory);

    event TokenURISet(uint256 indexed tokenId, string uri);

    error InvalidTokenId();
}