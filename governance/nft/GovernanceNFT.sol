// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGovernanceNFT {
    // 治理主體 NFT
    function mint(address _to, uint256 _tokenId) external;
    function burn(uint256 _tokenId) external;
    function transfer(address _from, address _to, uint256 _tokenId) external;
    function ownerOf(uint256 _tokenId) external view returns (address);

    event Minted(address indexed to, uint256 indexed tokenId);
    event Burned(uint256 indexed tokenId);
    event Transferred(address indexed from, address indexed to, uint256 indexed tokenId);

    error MintFailed();
    error BurnFailed();
    error TransferFailed();
}