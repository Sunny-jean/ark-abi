// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUniswapTWAPOracle {
    event TWAPUpdated(address indexed tokenA, address indexed tokenB, uint256 twapPrice, uint256 timestamp);

    error InvalidPair(address tokenA, address tokenB);

    function getTWAP(address _tokenA, address _tokenB, uint32 _period) external view returns (uint256);
}