// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface RoyaltyManagement {
    /**
     * @dev Emitted when royalty information for a content ID is set or updated.
     * @param contentId The unique ID of the content.
     * @param recipient The address receiving the royalty.
     * @param percentage The percentage of sales/revenue allocated as royalty.
     */
    event RoyaltyInfoSet(bytes32 indexed contentId, address indexed recipient, uint256 percentage);

    /**
     * @dev Emitted when royalties are paid out.
     * @param contentId The unique ID of the content.
     * @param payer The address that paid the royalties.
     * @param recipient The address that received the royalties.
     * @param amount The amount of royalties paid.
     * @param token The token in which royalties were paid.
     */
    event RoyaltyPaid(bytes32 indexed contentId, address indexed payer, address indexed recipient, uint256 amount, address token);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when content with the given ID is not found.
     */
    error ContentNotFound(bytes32 contentId);

    /**
     * @dev Thrown when an invalid royalty percentage is provided (e.g., > 100%).
     */
    error InvalidRoyaltyPercentage(uint256 percentage);

    /**
     * @dev Sets or updates the royalty information for a specific piece of content.
     * Only callable by the content owner or an authorized manager.
     * @param contentId The unique ID of the content.
     * @param recipient The address that will receive the royalties.
     * @param percentage The percentage of sales/revenue to be paid as royalty (e.g., 500 for 5%).
     */
    function setRoyaltyInfo(bytes32 contentId, address recipient, uint256 percentage) external;

    /**
     * @dev Records a royalty payment for a piece of content.
     * This function is typically called by a marketplace or platform after a sale.
     * @param contentId The unique ID of the content.
     * @param payer The address that made the payment (e.g., buyer).
     * @param amount The total amount of the sale/revenue from which royalties are calculated.
     * @param token The address of the token in which the sale occurred.
     */
    function recordRoyaltyPayment(bytes32 contentId, address payer, uint256 amount, address token) external;

    /**
     * @dev Retrieves the royalty information for a specific piece of content.
     * @param contentId The unique ID of the content.
     * @return recipient The address receiving the royalty.
     * @return percentage The percentage of sales/revenue allocated as royalty.
     */
    function getRoyaltyInfo(bytes32 contentId) external view returns (address recipient, uint256 percentage);

    /**
     * @dev Retrieves the total accumulated royalties for a specific content ID and token.
     * @param contentId The unique ID of the content.
     * @param token The address of the token.
     * @return totalRoyalties The total amount of royalties accumulated.
     */
    function getAccumulatedRoyalties(bytes32 contentId, address token) external view returns (uint256 totalRoyalties);
}