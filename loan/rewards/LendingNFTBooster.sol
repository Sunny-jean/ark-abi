// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILendingNFTBooster {
    function getBoostedBorrowLimit(address _user, uint256 _originalLimit) external view returns (uint256);
    function registerNFT(address _nftContract, uint256 _tokenId, uint256 _boostFactor) external;
    function unregisterNFT(address _nftContract, uint256 _tokenId) external;

    event NFTRegistered(address indexed nftContract, uint256 indexed tokenId, uint256 boostFactor);
    event NFTUnregistered(address indexed nftContract, uint256 indexed tokenId);

    error InvalidNFT();
}