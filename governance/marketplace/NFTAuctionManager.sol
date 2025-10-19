// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTAuctionManager {
    function createAuction(uint256 _tokenId, uint256 _startingBid, uint256 _endTime) external;
    function placeBid(uint256 _auctionId) external payable;
    function endAuction(uint256 _auctionId) external;
    function getAuctionDetails(uint256 _auctionId) external view returns (uint256 tokenId, uint256 highestBid, address highestBidder, uint256 endTime, bool ended);

    event AuctionCreated(uint256 indexed auctionId, uint256 indexed tokenId, uint256 startingBid, uint256 endTime);
    event BidPlaced(uint256 indexed auctionId, address indexed bidder, uint256 amount);
    event AuctionEnded(uint256 indexed auctionId, uint256 indexed tokenId, address winner, uint256 amount);

    error AuctionNotFound();
    error AuctionAlreadyEnded();
    error BidTooLow();
}