// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenSwap {
    event TokensSwapped(address indexed fromToken, address indexed toToken, address indexed user, uint256 fromAmount, uint256 toAmount);
    event LiquidityAdded(address indexed tokenA, address indexed tokenB, address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed tokenA, address indexed tokenB, address indexed provider, uint256 amountA, uint256 amountB);

    error InvalidTokenPair(address tokenA, address tokenB);
    error InsufficientLiquidity(address token, uint256 requestedAmount, uint256 availableAmount);
    error SlippageExceeded(uint256 actualAmountOut, uint256 minAmountOut);
    error UnauthorizedAccess(address caller);

    function swapTokens(address _fromToken, address _toToken, uint256 _amountIn, uint256 _minAmountOut) external;
    function addLiquidity(address _tokenA, address _tokenB, uint256 _amountA, uint256 _amountB) external;
    function removeLiquidity(address _tokenA, address _tokenB, uint256 _amountLP) external;
    function getAmountOut(uint256 _amountIn, address _tokenIn, address _tokenOut) external view returns (uint256);
    function getReserves(address _tokenA, address _tokenB) external view returns (uint256 reserveA, uint256 reserveB);
}