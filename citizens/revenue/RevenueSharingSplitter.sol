// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface RevenueSharingSplitter {
    /**
     * @dev Emitted when revenue is distributed to participants.
     * @param revenueId The unique ID of the revenue event.
     * @param totalAmount The total amount of revenue distributed.
     * @param currency The address of the currency token.
     */
    event RevenueDistributed(bytes32 indexed revenueId, uint256 totalAmount, address indexed currency);

    /**
     * @dev Emitted when a participant's share is updated.
     * @param participant The address of the participant.
     * @param newShare The new share percentage (e.g., 1000 for 10%).
     */
    event ShareUpdated(address indexed participant, uint256 newShare);

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
     * @dev Thrown when the total shares exceed 100%.
     */
    error TotalSharesExceeded();

    /**
     * @dev Thrown when a participant is not found.
     */
    error ParticipantNotFound(address participant);

    /**
     * @dev Distributes a given amount of revenue among predefined participants based on their shares.
     * @param amount The total amount of revenue to distribute.
     * @param currency The address of the ERC-20 token representing the currency.
     * @return distributedAmount The actual amount distributed.
     */
    function distributeRevenue(uint256 amount, address currency) external returns (uint256 distributedAmount);

    /**
     * @dev Updates the share percentage for a specific participant.
     * @param participant The address of the participant.
     * @param shareBps The new share in basis points (e.g., 1000 for 10%).
     */
    function updateParticipantShare(address participant, uint256 shareBps) external;

    /**
     * @dev Retrieves the current share of a participant.
     * @param participant The address of the participant.
     * @return shareBps The share in basis points.
     */
    function getParticipantShare(address participant) external view returns (uint256 shareBps);
}