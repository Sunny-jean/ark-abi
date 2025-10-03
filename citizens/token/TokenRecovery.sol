// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TokenRecovery {
    /**
     * @dev Emitted when tokens are recovered.
     */
    event TokensRecovered(address indexed token, uint256 amount);

    /**
     * @dev Error when an unauthorized address tries to recover tokens.
     */
    error UnauthorizedRecovery(address caller);

    /**
     * @dev Recovers accidentally sent ERC20 tokens from the contract.
     * Only callable by authorized addresses.
     * @param token The address of the ERC-20 token to recover.
     * @param amount The amount of tokens to recover.
     */
    function recoverERC20(address token, uint256 amount) external;

    /**
     * @dev Recovers accidentally sent native currency from the contract.
     * Only callable by authorized addresses.
     * @param amount The amount of native currency to recover.
     */
    function recoverNative(uint256 amount) external;
}