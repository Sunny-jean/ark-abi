// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTTradeExecutor {
    function executeTrade(uint256 _tokenId, address _buyer, uint256 _price) external;
    function setTradeFee(uint256 _fee) external;
    function getTradeFee() external view returns (uint256);

    event TradeExecuted(uint256 indexed tokenId, address indexed buyer, uint256 price);
    event TradeFeeSet(uint256 fee);

    error TradeFailed();
}