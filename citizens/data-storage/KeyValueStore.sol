// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface KeyValueStore {
    /**
     * @dev Emitted when a key-value pair is set.
     */
    event ValueSet(bytes32 indexed key, bytes value);

    /**
     * @dev Emitted when a key-value pair is deleted.
     */
    event ValueDeleted(bytes32 indexed key);

    /**
     * @dev Error when a key is not found.
     */
    error KeyNotFound(bytes32 key);

    /**
     * @dev Sets a value for a given key.
     * @param key The key to set.
     * @param value The value to store.
     */
    function set(bytes32 key, bytes calldata value) external;

    /**
     * @dev Retrieves the value for a given key.
     * @param key The key to retrieve.
     * @return The stored value.
     */
    function get(bytes32 key) external view returns (bytes memory);

    /**
     * @dev Deletes a key-value pair.
     * @param key The key to delete.
     */
    function del(bytes32 key) external;

    /**
     * @dev Checks if a key exists in the store.
     * @param key The key to check.
     * @return True if the key exists, false otherwise.
     */
    function exists(bytes32 key) external view returns (bool);
}