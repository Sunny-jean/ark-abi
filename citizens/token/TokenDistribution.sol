// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TokenDistribution {
    /**
     * @dev Emitted when tokens are distributed to a recipient.
     */
    event TokensDistributed(address indexed token, address indexed recipient, uint256 amount);

    /**
     * @dev Emitted when a new distribution schedule is set.
     */
    event DistributionScheduleSet(uint256 startTime, uint256 endTime, uint256 totalAmount);

    /**
     * @dev Error when the distribution period has not started or has ended.
     */
    error InvalidDistributionPeriod();

    /**
     * @dev Error when an unauthorized address tries to distribute tokens.
     */
    error UnauthorizedDistribution(address caller);

    /**
     * @dev Distributes a specified amount of tokens to a recipient.
     * @param token The address of the ERC-20 token to distribute.
     * @param recipient The address to send the tokens to.
     * @param amount The amount of tokens to distribute.
     */
    function distributeTokens(address token, address recipient, uint256 amount) external;

    /**
     * @dev Sets a new token distribution schedule.
     * @param startTime The start timestamp of the distribution.
     * @param endTime The end timestamp of the distribution.
     * @param totalAmount The total amount of tokens to be distributed over the period.
     */
    function setDistributionSchedule(uint256 startTime, uint256 endTime, uint256 totalAmount) external;

    /**
     * @dev Returns the amount of tokens distributed to a recipient.
     * @param recipient The address of the recipient.
     * @return The total amount of tokens distributed to the recipient.
     */
    function getDistributedAmount(address recipient) external view returns (uint256);

    /**
     * @dev Returns the current distribution schedule details.
     * @return startTime The start timestamp.
     * @return endTime The end timestamp.
     * @return totalAmount The total amount to be distributed.
     */
    function getDistributionSchedule() external view returns (uint256 startTime, uint256 endTime, uint256 totalAmount);
}