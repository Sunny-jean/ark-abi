// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTStakingManager {
    // NFT 質押控制器
    function stakeNFT(uint256 _tokenId) external;
    function unstakeNFT(uint256 _tokenId) external;
    function getStakedNFTs(address _user) external view returns (uint256[] memory);

    event NFTStaked(address indexed user, uint256 indexed tokenId);
    event NFTUnstaked(address indexed user, uint256 indexed tokenId);

    error NFTAlreadyStaked();
    error NFTNotStaked();
}