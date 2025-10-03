// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface SoulboundTokens {
    /**
     * @dev Emitted when a soulbound token is minted.
     */
    event SoulboundTokenMinted(uint256 indexed tokenId, address indexed recipient, string tokenURI);

    /**
     * @dev Error when a token is not soulbound.
     */
    error NotSoulbound(uint256 tokenId);

    /**
     * @dev Mints a new soulbound token to a recipient.
     * Soulbound tokens cannot be transferred after minting.
     * @param recipient The address to mint the token to.
     * @param tokenURI The URI for the token's metadata.
     * @return The ID of the newly minted token.
     */
    function mintSoulboundToken(address recipient, string calldata tokenURI) external returns (uint256);

    /**
     * @dev Returns the URI for a given soulbound token ID.
     * @param tokenId The ID of the token.
     * @return The URI for the token's metadata.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    /**
     * @dev Returns the owner of a soulbound token.
     * @param tokenId The ID of the token.
     * @return The address of the token owner.
     */
    function ownerOf(uint256 tokenId) external view returns (address);

    /**
     * @dev Returns the total number of soulbound tokens in existence.
     */
    function totalSupply() external view returns (uint256);
}