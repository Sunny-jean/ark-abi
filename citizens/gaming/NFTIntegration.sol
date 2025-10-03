// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface NFTIntegration {
    /**
     * @dev Emitted when an NFT is minted as a game reward.
     * @param gameId The ID of the game.
     * @param player The address of the player who received the NFT.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the minted NFT.
     */
    event NFTRewardMinted(bytes32 indexed gameId, address indexed player, address indexed nftContract, uint256 tokenId);

    /**
     * @dev Emitted when an NFT is used within a game (e.g., consumed, staked).
     * @param gameId The ID of the game.
     * @param player The address of the player using the NFT.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT used.
     * @param usageType A string describing the type of usage (e.g., "consume", "stake", "equip").
     */
    event NFTUsedInGame(bytes32 indexed gameId, address indexed player, address indexed nftContract, uint256 tokenId, string usageType);

    /**
     * @dev Emitted when an NFT is burned or removed from circulation due to game mechanics.
     * @param gameId The ID of the game.
     * @param player The address of the player whose NFT was burned.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT burned.
     */
    event NFTBurnedInGame(bytes32 indexed gameId, address indexed player, address indexed nftContract, uint256 tokenId);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when the specified NFT contract is not recognized or supported.
     */
    error UnsupportedNFTContract(address nftContract);

    /**
     * @dev Thrown when the player does not own the specified NFT.
     */
    error NotNFTOwner(address player, address nftContract, uint256 tokenId);

    /**
     * @dev Thrown when an NFT is attempted to be used in a way not allowed by game rules.
     */
    error InvalidNFTUsage(bytes32 gameId, address nftContract, uint256 tokenId, string usageType);

    /**
     * @dev Mints an NFT as a reward for a player in a specific game.
     * Only callable by authorized game contracts or administrators.
     * @param gameId The ID of the game.
     * @param player The address of the player to reward.
     * @param nftContract The address of the NFT contract to mint from.
     * @param tokenId The ID of the NFT to mint.
     */
    function mintNFTReward(bytes32 gameId, address player, address nftContract, uint256 tokenId) external;

    /**
     * @dev Records the usage of an NFT within a game.
     * This function might trigger game-specific logic (e.g., consuming an item).
     * Only callable by authorized game contracts.
     * @param gameId The ID of the game.
     * @param player The address of the player using the NFT.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT being used.
     * @param usageType A string describing the type of usage (e.g., "consume", "stake", "equip").
     */
    function useNFTInGame(bytes32 gameId, address player, address nftContract, uint256 tokenId, string calldata usageType) external;

    /**
     * @dev Burns an NFT due to game mechanics (e.g., item consumption).
     * Only callable by authorized game contracts or administrators.
     * @param gameId The ID of the game.
     * @param player The address of the player whose NFT is being burned.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT to burn.
     */
    function burnNFTInGame(bytes32 gameId, address player, address nftContract, uint256 tokenId) external;

    /**
     * @dev Checks if a specific NFT is valid for use in a given game.
     * @param gameId The ID of the game.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT.
     * @return True if the NFT is valid for the game, false otherwise.
     */
    function isValidGameNFT(bytes32 gameId, address nftContract, uint256 tokenId) external view returns (bool);

    /**
     * @dev Retrieves the game-specific properties or metadata of an NFT.
     * @param gameId The ID of the game.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT.
     * @return metadata A string containing JSON or other structured metadata.
     */
    function getNFTGameMetadata(bytes32 gameId, address nftContract, uint256 tokenId) external view returns (string memory metadata);
}