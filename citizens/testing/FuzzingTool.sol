// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface FuzzingTool {
    /**
     * @dev Emitted when a fuzzing campaign starts.
     * @param campaignId The unique ID of the fuzzing campaign.
     * @param targetContract The address of the contract being fuzzed.
     * @param duration The duration of the fuzzing campaign in seconds.
     */
    event FuzzingStarted(bytes32 indexed campaignId, address indexed targetContract, uint256 duration);

    /**
     * @dev Emitted when a potential vulnerability is found during fuzzing.
     * @param campaignId The ID of the fuzzing campaign.
     * @param vulnerabilityType The type of vulnerability found (e.g., "reentrancy", "overflow").
     * @param inputData The input data that triggered the vulnerability.
     * @param description A description of the vulnerability.
     */
    event VulnerabilityFound(bytes32 indexed campaignId, string indexed vulnerabilityType, bytes inputData, string description);

    /**
     * @dev Emitted when a fuzzing campaign ends.
     * @param campaignId The ID of the fuzzing campaign.
     * @param totalTests The total number of test cases executed.
     * @param vulnerabilitiesFound The number of vulnerabilities found.
     */
    event FuzzingEnded(bytes32 indexed campaignId, uint256 totalTests, uint256 vulnerabilitiesFound);

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
     * @dev Thrown when a fuzzing campaign with the given ID is not found.
     */
    error CampaignNotFound(bytes32 campaignId);

    /**
     * @dev Initiates a fuzzing campaign on a target contract.
     * Only callable by authorized security researchers or auditors.
     * @param targetContract The address of the contract to fuzz.
     * @param duration The duration of the fuzzing campaign in seconds.
     * @param initialSeed An initial seed for the fuzzer.
     * @return campaignId The unique ID for this fuzzing campaign.
     */
    function startFuzzing(address targetContract, uint256 duration, bytes32 initialSeed) external returns (bytes32 campaignId);

    /**
     * @dev Reports a vulnerability found during a fuzzing campaign.
     * Only callable by the fuzzing tool itself or authorized reporters.
     * @param campaignId The ID of the fuzzing campaign.
     * @param vulnerabilityType The type of vulnerability found.
     * @param inputData The input data that triggered the vulnerability.
     * @param description A description of the vulnerability.
     */
    function reportVulnerability(bytes32 campaignId, string calldata vulnerabilityType, bytes calldata inputData, string calldata description) external;

    /**
     * @dev Retrieves the status of a fuzzing campaign.
     * @param campaignId The ID of the fuzzing campaign.
     * @return targetContract The address of the contract being fuzzed.
     * @return duration The duration of the campaign.
     * @return status The current status (e.g., "running", "completed", "paused").
     * @return vulnerabilitiesFound The number of vulnerabilities found so far.
     */
    function getCampaignStatus(bytes32 campaignId) external view returns (address targetContract, uint256 duration, string memory status, uint256 vulnerabilitiesFound);

    /**
     * @dev Retrieves a list of all vulnerabilities found in a specific campaign.
     * @param campaignId The ID of the fuzzing campaign.
     * @return vulnerabilities An array of Vulnerability structs.
     */
    function getVulnerabilities(bytes32 campaignId) external view returns (Vulnerability[] memory vulnerabilities);

    /**
     * @dev Struct representing a found vulnerability.
     */
    struct Vulnerability {
        string vulnerabilityType;
        bytes inputData;
        string description;
        uint256 timestamp;
    }
}