// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TokenSale {
    /**
     * @dev Emitted when tokens are sold.
     */
    event TokensSold(address indexed buyer, uint256 amount, uint256 price);

    /**
     * @dev Emitted when the sale is started.
     */
    event SaleStarted(uint256 startTime, uint256 endTime);

    /**
     * @dev Emitted when the sale is ended.
     */
    event SaleEnded();

    /**
     * @dev Error when the sale is not active.
     */
    error SaleNotActive();

    /**
     * @dev Error when the amount of tokens requested is invalid.
     */
    error InvalidAmount();

    /**
     * @dev Error when insufficient funds are provided.
     */
    error InsufficientFundsProvided();

    /**
     * @dev Buys tokens from the sale.
     * @param amount The amount of tokens to buy.
     */
    function buyTokens(uint256 amount) external payable;

    /**
     * @dev Starts the token sale.
     * @param startTime The start timestamp of the sale.
     * @param endTime The end timestamp of the sale.
     */
    function startSale(uint256 startTime, uint256 endTime) external;

    /**
     * @dev Ends the token sale.
     */
    function endSale() external;

    /**
     * @dev Returns the current price of the token.
     * @return The price of one token.
     */
    function getTokenPrice() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens sold so far.
     * @return The total amount of tokens sold.
     */
    function tokensSold() external view returns (uint256);
}