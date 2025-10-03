// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface GovernanceToken {
    /**
     * @dev Emitted when tokens are minted.
     * @param to The address to which tokens were minted.
     * @param amount The amount of tokens minted.
     */
    event TokensMinted(address indexed to, uint256 amount);

    /**
     * @dev Emitted when tokens are burned.
     * @param from The address from which tokens were burned.
     * @param amount The amount of tokens burned.
     */
    event TokensBurned(address indexed from, uint256 amount);

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
     * @dev Thrown when an attempt is made to mint more tokens than allowed.
     */
    error MintingCapExceeded(uint256 currentSupply, uint256 cap);

    /**
     * @dev Thrown when an attempt is made to burn more tokens than available.
     */
    error InsufficientBalance(uint256 required, uint256 available);

    /**
     * @dev Mints new governance tokens and assigns them to an address.
     * @param to The address to mint tokens to.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) external;

    /**
     * @dev Burns governance tokens from an address.
     * @param from The address to burn tokens from.
     * @param amount The amount of tokens to burn.
     */
    function burn(address from, uint256 amount) external;

    /**
     * @dev Returns the total supply of the governance token.
     * @return totalSupply The total number of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the balance of the governance token for a specific address.
     * @param account The address to query the balance of.
     * @return balance The balance of the account.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Transfers tokens from one address to another.
     * @param to The recipient of the tokens.
     * @param amount The amount of tokens to transfer.
     * @return success True if the transfer was successful, false otherwise.
     */
    function transfer(address to, uint256 amount) external returns (bool success);
}