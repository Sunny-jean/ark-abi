// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface QualityAssuranceAI {
    /**
     * @dev Emitted when a quality check is performed.
     * @param moduleId The ID of the module checked.
     * @param checkId The unique ID of the check.
     * @param passed True if the check passed, false otherwise.
     */
    event QualityCheckPerformed(bytes32 indexed moduleId, bytes32 indexed checkId, bool passed);

    /**
     * @dev Emitted when a quality standard is updated.
     * @param standardId The ID of the updated standard.
     * @param standardHash A hash of the new standard definition.
     */
    event QualityStandardUpdated(bytes32 indexed standardId, bytes32 standardHash);

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
     * @dev Thrown when the specified module is not found.
     */
    error ModuleNotFound(bytes32 moduleId);

    /**
     * @dev Thrown when a quality check fails.
     */
    error QualityCheckFailed(bytes32 moduleId, string reason);

    /**
     * @dev Initiates an AI-driven quality assurance check for a given module.
     * @param moduleId The unique ID of the module to check.
     * @param checkType The type of quality check to perform (e.g., "code_quality", "security_vulnerability").
     * @param checkData Additional data required for the check.
     * @return checkId The unique ID generated for this quality check.
     */
    function performQualityCheck(bytes32 moduleId, string calldata checkType, bytes calldata checkData) external returns (bytes32 checkId);

    /**
     * @dev Updates the AI's quality standards or rules.
     * @param standardId The unique ID of the standard to update.
     * @param standardDefinition The new definition of the quality standard.
     */
    function updateQualityStandard(bytes32 standardId, bytes calldata standardDefinition) external;

    /**
     * @dev Retrieves the result of a previously performed quality check.
     * @param checkId The unique ID of the quality check.
     * @return passed True if the check passed, false otherwise.
     * @return details A string containing details about the check result.
     */
    function getQualityCheckResult(bytes32 checkId) external view returns (bool passed, string memory details);
}