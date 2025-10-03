// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface SkillAssessmentManager {
    /**
     * @dev Emitted when a user completes a skill assessment.
     * @param user The address of the user.
     * @param assessmentId The unique ID of the assessment.
     * @param score The score achieved in the assessment.
     */
    event AssessmentCompleted(address indexed user, bytes32 indexed assessmentId, uint256 score);

    /**
     * @dev Emitted when a skill certification is issued.
     * @param user The address of the user.
     * @param skillId The unique ID of the skill certified.
     * @param certificationId The unique ID of the certification.
     */
    event SkillCertified(address indexed user, bytes32 indexed skillId, bytes32 indexed certificationId);

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
     * @dev Thrown when the specified assessment is not found.
     */
    error AssessmentNotFound(bytes32 assessmentId);

    /**
     * @dev Thrown when a user has not completed the prerequisites for an assessment.
     */
    error PrerequisitesNotMet(address user, bytes32 assessmentId);

    /**
     * @dev Records the completion of a skill assessment for a user.
     * @param user The address of the user.
     * @param assessmentId The unique ID of the assessment taken.
     * @param score The score obtained by the user.
     * @param assessmentData Additional data related to the assessment (e.g., answers, time taken).
     */
    function recordAssessmentCompletion(address user, bytes32 assessmentId, uint256 score, bytes calldata assessmentData) external;

    /**
     * @dev Issues a skill certification to a user based on assessment results or other criteria.
     * @param user The address of the user to certify.
     * @param skillId The unique ID of the skill being certified.
     * @param certificationDetails Details about the certification (e.g., expiry date, level).
     * @return certificationId The unique ID generated for the certification.
     */
    function issueSkillCertification(address user, bytes32 skillId, bytes calldata certificationDetails) external returns (bytes32 certificationId);

    /**
     * @dev Retrieves a user's score for a specific assessment.
     * @param user The address of the user.
     * @param assessmentId The unique ID of the assessment.
     * @return score The score achieved by the user.
     */
    function getUserAssessmentScore(address user, bytes32 assessmentId) external view returns (uint256 score);

    /**
     * @dev Checks if a user holds a specific skill certification.
     * @param user The address of the user.
     * @param skillId The unique ID of the skill.
     * @return isCertified True if the user is certified for the skill, false otherwise.
     * @return certificationId The ID of the certification (0 if not certified).
     */
    function hasSkillCertification(address user, bytes32 skillId) external view returns (bool isCertified, bytes32 certificationId);
}