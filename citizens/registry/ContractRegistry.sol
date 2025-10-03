// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ContractRegistry {
    /**
     * @dev Emitted when a contract is registered.
     */
    event ContractRegistered(string indexed name, address indexed contractAddress);

    /**
     * @dev Emitted when a contract is updated.
     */
    event ContractUpdated(string indexed name, address indexed oldAddress, address indexed newAddress);

    /**
     * @dev Emitted when a contract is removed.
     */
    event ContractRemoved(string indexed name, address indexed contractAddress);

    /**
     * @dev Error when a contract name is not found.
     */
    error ContractNotFound(string name);

    /**
     * @dev Registers a new contract address with a given name.
     * @param name The name to associate with the contract address.
     * @param contractAddress The address of the contract.
     */
    function registerContract(string calldata name, address contractAddress) external;

    /**
     * @dev Updates the address of an existing registered contract.
     * @param name The name of the contract to update.
     * @param newAddress The new address of the contract.
     */
    function updateContract(string calldata name, address newAddress) external;

    /**
     * @dev Removes a registered contract.
     * @param name The name of the contract to remove.
     */
    function removeContract(string calldata name) external;

    /**
     * @dev Retrieves the address of a registered contract by its name.
     * @param name The name of the contract.
     * @return The address of the contract.
     */
    function getContractAddress(string calldata name) external view returns (address);

    /**
     * @dev Checks if a contract name is registered.
     * @param name The name of the contract.
     * @return True if the contract is registered, false otherwise.
     */
    function isContractRegistered(string calldata name) external view returns (bool);
}