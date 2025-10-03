// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ReputationSystem {
    /**
     * @dev Emitted when a user's reputation score is updated.
     * @param user The address of the user whose reputation was updated.
     * @param newScore The user's new reputation score.
     * @param reason A string describing the reason for the update (e.g., "post_liked", "transaction_completed").
     */
    event ReputationUpdated(address indexed user, int256 newScore, string reason);

    /**
     * @dev Emitted when a reputation event type is defined.
     * @param eventType The unique identifier for the event type.
     * @param scoreChange The amount of score change associated with this event.
     * @param cooldownPeriod The cooldown period for this event type.
     */
    event ReputationEventTypeDefined(bytes32 indexed eventType, int256 scoreChange, uint256 cooldownPeriod);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a reputation event type is not found.
     */
    error EventTypeNotFound(bytes32 eventType);

    /**
     * @dev Thrown when a user attempts to trigger a reputation event before its cooldown period has passed.
     */
    error OnCooldown(address user, bytes32 eventType, uint256 timeLeft);

    /**
     * @dev Defines a new type of event that affects reputation.
     * Only callable by authorized administrators.
     * @param eventType The unique identifier for this event type (e.g., "post_liked", "transaction_completed").
     * @param scoreChange The amount by which reputation changes for this event (can be positive or negative).
     * @param cooldownPeriod The minimum time (in seconds) before the same user can trigger this event again.
     */
    function defineReputationEventType(bytes32 eventType, int256 scoreChange, uint256 cooldownPeriod) external;

    /**
     * @dev Records a reputation-affecting event for a user.
     * Only callable by authorized contracts or administrators.
     * @param user The address of the user whose reputation is affected.
     * @param eventType The type of event that occurred.
     */
    function recordReputationEvent(address user, bytes32 eventType) external;

    /**
     * @dev Retrieves a user's current reputation score.
     * @param user The address of the user to query.
     * @return score The user's current reputation score.
     */
    function getReputationScore(address user) external view returns (int256 score);

    /**
     * @dev Retrieves the details of a defined reputation event type.
     * @param eventType The ID of the event type to query.
     * @return scoreChange The score change associated with this event.
     * @return cooldownPeriod The cooldown period for this event type.
     */
    function getReputationEventTypeDetails(bytes32 eventType) external view returns (int256 scoreChange, uint256 cooldownPeriod);
}