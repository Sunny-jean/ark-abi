// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IChainlinkOracle {
    event PriceFeedUpdated(address indexed feedAddress, int256 price, uint256 timestamp);

    error InvalidFeedAddress(address feedAddress);

    function getLatestPrice(address _feedAddress) external view returns (int256);
}