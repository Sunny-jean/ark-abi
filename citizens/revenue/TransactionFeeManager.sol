// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TransactionFeeManager {
    /**
     * @dev Emitted when a transaction fee is collected.
     * @param transactionId The unique ID of the transaction.
     * @param feeAmount The amount of fee collected.
     * @param currency The currency of the fee.
     */
    event FeeCollected(bytes32 indexed transactionId, uint256 feeAmount, address indexed currency);

    /**
     * @dev Emitted when a fee rate is updated.
     * @param feeType The type of fee.
     * @param newRate The new fee rate.
     */
    event FeeRateUpdated(string indexed feeType, uint256 newRate);

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
     * @dev Thrown when the specified fee type is not found.
     */
    error FeeTypeNotFound(string feeType);

    /**
     * @dev Thrown when fee collection fails.
     */
    error FeeCollectionFailed(bytes32 transactionId, string reason);

    /**
     * @dev Collects a transaction fee for a given transaction.
     * @param transactionId The unique ID of the transaction.
     * @param amount The total amount of the transaction.
     * @param currency The address of the ERC-20 token for the transaction.
     * @return collectedFee The amount of fee collected.
     */
    function collectFee(bytes32 transactionId, uint256 amount, address currency) external returns (uint256 collectedFee);

    /**
     * @dev Updates the fee rate for a specific type of transaction.
     * @param feeType The type of fee (e.g., "module_sale", "subscription").
     * @param rateBps The new fee rate in basis points (e.g., 500 for 5%).
     */
    function updateFeeRate(string calldata feeType, uint256 rateBps) external;

    /**
     * @dev Retrieves the current fee rate for a specific type of fee.
     * @param feeType The type of fee.
     * @return rateBps The fee rate in basis points.
     */
    function getFeeRate(string calldata feeType) external view returns (uint256 rateBps);
}