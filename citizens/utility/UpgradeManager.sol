// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface UpgradeManager {
    /**
     * @dev Emitted when a new implementation is proposed for upgrade.
     * @param newImplementation The address of the new implementation contract.
     * @param proposer The address that proposed the upgrade.
     */
    event UpgradeProposed(address indexed newImplementation, address indexed proposer);

    /**
     * @dev Emitted when an upgrade is approved and activated.
     * @param newImplementation The address of the new implementation contract.
     * @param activator The address that activated the upgrade.
     */
    event UpgradeActivated(address indexed newImplementation, address indexed activator);

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
     * @dev Thrown when an upgrade is proposed that is identical to the current implementation.
     */
    error NoChangeInImplementation();

    /**
     * @dev Thrown when an upgrade is attempted without a pending proposal.
     */
    error NoPendingUpgrade();

    /**
     * @dev Proposes a new implementation contract for an upgrade.
     * @param newImplementation The address of the new implementation contract.
     */
    function proposeUpgrade(address newImplementation) external;

    /**
     * @dev Activates a proposed upgrade, switching the proxy to the new implementation.
     */
    function activateUpgrade() external;

    /**
     * @dev Retrieves the address of the current implementation contract.
     * @return currentImplementation The address of the current implementation.
     */
    function getCurrentImplementation() external view returns (address currentImplementation);

    /**
     * @dev Retrieves the address of the pending proposed implementation contract.
     * @return pendingImplementation The address of the pending implementation, or address(0) if none.
     */
    function getPendingImplementation() external view returns (address pendingImplementation);
}