// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TokenDistribution {
    /**
     * @dev Emitted when a token distribution campaign is initiated.
     * @param campaignId The unique ID of the distribution campaign.
     * @param token The address of the token being distributed.
     * @param totalAmount The total amount of tokens to be distributed.
     * @param startTime The timestamp when the distribution starts.
     * @param endTime The timestamp when the distribution ends.
     */
    event DistributionInitiated(bytes32 indexed campaignId, address indexed token, uint256 totalAmount, uint256 startTime, uint256 endTime);

    /**
     * @dev Emitted when tokens are claimed by a recipient.
     * @param campaignId The ID of the distribution campaign.
     * @param recipient The address that claimed the tokens.
     * @param amount The amount of tokens claimed.
     */
    event TokensClaimed(bytes32 indexed campaignId, address indexed recipient, uint256 amount);

    /**
     * @dev Emitted when a distribution campaign is paused or resumed.
     * @param campaignId The ID of the distribution campaign.
     * @param paused True if paused, false if resumed.
     */
    event DistributionPaused(bytes32 indexed campaignId, bool paused);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a distribution campaign with the given ID is not found.
     */
    error CampaignNotFound(bytes32 campaignId);

    /**
     * @dev Thrown when the distribution is not active (e.g., not started, ended, or paused).
     */
    error DistributionNotActive();

    /**
     * @dev Thrown when a recipient attempts to claim more tokens than allocated or available.
     */
    error InsufficientClaimableAmount();

    /**
     * @dev Struct representing a token distribution campaign.
     */
    struct ClaimedAmount {
        address recipient;
        uint256 amount;
    }

    struct Allocation {
        address recipient;
        uint256 amount;
    }

    struct DistributionCampaign {
        address token;
        uint256 totalAmount;
        uint256 startTime;
        uint256 endTime;
        bool paused;
        ClaimedAmount[] claimedAmounts;
        Allocation[] allocations;
    }

    /**
     * @dev Initiates a new token distribution campaign.
     * Only callable by authorized governance or distribution managers.
     * @param token The address of the token to distribute.
     * @param totalAmount The total amount of tokens to distribute.
     * @param startTime The timestamp when the distribution starts.
     * @param endTime The timestamp when the distribution ends.
     * @return campaignId The unique ID for the distribution campaign.
     */
    function initiateDistribution(address token, uint256 totalAmount, uint256 startTime, uint256 endTime) external returns (bytes32 campaignId);

    /**
     * @dev Sets the allocation for a specific recipient in a distribution campaign.
     * Only callable by authorized governance or distribution managers.
     * @param campaignId The ID of the distribution campaign.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens allocated to the recipient.
     */
    function setAllocation(bytes32 campaignId, address recipient, uint256 amount) external;

    /**
     * @dev Allows a recipient to claim their allocated tokens from a distribution campaign.
     * @param campaignId The ID of the distribution campaign.
     */
    function claimTokens(bytes32 campaignId) external;

    /**
     * @dev Pauses or resumes a token distribution campaign.
     * Only callable by authorized governance or distribution managers.
     * @param campaignId The ID of the distribution campaign.
     * @param pause True to pause, false to resume.
     */
    function pauseDistribution(bytes32 campaignId, bool pause) external;

    /**
     * @dev Retrieves the details of a specific distribution campaign.
     * @param campaignId The ID of the distribution campaign.
     * @return campaign The DistributionCampaign struct containing all details.
     */
    function getDistributionCampaign(bytes32 campaignId) external view returns (DistributionCampaign memory campaign);

    /**
     * @dev Retrieves the claimable amount for a recipient in a distribution campaign.
     * @param campaignId The ID of the distribution campaign.
     * @param recipient The address of the recipient.
     * @return claimableAmount The amount of tokens the recipient can claim.
     */
    function getClaimableAmount(bytes32 campaignId, address recipient) external view returns (uint256 claimableAmount);
}