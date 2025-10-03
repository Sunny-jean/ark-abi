// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGovernanceNFTMarketplace {
    // 去中心治理 NFT 市場
    function listItem(uint256 _tokenId, uint256 _price) external;
    function buyItem(uint256 _tokenId) external payable;
    function cancelListing(uint256 _tokenId) external;
    function getListing(uint256 _tokenId) external view returns (address seller, uint256 price);

    event ItemListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event ItemBought(uint256 indexed tokenId, address indexed buyer, uint256 price);
    event ListingCancelled(uint256 indexed tokenId);

    error ItemNotFound();
    error NotEnoughFunds();
    error NotOwner();
}