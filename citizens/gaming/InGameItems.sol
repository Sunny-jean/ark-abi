// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface InGameItems {
    /**
     * @dev Emitted when a new item type is defined.
     * @param itemId The unique ID of the item type.
     * @param name The name of the item.
     * @param description The description of the item.
     * @param fungible True if the item is fungible (ERC-20), false if non-fungible (ERC-721).
     */
    event ItemDefined(bytes32 indexed itemId, string name, string description, bool fungible);

    /**
     * @dev Emitted when an item is minted or created.
     * @param itemId The ID of the item type.
     * @param to The address to which the item is minted.
     * @param amount The amount of the item minted (for fungible items) or 1 (for non-fungible).
     * @param tokenId The specific token ID for non-fungible items (0 for fungible).
     */
    event ItemMinted(bytes32 indexed itemId, address indexed to, uint256 amount, uint256 indexed tokenId);

    /**
     * @dev Emitted when an item is transferred.
     * @param itemId The ID of the item type.
     * @param from The address from which the item is transferred.
     * @param to The address to which the item is transferred.
     * @param amount The amount of the item transferred (for fungible items) or 1 (for non-fungible).
     * @param tokenId The specific token ID for non-fungible items (0 for fungible).
     */
    event ItemTransferred(bytes32 indexed itemId, address indexed from, address indexed to, uint256 amount, uint256 tokenId);

    /**
     * @dev Emitted when an item is burned or destroyed.
     * @param itemId The ID of the item type.
     * @param from The address from which the item is burned.
     * @param amount The amount of the item burned (for fungible items) or 1 (for non-fungible).
     * @param tokenId The specific token ID for non-fungible items (0 for fungible).
     */
    event ItemBurned(bytes32 indexed itemId, address indexed from, uint256 amount, uint256 indexed tokenId);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when an item with the given ID is not found.
     */
    error ItemNotFound(bytes32 itemId);

    /**
     * @dev Thrown when the sender does not have enough of a fungible item.
     */
    error InsufficientItemBalance(bytes32 itemId, address holder, uint256 requested, uint256 available);

    /**
     * @dev Thrown when a non-fungible token ID is invalid or not owned by the sender.
     */
    error InvalidTokenId(bytes32 itemId, uint256 tokenId);

    /**
     * @dev Defines a new in-game item type.
     * Only callable by authorized game administrators or item creators.
     * @param itemId The unique ID for the item type.
     * @param name The name of the item.
     * @param description The description of the item.
     * @param fungible True if the item is fungible (ERC-20-like), false if non-fungible (ERC-721-like).
     */
    function defineItem(bytes32 itemId, string calldata name, string calldata description, bool fungible) external;

    /**
     * @dev Mints new items of a defined type to a specific address.
     * Only callable by authorized game contracts or administrators.
     * @param itemId The ID of the item type to mint.
     * @param to The address to which the items will be minted.
     * @param amount The amount of items to mint (for fungible items) or 1 (for non-fungible).
     * @return tokenId The specific token ID for non-fungible items (0 for fungible).
     */
    function mintItem(bytes32 itemId, address to, uint256 amount) external returns (uint256 tokenId);

    /**
     * @dev Transfers items from one address to another.
     * @param itemId The ID of the item type to transfer.
     * @param from The address from which to transfer items.
     * @param to The address to which to transfer items.
     * @param amount The amount of items to transfer (for fungible items) or 1 (for non-fungible).
     * @param tokenId The specific token ID for non-fungible items (0 for fungible).
     */
    function transferItem(bytes32 itemId, address from, address to, uint256 amount, uint256 tokenId) external;

    /**
     * @dev Burns items from a specific address.
     * Only callable by authorized game contracts or administrators.
     * @param itemId The ID of the item type to burn.
     * @param from The address from which to burn items.
     * @param amount The amount of items to burn (for fungible items) or 1 (for non-fungible).
     * @param tokenId The specific token ID for non-fungible items (0 for fungible).
     */
    function burnItem(bytes32 itemId, address from, uint256 amount, uint256 tokenId) external;

    /**
     * @dev Retrieves the details of a defined item type.
     * @param itemId The ID of the item type to query.
     * @return name The name of the item.
     * @return description The description of the item.
     * @return fungible True if the item is fungible, false otherwise.
     */
    function getItemDetails(bytes32 itemId) external view returns (string memory name, string memory description, bool fungible);

    /**
     * @dev Retrieves the balance of a fungible item for a specific holder.
     * @param itemId The ID of the fungible item type.
     * @param holder The address of the item holder.
     * @return balance The amount of the item held by the address.
     */
    function getFungibleItemBalance(bytes32 itemId, address holder) external view returns (uint256 balance);

    /**
     * @dev Checks if a specific non-fungible token ID is owned by an address.
     * @param itemId The ID of the non-fungible item type.
     * @param tokenId The specific token ID.
     * @return owner The address of the token owner.
     */
    function getNonFungibleItemOwner(bytes32 itemId, uint256 tokenId) external view returns (address owner);
}