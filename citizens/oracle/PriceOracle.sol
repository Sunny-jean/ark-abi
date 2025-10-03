// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface PriceOracle {
    /**
     * @dev Emitted when a new price is updated for a specific asset.
     * @param asset The address of the asset.
     * @param price The new price of the asset (scaled by decimals).
     * @param timestamp The timestamp when the price was updated.
     */
    event PriceUpdated(address indexed asset, uint256 price, uint256 timestamp);

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
     * @dev Thrown when price data for a given asset is not available.
     */
    error PriceDataNotAvailable(address asset);

    /**
     * @dev Returns the latest price of a given asset.
     * @param asset The address of the asset.
     * @return price The price of the asset, scaled by the oracle's decimals.
     */
    function getLatestPrice(address asset) external view returns (uint256 price);

    /**
     * @dev Returns the decimals used by the oracle for price representation.
     * @return decimals The number of decimal places.
     */
    function getDecimals() external view returns (uint8 decimals);

    /**
     * @dev Returns the description of the price feed.
     * @return description The description string.
     */
    function getDescription() external view returns (string memory description);

    /**
     * @dev Returns the version of the price feed.
     * @return version The version number.
     */
    function getVersion() external view returns (uint256 version);
}