// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AuditTrail {
    /**
     * @dev Emitted when an auditable action occurs.
     * @param actor The address that performed the action.
     * @param actionType A string describing the type of action (e.g., "deposit", "withdraw", "vote").
     * @param entityId An optional ID of the entity affected by the action (e.g., user ID, proposal ID).
     * @param detailsHash A hash of additional details about the action (e.g., IPFS hash of transaction data).
     * @param timestamp The timestamp when the action occurred.
     */
    event ActionLogged(address indexed actor, string indexed actionType, bytes32 indexed entityId, bytes32 detailsHash, uint256 timestamp);

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
     * @dev Logs an auditable action.
     * @param actionType A string describing the type of action.
     * @param entityId An optional ID of the entity affected.
     * @param detailsHash A hash of additional details.
     */
    function logAction(string calldata actionType, bytes32 entityId, bytes32 detailsHash) external;

    /**
     * @dev Retrieves a list of actions performed by a specific actor.
     * @param actor The address of the actor.
     * @return logs An array of ActionLog structs.
     */
    function getActionsByActor(address actor) external view returns (ActionLog[] memory logs);

    /**
     * @dev Retrieves a list of actions of a specific type.
     * @param actionType The type of action.
     * @return logs An array of ActionLog structs.
     */
    function getActionsByType(string calldata actionType) external view returns (ActionLog[] memory logs);

    /**
     * @dev Retrieves a list of actions related to a specific entity.
     * @param entityId The ID of the entity.
     * @return logs An array of ActionLog structs.
     */
    function getActionsByEntity(bytes32 entityId) external view returns (ActionLog[] memory logs);

    /**
     * @dev Struct representing a logged action.
     */
    struct ActionLog {
        address actor;
        string actionType;
        bytes32 entityId;
        bytes32 detailsHash;
        uint256 timestamp;
    }
}