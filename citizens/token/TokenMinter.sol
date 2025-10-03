// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TokenMinter {
    /**
     * @dev Emitted when new tokens are minted.
     */
    event TokensMinted(address indexed minter, address indexed token, uint256 amount);

    /**
     * @dev Error when an unauthorized address tries to mint tokens.
     */
    error UnauthorizedMint(address caller);

    /**
     * @dev Mints a specified amount of tokens to a recipient.
     * Only callable by authorized minters.
     * @param token The address of the ERC-20 token to mint.
     * @param to The address to mint tokens to.
     * @param amount The amount of tokens to mint.
     */
    function mint(address token, address to, uint256 amount) external;
}