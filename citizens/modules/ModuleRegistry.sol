// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModuleRegistry {
    /**
     * @dev Emitted when a new module is registered.
     * @param moduleId The unique ID of the module.
     * @param moduleAddress The address of the module contract.
     * @param moduleType The type of the module (e.g., "Policy", "Oracle", "Governance").
     */
    event ModuleRegistered(bytes32 indexed moduleId, address indexed moduleAddress, string indexed moduleType);

    /**
     * @dev Emitted when a module is updated.
     * @param moduleId The unique ID of the module.
     * @param newAddress The new address of the module contract.
     */
    event ModuleUpdated(bytes32 indexed moduleId, address indexed newAddress);

    /**
     * @dev Emitted when a module is deregistered.
     * @param moduleId The unique ID of the module.
     */
    event ModuleDeregistered(bytes32 indexed moduleId);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a module with the given ID is not found.
     */
    error ModuleNotFound(bytes32 moduleId);

    /**
     * @dev Thrown when a module with the given ID is already registered.
     */
    error ModuleAlreadyRegistered(bytes32 moduleId);

    /**
     * @dev Registers a new module with its address and type.
     * Only callable by authorized administrators or governance.
     * @param moduleId The unique ID for the module.
     * @param moduleAddress The address of the module contract.
     * @param moduleType The type of the module.
     */
    function registerModule(bytes32 moduleId, address moduleAddress, string calldata moduleType) external;

    /**
     * @dev Updates the address of an existing module.
     * Only callable by authorized administrators or governance.
     * @param moduleId The ID of the module to update.
     * @param newAddress The new address of the module contract.
     */
    function updateModule(bytes32 moduleId, address newAddress) external;

    /**
     * @dev Deregisters a module.
     * Only callable by authorized administrators or governance.
     * @param moduleId The ID of the module to deregister.
     */
    function deregisterModule(bytes32 moduleId) external;

    /**
     * @dev Retrieves the address of a registered module.
     * @param moduleId The ID of the module to query.
     * @return moduleAddress The address of the module contract.
     */
    function getModuleAddress(bytes32 moduleId) external view returns (address moduleAddress);

    /**
     * @dev Retrieves the type of a registered module.
     * @param moduleId The ID of the module to query.
     * @return moduleType The type of the module.
     */
    function getModuleType(bytes32 moduleId) external view returns (string memory moduleType);

    /**
     * @dev Checks if a module is registered.
     * @param moduleId The ID of the module to check.
     * @return isRegistered True if the module is registered, false otherwise.
     */
    function isModuleRegistered(bytes32 moduleId) external view returns (bool isRegistered);
}