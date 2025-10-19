// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTLifecycleController {
    function pauseNFT(uint256 _tokenId) external;
    function unpauseNFT(uint256 _tokenId) external;
    function isPaused(uint256 _tokenId) external view returns (bool);

    event NFTPaused(uint256 indexed tokenId);
    event NFTUnpaused(uint256 indexed tokenId);

    error NFTAlreadyPaused();
    error NFTNotPaused();
}