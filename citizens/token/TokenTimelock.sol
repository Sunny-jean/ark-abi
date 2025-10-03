// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TokenTimelock {
    /**
     * @dev Emitted when tokens are released from the timelock.
     */
    event TokensReleased(address indexed beneficiary, uint256 amount);

    /**
     * @dev Error when tokens are not yet releasable.
     */
    error TokensNotYetReleasable(uint256 releaseTime);

    /**
     * @dev Error when no tokens are available for release.
     */
    error NoTokensToRelease();

    /**
     * @dev Releases the tokens to the beneficiary once the release time has passed.
     */
    function release() external;

    /**
     * @dev Returns the address of the token being held.
     */
    function token() external view returns (address);

    /**
     * @dev Returns the beneficiary of the tokens.
     */
    function beneficiary() external view returns (address);

    /**
     * @dev Returns the time when the tokens are released.
     */
    function releaseTime() external view returns (uint256);
}