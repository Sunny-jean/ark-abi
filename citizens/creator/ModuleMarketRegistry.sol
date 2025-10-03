// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModuleMarketRegistry {
    /**
     * @dev Emitted when a module is listed on the market.
     * @param moduleId The unique ID of the module.
     * @param listingId The unique ID of the market listing.
     * @param price The listing price.
     * @param currency The currency of the listing.
     */
    event ModuleListed(bytes32 indexed moduleId, bytes32 indexed listingId, uint256 price, address indexed currency);

    /**
     * @dev Emitted when a module listing is updated.
     * @param listingId The unique ID of the market listing.
     * @param newPrice The new listing price.
     */
    event ModuleListingUpdated(bytes32 indexed listingId, uint256 newPrice);

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
     * @dev Thrown when the specified module is already listed.
     */
    error ModuleAlreadyListed(bytes32 moduleId);

    /**
     * @dev Thrown when a listing is not found.
     */
    error ListingNotFound(bytes32 listingId);

    /**
     * @dev Lists a module on the market for sale or subscription.
     * @param moduleId The unique ID of the module to list.
     * @param price The price of the module.
     * @param currency The address of the ERC-20 token used as currency.
     * @param listingDetails Additional details about the listing.
     * @return listingId The unique ID of the created listing.
     */
    function listModule(bytes32 moduleId, uint256 price, address currency, bytes calldata listingDetails) external returns (bytes32 listingId);

    /**
     * @dev Updates an existing module listing.
     * @param listingId The unique ID of the listing to update.
     * @param newPrice The new price for the module.
     */
    function updateListing(bytes32 listingId, uint256 newPrice) external;

    /**
     * @dev Retrieves the details of a module listing.
     * @param listingId The unique ID of the listing.
     * @return moduleId The ID of the listed module.
     * @return price The price of the module.
     * @return currency The currency of the listing.
     * @return isActive True if the listing is active, false otherwise.
     */
    function getListingDetails(bytes32 listingId) external view returns (bytes32 moduleId, uint256 price, address currency, bool isActive);
}