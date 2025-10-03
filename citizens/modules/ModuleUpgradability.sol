// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModuleUpgradability {
    /**
     * @dev Emitted when a module's implementation is upgraded.
     * @param moduleAddress The address of the proxy module.
     * @param oldImplementation The address of the old implementation contract.
     * @param newImplementation The address of the new implementation contract.
     */
    event ModuleUpgraded(address indexed moduleAddress, address indexed oldImplementation, address indexed newImplementation);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when the new implementation address is invalid (e.g., zero address or not a contract).
     */
    error InvalidNewImplementation(address newImplementation);

    /**
     * @dev Thrown when the upgrade process fails.
     */
    error UpgradeFailed(address moduleAddress, string reason);

    /**
     * @dev Upgrades the implementation contract of a proxy module.
     * Only callable by authorized upgrade managers or governance.
     * @param moduleAddress The address of the proxy module to upgrade.
     * @param newImplementation The address of the new implementation contract.
     * @param data Optional data to be passed to the new implementation's `_initialize` function.
     */
    function upgradeModule(address moduleAddress, address newImplementation, bytes calldata data) external;

    /**
     * @dev Retrieves the current implementation address of a proxy module.
     * @param moduleAddress The address of the proxy module.
     * @return implementationAddress The address of the current implementation contract.
     */
    function getModuleImplementation(address moduleAddress) external view returns (address implementationAddress);

    /**
     * @dev Proposes a new implementation for a module, subject to governance approval.
     * @param moduleAddress The address of the proxy module.
     * @param newImplementation The address of the proposed new implementation contract.
     */
    function proposeUpgrade(address moduleAddress, address newImplementation) external;

    /**
     * @dev Approves a proposed upgrade, allowing it to be executed.
     * @param moduleAddress The address of the proxy module.
     * @param newImplementation The address of the proposed new implementation contract.
     */
    function approveUpgrade(address moduleAddress, address newImplementation) external;
}