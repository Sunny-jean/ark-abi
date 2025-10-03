// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TokenVault {
    /**
     * @dev Emitted when tokens are deposited into the vault.
     */
    event TokensDeposited(address indexed token, address indexed depositor, uint256 amount);

    /**
     * @dev Emitted when tokens are withdrawn from the vault.
     */
    event TokensWithdrawn(address indexed token, address indexed withdrawer, uint256 amount);

    /**
     * @dev Error when an unauthorized address tries to perform an action.
     */
    error UnauthorizedAccess(address caller);

    /**
     * @dev Error when insufficient funds are available for a withdrawal.
     */
    error InsufficientFunds(address token, uint256 requested, uint256 available);

    /**
     * @dev Deposits tokens into the vault.
     * @param token The address of the ERC-20 token to deposit. Use address(0) for native currency.
     * @param amount The amount of tokens to deposit.
     */
    function deposit(address token, uint256 amount) external payable;

    /**
     * @dev Withdraws tokens from the vault.
     * @param token The address of the ERC-20 token to withdraw. Use address(0) for native currency.
     * @param amount The amount of tokens to withdraw.
     * @param recipient The address to send the withdrawn funds to.
     */
    function withdraw(address token, uint256 amount, address recipient) external;

    /**
     * @dev Retrieves the balance of a specific token for a given account in the vault.
     * @param account The address of the account.
     * @param token The address of the ERC-20 token. Use address(0) for native currency.
     * @return The balance of the token for the account.
     */
    function getBalance(address account, address token) external view returns (uint256);
}