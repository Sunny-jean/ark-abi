// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TreasuryManagement {
    /**
     * @dev Emitted when funds are deposited into the treasury.
     * @param token The address of the token deposited (or address(0) for native currency).
     * @param amount The amount deposited.
     * @param depositor The address that deposited the funds.
     */
    event FundsDeposited(address indexed token, uint256 amount, address indexed depositor);

    /**
     * @dev Emitted when funds are withdrawn from the treasury.
     * @param token The address of the token withdrawn (or address(0) for native currency).
     * @param amount The amount withdrawn.
     * @param recipient The address that received the funds.
     */
    event FundsWithdrawn(address indexed token, uint256 amount, address indexed recipient);

    /**
     * @dev Emitted when a new investment is made from the treasury.
     * @param investmentId The unique ID of the investment.
     * @param token The address of the token invested.
     * @param amount The amount invested.
     * @param strategy The address of the investment strategy contract.
     */
    event InvestmentMade(bytes32 indexed investmentId, address indexed token, uint256 amount, address indexed strategy);

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
     * @dev Thrown when there are insufficient funds in the treasury for a withdrawal or investment.
     */
    error InsufficientFunds(address token, uint256 requested, uint256 available);

    /**
     * @dev Thrown when an investment with the given ID is not found.
     */
    error InvestmentNotFound(bytes32 investmentId);

    /**
     * @dev Deposits funds into the treasury.
     * @param token The address of the token to deposit (address(0) for native currency).
     * @param amount The amount of tokens to deposit.
     */
    function depositFunds(address token, uint256 amount) external payable;

    /**
     * @dev Withdraws funds from the treasury.
     * @param token The address of the token to withdraw (address(0) for native currency).
     * @param amount The amount of tokens to withdraw.
     * @param recipient The address to send the withdrawn funds to.
     */
    function withdrawFunds(address token, uint256 amount, address recipient) external;

    /**
     * @dev Makes an investment from the treasury into a specified strategy.
     * @param token The address of the token to invest.
     * @param amount The amount of tokens to invest.
     * @param strategy The address of the investment strategy contract.
     * @return investmentId The unique ID of the created investment.
     */
    function makeInvestment(address token, uint256 amount, address strategy) external returns (bytes32 investmentId);

    /**
     * @dev Retrieves the balance of a specific token in the treasury.
     * @param token The address of the token (address(0) for native currency).
     * @return balance The balance of the token.
     */
    function getTreasuryBalance(address token) external view returns (uint256 balance);

    /**
     * @dev Retrieves the details of an ongoing investment.
     * @param investmentId The unique ID of the investment.
     * @return token The address of the token invested.
     * @return amount The amount invested.
     * @return strategy The address of the investment strategy contract.
     * @return isActive True if the investment is still active, false otherwise.
     */
    function getInvestmentDetails(bytes32 investmentId) external view returns (address token, uint256 amount, address strategy, bool isActive);
}