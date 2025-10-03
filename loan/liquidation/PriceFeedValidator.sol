// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPriceFeedValidator {
    // 清算價格來源驗證
    function validatePrice(address _asset, uint256 _price) external view returns (bool);
    function setPriceFeed(address _asset, address _feedAddress) external;
    function getPriceFeed(address _asset) external view returns (address);

    event PriceFeedSet(address indexed asset, address feedAddress);

    error InvalidPriceFeed();
}