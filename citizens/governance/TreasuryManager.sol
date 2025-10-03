// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TreasuryManager {
    /**
     * @dev Emitted when funds are deposited into the treasury.
     * @param token The address of the token deposited.
     * @param amount The amount of tokens deposited.
     */
    event FundsDeposited(address indexed token, uint256 amount);

    /**
     * @dev Emitted when funds are withdrawn from the treasury.
     * @param token The address of the token withdrawn.
     * @param amount The amount of tokens withdrawn.
     * @param recipient The address receiving the withdrawn funds.
     */
    event FundsWithdrawn(address indexed token, uint256 amount, address indexed recipient);

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
     * @dev Thrown when there are insufficient funds in the treasury for a withdrawal.
     */
    error InsufficientFunds(address token, uint256 requested, uint256 available);

    /**
     * @dev Thrown when an invalid token address is provided.
     */
    error InvalidToken(address token);

    /**
     * @dev Deposits funds into the treasury.
     * @param token The address of the token to deposit.
     * @param amount The amount of tokens to deposit.
     */
    function deposit(address token, uint256 amount) external;

    /**
     * @dev Withdraws funds from the treasury to a specified recipient.
     * @param token The address of the token to withdraw.
     * @param amount The amount of tokens to withdraw.
     * @param recipient The address to send the funds to.
     */
    function withdraw(address token, uint256 amount, address recipient) external;

    /**
     * @dev Returns the balance of a specific token held by the treasury.
     * @param token The address of the token to query.
     * @return balance The amount of the token held in the treasury.
     */
    function getBalance(address token) external view returns (uint256 balance);

    /**
     * @dev Returns the total value of all assets in the treasury, denominated in a base currency.
     * @param baseCurrency The address of the base currency token (e.g., stablecoin).
     * @return totalValue The total value of treasury assets.
     */
    function getTotalValue(address baseCurrency) external view returns (uint256 totalValue);
}