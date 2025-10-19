// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTMintingManager {
    function mintNFT(address _to, uint256 _tokenId) external;
    function setMintingEnabled(bool _enabled) external;
    function isMintingEnabled() external view returns (bool);

    event NFTMinted(address indexed to, uint256 indexed tokenId);
    event MintingStatusChanged(bool enabled);

    error MintingDisabled();
}