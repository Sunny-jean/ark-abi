// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTPricingOracle {
    function getPrice(uint256 _tokenId) external view returns (uint256);
    function setPrice(uint256 _tokenId, uint256 _price) external;

    event PriceSet(uint256 indexed tokenId, uint256 price);

    error PriceNotFound();
}