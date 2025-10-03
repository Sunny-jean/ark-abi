// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Vesting {
    /**
     * @dev Emitted when a new vesting schedule is created.
     */
    event VestingScheduleCreated(address indexed beneficiary, uint256 startTime, uint256 endTime, uint256 totalAmount);

    /**
     * @dev Emitted when vested tokens are released.
     */
    event TokensReleased(address indexed beneficiary, uint256 amount);

    /**
     * @dev Error when no tokens are available for vesting.
     */
    error NoTokensToVest();

    /**
     * @dev Error when no tokens are available for release.
     */
    error NoTokensToRelease();

    /**
     * @dev Creates a new vesting schedule for a beneficiary.
     * @param beneficiary The address of the beneficiary.
     * @param startTime The start timestamp of the vesting period.
     * @param endTime The end timestamp of the vesting period.
     * @param totalAmount The total amount of tokens to vest.
     */
    function createVestingSchedule(address beneficiary, uint256 startTime, uint256 endTime, uint256 totalAmount) external;

    /**
     * @dev Releases vested tokens to the beneficiary.
     */
    function release() external;

    /**
     * @dev Returns the amount of tokens vested for a beneficiary at a given timestamp.
     * @param beneficiary The address of the beneficiary.
     * @param timestamp The timestamp to query.
     * @return The amount of vested tokens.
     */
    function vestedAmount(address beneficiary, uint256 timestamp) external view returns (uint256);

    /**
     * @dev Returns the amount of tokens already released to a beneficiary.
     * @param beneficiary The address of the beneficiary.
     * @return The amount of released tokens.
     */
    function releasedAmount(address beneficiary) external view returns (uint256);

    /**
     * @dev Returns the total amount of tokens in a vesting schedule for a beneficiary.
     * @param beneficiary The address of the beneficiary.
     * @return The total amount of tokens.
     */
    function totalVestingAmount(address beneficiary) external view returns (uint256);
}