// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface FraudDetection {
    /**
     * @dev Emitted when a potential fraudulent activity is detected.
     * @param transactionId The ID of the transaction or activity.
     * @param user The address of the user involved.
     * @param fraudType The type of fraud detected.
     * @param score The fraud score or severity.
     */
    event FraudDetected(bytes32 indexed transactionId, address indexed user, string indexed fraudType, uint256 score);

    /**
     * @dev Emitted when a fraudulent activity is confirmed or resolved.
     * @param transactionId The ID of the transaction or activity.
     * @param status The new status of the fraud alert (e.g., "confirmed", "false_positive", "resolved").
     * @param resolver The address that resolved the alert.
     */
    event FraudStatusUpdated(bytes32 indexed transactionId, string indexed status, address indexed resolver);

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
     * @dev Thrown when a fraud alert with the given ID is not found.
     */
    error FraudAlertNotFound(bytes32 transactionId);

    /**
     * @dev Submits an activity for fraud analysis.
     * @param transactionId The unique ID of the transaction or activity.
     * @param user The address of the user involved.
     * @param activityType The type of activity (e.g., "transfer", "mint", "swap").
     * @param data Additional data related to the activity.
     */
    function analyzeActivity(bytes32 transactionId, address user, string calldata activityType, bytes calldata data) external;

    /**
     * @dev Updates the status of a detected fraud alert.
     * @param transactionId The ID of the transaction or activity.
     * @param status The new status of the fraud alert.
     * @param reason A reason for the status update.
     */
    function updateFraudStatus(bytes32 transactionId, string calldata status, string calldata reason) external;

    /**
     * @dev Retrieves the fraud score for a given transaction or activity.
     * @param transactionId The ID of the transaction or activity.
     * @return fraudType The type of fraud detected.
     * @return score The fraud score or severity.
     * @return status The current status of the fraud alert.
     */
    function getFraudScore(bytes32 transactionId) external view returns (string memory fraudType, uint256 score, string memory status);

    /**
     * @dev Retrieves all pending fraud alerts.
     * @return transactionIds An array of transaction IDs with pending fraud alerts.
     */
    function getPendingFraudAlerts() external view returns (bytes32[] memory transactionIds);
}