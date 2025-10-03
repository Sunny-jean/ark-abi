// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModuleFactory {
    /**
     * @dev Emitted when a new module is created by the factory.
     * @param moduleAddress The address of the newly created module contract.
     * @param moduleType The type of the module.
     * @param creator The address that initiated the module creation.
     */
    event ModuleCreated(address indexed moduleAddress, string indexed moduleType, address indexed creator);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when an invalid module type is provided.
     */
    error InvalidModuleType(string moduleType);

    /**
     * @dev Thrown when module creation fails.
     */
    error ModuleCreationFailed(string reason);

    /**
     * @dev Creates a new instance of a specified module type.
     * Only callable by authorized administrators or governance.
     * @param moduleType The type of module to create (e.g., "Policy", "Oracle", "Governance").
     * @param initializationData Data required to initialize the new module contract.
     * @return newModuleAddress The address of the newly deployed module contract.
     */
    function createModule(string calldata moduleType, bytes calldata initializationData) external returns (address newModuleAddress);

    /**
     * @dev Retrieves the address of the template contract for a given module type.
     * @param moduleType The type of module.
     * @return templateAddress The address of the template contract.
     */
    function getModuleTemplate(string calldata moduleType) external view returns (address templateAddress);

    /**
     * @dev Sets the template contract for a specific module type.
     * Only callable by authorized administrators or governance.
     * @param moduleType The type of module.
     * @param templateAddress The address of the template contract.
     */
    function setModuleTemplate(string calldata moduleType, address templateAddress) external;
}