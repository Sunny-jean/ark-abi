// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface RegulatoryCompliance {
    /**
     * @dev Emitted when a new regulation is added or updated.
     * @param regulationId The unique ID of the regulation.
     * @param jurisdiction The jurisdiction this regulation applies to.
     * @param regulationType The type of regulation (e.g., "data_privacy", "financial_reporting").
     */
    event RegulationUpdated(bytes32 indexed regulationId, string indexed jurisdiction, string indexed regulationType);

    /**
     * @dev Emitted when a system component is marked as compliant or non-compliant with a regulation.
     * @param componentId The ID of the component.
     * @param regulationId The ID of the regulation.
     * @param isCompliant True if compliant, false if non-compliant.
     */
    event ComponentComplianceStatus(bytes32 indexed componentId, bytes32 indexed regulationId, bool isCompliant);

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
     * @dev Thrown when a regulation with the given ID is not found.
     */
    error RegulationNotFound(bytes32 regulationId);

    /**
     * @dev Adds or updates a regulatory requirement.
     * @param regulationId The unique ID for the regulation.
     * @param jurisdiction The jurisdiction this regulation applies to.
     * @param regulationType The type of regulation.
     * @param detailsHash A hash of the regulation details (e.g., IPFS hash of the legal text).
     */
    function addOrUpdateRegulation(bytes32 regulationId, string calldata jurisdiction, string calldata regulationType, bytes32 detailsHash) external;

    /**
     * @dev Sets the compliance status of a system component with respect to a specific regulation.
     * @param componentId The ID of the component (e.g., "UserRegistry", "YieldAggregator").
     * @param regulationId The ID of the regulation.
     * @param isCompliant True if the component is compliant, false otherwise.
     */
    function setComponentCompliance(bytes32 componentId, bytes32 regulationId, bool isCompliant) external;

    /**
     * @dev Checks the compliance status of a component against a specific regulation.
     * @param componentId The ID of the component.
     * @param regulationId The ID of the regulation.
     * @return isCompliant True if the component is compliant, false otherwise.
     */
    function isComponentCompliant(bytes32 componentId, bytes32 regulationId) external view returns (bool isCompliant);

    /**
     * @dev Retrieves the details of a regulatory requirement.
     * @param regulationId The ID of the regulation.
     * @return jurisdiction The jurisdiction.
     * @return regulationType The type of regulation.
     * @return detailsHash The hash of the regulation details.
     */
    function getRegulationDetails(bytes32 regulationId) external view returns (string memory jurisdiction, string memory regulationType, bytes32 detailsHash);

    /**
     * @dev Retrieves a list of all regulations applicable to a given jurisdiction.
     * @param jurisdiction The jurisdiction to query.
     * @return regulationIds An array of regulation IDs.
     */
    function getRegulationsByJurisdiction(string calldata jurisdiction) external view returns (bytes32[] memory regulationIds);
}