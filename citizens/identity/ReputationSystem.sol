// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ReputationSystem {
    /**
     * @dev Emitted when a user's reputation score is updated.
     * @param user The address of the user whose reputation was updated.
     * @param newScore The new reputation score.
     * @param change The change in reputation score.
     */
    event ReputationUpdated(address indexed user, uint256 newScore, int256 change);

    /**
     * @dev Emitted when a reputation event is recorded.
     * @param user The address of the user.
     * @param eventType The type of reputation event.
     * @param scoreImpact The impact of the event on the score.
     */
    event ReputationEventRecorded(address indexed user, string eventType, int256 scoreImpact);

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
     * @dev Thrown when the reputation score would go below zero.
     */
    error NegativeReputationNotAllowed();

    /**
     * @dev Updates a user's reputation score based on an event.
     * @param user The address of the user whose reputation to update.
     * @param eventType A string describing the event (e.g., "module_published", "feedback_received").
     * @param scoreImpact The amount by which the reputation score changes (can be positive or negative).
     */
    function updateReputation(address user, string calldata eventType, int256 scoreImpact) external;

    /**
     * @dev Retrieves the current reputation score of a user.
     * @param user The address of the user to query.
     * @return score The current reputation score of the user.
     */
    function getReputation(address user) external view returns (uint256 score);

    /**
     * @dev Sets the initial reputation score for a new user.
     * @param user The address of the new user.
     * @param initialScore The initial reputation score.
     */
    function setInitialReputation(address user, uint256 initialScore) external;
}