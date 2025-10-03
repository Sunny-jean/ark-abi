// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModuleCreatorManager {
    /**
     * @dev Emitted when a new module creator is registered.
     * @param creatorId The unique ID of the creator.
     * @param creatorAddress The address of the creator.
     * @param name The name of the creator.
     */
    event CreatorRegistered(bytes32 indexed creatorId, address indexed creatorAddress, string name);

    /**
     * @dev Emitted when a module creator's profile is updated.
     * @param creatorId The unique ID of the creator.
     * @param newName The new name of the creator.
     */
    event CreatorProfileUpdated(bytes32 indexed creatorId, string newName);

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
     * @dev Thrown when a creator ID already exists.
     */
    error CreatorAlreadyExists(bytes32 creatorId);

    /**
     * @dev Thrown when a creator is not found.
     */
    error CreatorNotFound(bytes32 creatorId);

    /**
     * @dev Registers a new module creator.
     * @param creatorAddress The address of the creator.
     * @param name The name of the creator.
     * @return creatorId The unique ID assigned to the new creator.
     */
    function registerCreator(address creatorAddress, string calldata name) external returns (bytes32 creatorId);

    /**
     * @dev Updates the profile information for an existing module creator.
     * @param creatorId The unique ID of the creator.
     * @param newName The new name for the creator.
     */
    function updateCreatorProfile(bytes32 creatorId, string calldata newName) external;

    /**
     * @dev Retrieves the details of a module creator.
     * @param creatorId The unique ID of the creator.
     * @return creatorAddress The address of the creator.
     * @return name The name of the creator.
     */
    function getCreatorDetails(bytes32 creatorId) external view returns (address creatorAddress, string memory name);
}