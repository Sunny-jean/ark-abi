// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface NFTMarketplace {
    /**
     * @dev Emitted when an NFT is listed for sale.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT.
     * @param seller The address of the seller.
     * @param price The listing price.
     */
    event NFTListed(address indexed nftContract, uint256 indexed tokenId, address indexed seller, uint256 price);

    /**
     * @dev Emitted when an NFT sale is cancelled.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT.
     * @param seller The address of the seller.
     */
    event NFTListingCancelled(address indexed nftContract, uint256 indexed tokenId, address indexed seller);

    /**
     * @dev Emitted when an NFT is successfully purchased.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT.
     * @param buyer The address of the buyer.
     * @param seller The address of the seller.
     * @param price The sale price.
     */
    event NFTPurchased(address indexed nftContract, uint256 indexed tokenId, address indexed buyer, address seller, uint256 price);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a required parameter is missing or invalid.
     */
    error InvalidParameter(string parameterName, string description);

    /**
     * @dev Thrown when an NFT is not found or not listed for sale.
     */
    error NFTNotFoundOrNotListed();

    /**
     * @dev Thrown when the provided price is insufficient for a purchase.
     */
    error InsufficientPayment(uint256 required, uint256 provided);

    /**
     * @dev Thrown when the NFT is already listed for sale.
     */
    error NFTAlreadyListed();

    /**
     * @dev Lists an NFT for sale.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT to list.
     * @param price The price in native currency or a specified ERC20 token.
     */
    function listNFT(address nftContract, uint256 tokenId, uint256 price) external;

    /**
     * @dev Cancels an active NFT listing.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT to delist.
     */
    function cancelListing(address nftContract, uint256 tokenId) external;

    /**
     * @dev Purchases a listed NFT.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT to purchase.
     */
    function purchaseNFT(address nftContract, uint256 tokenId) external payable;

    /**
     * @dev Returns the details of an NFT listing.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT.
     * @return seller The address of the seller.
     * @return price The listing price.
     * @return isListed True if the NFT is listed, false otherwise.
     */
    function getListing(address nftContract, uint256 tokenId) external view returns (address seller, uint256 price, bool isListed);
}