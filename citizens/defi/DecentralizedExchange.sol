// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DecentralizedExchange {
    /**
     * @dev Emitted when a swap occurs.
     * @param fromToken The address of the token being swapped from.
     * @param toToken The address of the token being swapped to.
     * @param amountIn The amount of `fromToken` swapped.
     * @param amountOut The amount of `toToken` received.
     * @param user The address of the user who performed the swap.
     */
    event Swap(address indexed fromToken, address indexed toToken, uint256 amountIn, uint256 amountOut, address indexed user);

    /**
     * @dev Emitted when liquidity is added to a pool.
     * @param tokenA The address of the first token in the pair.
     * @param tokenB The address of the second token in the pair.
     * @param amountA The amount of `tokenA` added.
     * @param amountB The amount of `tokenB` added.
     * @param user The address of the user who added liquidity.
     */
    event LiquidityAdded(address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB, address indexed user);

    /**
     * @dev Emitted when liquidity is removed from a pool.
     * @param tokenA The address of the first token in the pair.
     * @param tokenB The address of the second token in the pair.
     * @param amountA The amount of `tokenA` removed.
     * @param amountB The amount of `tokenB` removed.
     * @param user The address of the user who removed liquidity.
     */
    event LiquidityRemoved(address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB, address indexed user);

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
     * @dev Thrown when an unsupported token is used.
     */
    error UnsupportedToken(address token);

    /**
     * @dev Thrown when the swap amount is zero or results in zero output.
     */
    error ZeroAmount();

    /**
     * @dev Thrown when there is insufficient liquidity in the pool for the requested swap.
     */
    error InsufficientLiquidity();

    /**
     * @dev Thrown when the deadline for a transaction has passed.
     */
    error DeadlineExceeded();

    /**
     * @dev Swaps `amountIn` of `fromToken` for `toToken`.
     * @param fromToken The address of the token to swap from.
     * @param toToken The address of the token to swap to.
     * @param amountIn The amount of `fromToken` to swap.
     * @param minAmountOut The minimum amount of `toToken` expected.
     * @param deadline The timestamp by which the transaction must be completed.
     * @return amountOut The actual amount of `toToken` received.
     */
    function swap(address fromToken, address toToken, uint256 amountIn, uint256 minAmountOut, uint256 deadline) external returns (uint256 amountOut);

    /**
     * @dev Adds liquidity to a token pair.
     * @param tokenA The address of the first token.
     * @param tokenB The address of the second token.
     * @param amountA The amount of `tokenA` to add.
     * @param amountB The amount of `tokenB` to add.
     * @param minLiquidity The minimum liquidity tokens expected.
     * @param deadline The timestamp by which the transaction must be completed.
     * @return liquidityTokens The amount of liquidity tokens received.
     */
    function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB, uint256 minLiquidity, uint256 deadline) external returns (uint256 liquidityTokens);

    /**
     * @dev Removes liquidity from a token pair.
     * @param tokenA The address of the first token.
     * @param tokenB The address of the second token.
     * @param liquidityTokens The amount of liquidity tokens to burn.
     * @param minAmountA The minimum amount of `tokenA` expected.
     * @param minAmountB The minimum amount of `tokenB` expected.
     * @param deadline The timestamp by which the transaction must be completed.
     * @return amountA The actual amount of `tokenA` received.
     * @return amountB The actual amount of `tokenB` received.
     */
    function removeLiquidity(address tokenA, address tokenB, uint256 liquidityTokens, uint256 minAmountA, uint256 minAmountB, uint256 deadline) external returns (uint256 amountA, uint256 amountB);

    /**
     * @dev Returns the current price of `tokenA` in terms of `tokenB`.
     * @param tokenA The address of the first token.
     * @param tokenB The address of the second token.
     * @return price The current price.
     */
    function getPrice(address tokenA, address tokenB) external view returns (uint256 price);
}