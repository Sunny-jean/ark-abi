// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface SanctionList {
    /**
     * @dev Emitted when an address is added to the sanction list.
     * @param sanctionedAddress The address that was sanctioned.
     * @param reason The reason for sanctioning.
     * @param timestamp The timestamp when the address was added.
     */
    event AddressSanctioned(address indexed sanctionedAddress, string reason, uint256 timestamp);

    /**
     * @dev Emitted when an address is removed from the sanction list.
     * @param unsanctionedAddress The address that was unsanctioned.
     * @param reason The reason for unsanctioning.
     * @param timestamp The timestamp when the address was removed.
     */
    event AddressUnsanctioned(address indexed unsanctionedAddress, string reason, uint256 timestamp);

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
     * @dev Thrown when attempting to sanction an address that is already sanctioned.
     */
    error AddressAlreadySanctioned(address sanctionedAddress);

    /**
     * @dev Thrown when attempting to unsanction an address that is not sanctioned.
     */
    error AddressNotSanctioned(address unsanctionedAddress);

    /**
     * @dev Adds an address to the sanction list.
     * @param _address The address to sanction.
     * @param reason The reason for sanctioning this address.
     */
    function sanctionAddress(address _address, string calldata reason) external;

    /**
     * @dev Removes an address from the sanction list.
     * @param _address The address to unsanction.
     * @param reason The reason for unsanctioning this address.
     */
    function unsanctionAddress(address _address, string calldata reason) external;

    /**
     * @dev Checks if an address is currently on the sanction list.
     * @param _address The address to check.
     * @return isSanctioned True if the address is sanctioned, false otherwise.
     */
    function isSanctioned(address _address) external view returns (bool isSanctioned);

    /**
     * @dev Retrieves the reason an address was sanctioned.
     * @param _address The sanctioned address.
     * @return reason The reason for sanctioning.
     */
    function getSanctionReason(address _address) external view returns (string memory reason);

    /**
     * @dev Retrieves all sanctioned addresses.
     * @return sanctionedAddresses An array of all addresses currently on the sanction list.
     */
    function getAllSanctionedAddresses() external view returns (address[] memory sanctionedAddresses);
}