// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface GameAssetManager {
    /**
     * @dev Emitted when a new game asset is minted.
     * @param assetId The unique ID of the minted asset.
     * @param owner The address of the asset owner.
     * @param metadataURI The URI pointing to the asset's metadata.
     */
    event AssetMinted(uint256 indexed assetId, address indexed owner, string metadataURI);

    /**
     * @dev Emitted when a game asset is transferred.
     * @param assetId The unique ID of the transferred asset.
     * @param from The address from which the asset was transferred.
     * @param to The address to which the asset was transferred.
     */
    event AssetTransferred(uint256 indexed assetId, address indexed from, address indexed to);

    /**
     * @dev Emitted when a game asset's properties are updated.
     * @param assetId The unique ID of the updated asset.
     * @param updater The address that updated the asset.
     */
    event AssetPropertiesUpdated(uint256 indexed assetId, address indexed updater);

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
     * @dev Thrown when a game asset with the given ID does not exist.
     */
    error AssetNotFound(uint256 assetId);

    /**
     * @dev Thrown when the caller is not the owner of the asset.
     */
    error NotAssetOwner();

    /**
     * @dev Mints a new game asset and assigns it to an owner.
     * @param owner The address to assign the new asset to.
     * @param metadataURI The URI pointing to the asset's metadata.
     * @return assetId The unique ID of the newly minted asset.
     */
    function mintAsset(address owner, string calldata metadataURI) external returns (uint256 assetId);

    /**
     * @dev Transfers a game asset from one address to another.
     * @param from The address from which to transfer the asset.
     * @param to The address to which to transfer the asset.
     * @param assetId The unique ID of the asset to transfer.
     */
    function transferAsset(address from, address to, uint256 assetId) external;

    /**
     * @dev Updates the metadata URI of an existing game asset.
     * @param assetId The unique ID of the asset to update.
     * @param newMetadataURI The new URI pointing to the asset's metadata.
     */
    function updateAssetMetadata(uint256 assetId, string calldata newMetadataURI) external;

    /**
     * @dev Returns the owner of a specific game asset.
     * @param assetId The unique ID of the asset.
     * @return owner The address of the asset's owner.
     */
    function getAssetOwner(uint256 assetId) external view returns (address owner);

    /**
     * @dev Returns the metadata URI of a specific game asset.
     * @param assetId The unique ID of the asset.
     * @return metadataURI The URI pointing to the asset's metadata.
     */
    function getAssetMetadataURI(uint256 assetId) external view returns (string memory metadataURI);
}