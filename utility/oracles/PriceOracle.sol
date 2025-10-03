// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPriceOracle {
    event PriceUpdated(string indexed symbol, uint256 price, uint256 timestamp);

    error PriceNotFound(string symbol);
    error UnauthorizedUpdater(address caller);

    function getPrice(string memory _symbol) external view returns (uint256);
    function setPrice(string memory _symbol, uint256 _price) external;
}