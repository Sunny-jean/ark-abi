// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title CreditRiskAssessmentAI - AI for credit risk assessment
/// @notice This interface defines functions for an AI system that assesses the creditworthiness of entities or protocols.
interface CreditRiskAssessmentAI {
    /// @notice Assesses the credit risk of a given address or entity.
    /// @param entityAddress The address or identifier of the entity to assess.
    /// @return creditScore A numerical score representing creditworthiness (higher is better).
    /// @return riskCategory A string describing the credit risk category (e.g., "low", "medium", "high").
    /// @return assessmentDetails A string providing details about the credit assessment.
    function assessCreditRisk(
        address entityAddress
    ) external view returns (uint256 creditScore, string memory riskCategory, string memory assessmentDetails);

    /// @notice Retrieves historical credit risk assessments for an entity.
    /// @param entityAddress The address or identifier of the entity.
    /// @return historicalScores An array of historical credit scores.
    /// @return timestamps An array of timestamps corresponding to the assessments.
    function getHistoricalCreditAssessments(
        address entityAddress
    ) external view returns (uint256[] memory historicalScores, uint256[] memory timestamps);

    /// @notice Event emitted when a credit risk assessment is performed.
    /// @param entityAddress The address or identifier of the entity.
    /// @param creditScore The assessed credit score.
    /// @param timestamp The timestamp of the assessment.
    event CreditRiskAssessed(
        address indexed entityAddress,
        uint256 creditScore,
        uint256 timestamp
    );

    /// @notice Error indicating that the entity address is invalid.
    error InvalidEntityAddress(address entityAddress);

    /// @notice Error indicating that credit data is insufficient or unavailable.
    error InsufficientCreditData();

    /// @notice Error indicating a failure in the credit risk assessment process.
    error CreditRiskAssessmentFailed(string message);
}