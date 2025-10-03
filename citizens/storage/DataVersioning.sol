// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DataVersioning {
    /**
     * @dev Emitted when a new version of data is committed.
     * @param dataId The unique ID of the data.
     * @param version The new version number.
     * @param committer The address that committed the new version.
     * @param contentHash The hash of the new version's content.
     */
    event VersionCommitted(bytes32 indexed dataId, uint256 indexed version, address indexed committer, bytes32 contentHash);

    /**
     * @dev Emitted when a specific version of data is retrieved.
     * @param dataId The unique ID of the data.
     * @param version The version number retrieved.
     * @param retriever The address that retrieved the version.
     */
    event VersionRetrieved(bytes32 indexed dataId, uint256 indexed version, address indexed retriever);

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
     * @dev Thrown when data with the given ID is not found.
     */
    error DataNotFound(bytes32 dataId);

    /**
     * @dev Thrown when a specific version of data is not found.
     */
    error VersionNotFound(bytes32 dataId, uint256 version);

    /**
     * @dev Commits a new version of data.
     * @param dataId The unique ID for the data.
     * @param contentHash The hash of the new version's content.
     */
    function commitNewVersion(bytes32 dataId, bytes32 contentHash) external returns (uint256 newVersion);

    /**
     * @dev Retrieves a specific version of data.
     * @param dataId The unique ID for the data.
     * @param version The version number to retrieve.
     * @return contentHash The hash of the content for the specified version.
     * @return committer The address that committed this version.
     * @return timestamp The timestamp when this version was committed.
     */
    function getVersion(bytes32 dataId, uint256 version) external view returns (bytes32 contentHash, address committer, uint256 timestamp);

    /**
     * @dev Retrieves the latest version of data.
     * @param dataId The unique ID for the data.
     * @return latestVersion The latest version number.
     * @return contentHash The hash of the latest version's content.
     */
    function getLatestVersion(bytes32 dataId) external view returns (uint256 latestVersion, bytes32 contentHash);

    /**
     * @dev Retrieves the total number of versions for a given data ID.
     * @param dataId The unique ID for the data.
     * @return totalVersions The total number of versions available.
     */
    function getTotalVersions(bytes32 dataId) external view returns (uint256 totalVersions);
}