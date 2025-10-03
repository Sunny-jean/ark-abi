// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AMLCompliance {
    /**
     * @dev Emitted when a transaction is flagged for AML review.
     * @param transactionId The ID of the transaction.
     * @param reason The reason for flagging.
     * @param timestamp The timestamp when the transaction was flagged.
     */
    event TransactionFlaggedForAML(bytes32 indexed transactionId, string reason, uint256 timestamp);

    /**
     * @dev Emitted when an AML flag is resolved.
     * @param transactionId The ID of the transaction.
     * @param resolution The outcome of the review (e.g., "cleared", "rejected").
     * @param reviewer The address that resolved the flag.
     */
    event AMLFlagResolved(bytes32 indexed transactionId, string resolution, address indexed reviewer);

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
     * @dev Thrown when a transaction is already flagged for AML.
     */
    error TransactionAlreadyFlagged(bytes32 transactionId);

    /**
     * @dev Thrown when attempting to resolve an AML flag for a transaction that is not flagged.
     */
    error TransactionNotFlagged(bytes32 transactionId);

    /**
     * @dev Flags a transaction for AML review.
     * @param transactionId The unique ID of the transaction.
     * @param sender The address of the transaction sender.
     * @param recipient The address of the transaction recipient.
     * @param amount The amount of the transaction.
     * @param reason The reason for flagging the transaction.
     */
    function flagTransactionForAML(bytes32 transactionId, address sender, address recipient, uint256 amount, string calldata reason) external;

    /**
     * @dev Resolves an AML flag for a transaction.
     * Only callable by authorized AML officers.
     * @param transactionId The ID of the transaction.
     * @param resolution The outcome of the review (e.g., "cleared", "rejected", "further_investigation").
     */
    function resolveAMLFlag(bytes32 transactionId, string calldata resolution) external;

    /**
     * @dev Checks the AML status of a transaction.
     * @param transactionId The ID of the transaction.
     * @return isFlagged True if the transaction is flagged, false otherwise.
     * @return reason The reason for flagging, if any.
     * @return resolution The current resolution status, if any.
     */
    function getAMLStatus(bytes32 transactionId) external view returns (bool isFlagged, string memory reason, string memory resolution);

    /**
     * @dev Retrieves a list of all transactions currently flagged for AML review.
     * @return flaggedTransactions An array of transaction IDs that are currently flagged.
     */
    function getPendingAMLFlags() external view returns (bytes32[] memory flaggedTransactions);
}