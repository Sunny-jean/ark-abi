// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface FraudDetectionSystem {
    /**
     * @dev Emitted when a suspicious activity is flagged.
     * @param transactionId The ID of the suspicious transaction.
     * @param userAddress The address involved in the suspicious activity.
     * @param reason The reason for flagging.
     * @param severity The severity level of the flag.
     */
    event SuspiciousActivityFlagged(bytes32 indexed transactionId, address indexed userAddress, string reason, uint256 severity);

    /**
     * @dev Emitted when a flagged activity's status is updated.
     * @param transactionId The ID of the transaction.
     * @param newStatus The new status (e.g., "reviewed", "cleared", "confirmed_fraud").
     */
    event FlagStatusUpdated(bytes32 indexed transactionId, string newStatus);

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
     * @dev Thrown when the specified transaction is not found.
     */
    error TransactionNotFound(bytes32 transactionId);

    /**
     * @dev Records a transaction or activity for fraud analysis.
     * @param transactionId The unique ID of the transaction or activity.
     * @param userAddress The primary address involved.
     * @param activityType The type of activity (e.g., "module_purchase", "token_transfer").
     * @param data Additional data relevant for analysis.
     */
    function recordActivity(bytes32 transactionId, address userAddress, string calldata activityType, bytes calldata data) external;

    /**
     * @dev Flags a specific transaction as suspicious.
     * @param transactionId The ID of the transaction to flag.
     * @param reason The reason for flagging (e.g., "unusual_volume", "multiple_failed_attempts").
     * @param severity The severity level (e.g., 1 for low, 5 for critical).
     */
    function flagSuspiciousActivity(bytes32 transactionId, string calldata reason, uint256 severity) external;

    /**
     * @dev Updates the status of a previously flagged activity.
     * @param transactionId The ID of the flagged transaction.
     * @param newStatus The new status (e.g., "reviewed", "cleared", "confirmed_fraud").
     */
    function updateFlagStatus(bytes32 transactionId, string calldata newStatus) external;

    /**
     * @dev Retrieves the fraud status of a given transaction.
     * @param transactionId The ID of the transaction.
     * @return isFlagged True if the transaction is flagged, false otherwise.
     * @return status The current status of the flag.
     * @return reason The reason for the flag.
     * @return severity The severity level.
     */
    function getFraudStatus(bytes32 transactionId) external view returns (bool isFlagged, string memory status, string memory reason, uint256 severity);
}