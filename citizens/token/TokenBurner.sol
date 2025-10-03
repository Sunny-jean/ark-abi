// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TokenBurner {
    /**
     * @dev Emitted when tokens are burned.
     */
    event TokensBurned(address indexed burner, address indexed token, uint256 amount);

    /**
     * @dev Error when an unauthorized address tries to burn tokens.
     */
    error UnauthorizedBurn(address caller);

    /**
     * @dev Burns a specified amount of tokens from the caller's balance.
     * @param token The address of the ERC-20 token to burn.
     * @param amount The amount of tokens to burn.
     */
    function burn(address token, uint256 amount) external;

    /**
     * @dev Burns a specified amount of tokens from a specific address's balance.
     * Only callable by authorized burners.
     * @param token The address of the ERC-20 token to burn.
     * @param from The address from which tokens will be burned.
     * @param amount The amount of tokens to burn.
     */
    function burnFrom(address token, address from, uint256 amount) external;
}