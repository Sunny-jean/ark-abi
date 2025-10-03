// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ModelUpgradeAI - AI for model upgrades
/// @notice This interface defines functions for an AI system that manages and automates the upgrade of AI models.
interface ModelUpgradeAI {
    /// @notice Proposes an upgrade for a specific AI model.
    /// @param modelId The unique identifier of the model to upgrade.
    /// @param newModelHash A hash of the new model version.
    /// @param upgradeDetails A string providing details about the proposed upgrade.
    /// @return upgradeProposalId A unique identifier for the upgrade proposal.
    function proposeModelUpgrade(
        uint256 modelId,
        bytes32 newModelHash,
        string calldata upgradeDetails
    ) external returns (uint256 upgradeProposalId);

    /// @notice Approves a proposed model upgrade.
    /// @param upgradeProposalId The unique identifier of the upgrade proposal.
    /// @return success True if the approval was successful, false otherwise.
    function approveModelUpgrade(
        uint256 upgradeProposalId
    ) external returns (bool success);

    /// @notice Executes an approved model upgrade.
    /// @param upgradeProposalId The unique identifier of the upgrade proposal.
    /// @return success True if the execution was successful, false otherwise.
    function executeModelUpgrade(
        uint256 upgradeProposalId
    ) external returns (bool success);

    /// @notice Event emitted when a model upgrade is proposed.
    /// @param upgradeProposalId The unique identifier of the proposal.
    /// @param modelId The unique identifier of the model.
    /// @param newModelHash The hash of the new model version.
    /// @param timestamp The timestamp of the proposal.
    event ModelUpgradeProposed(
        uint256 indexed upgradeProposalId,
        uint256 indexed modelId,
        bytes32 newModelHash,
        uint256 timestamp
    );

    /// @notice Event emitted when a model upgrade is approved.
    /// @param upgradeProposalId The unique identifier of the proposal.
    /// @param timestamp The timestamp of the approval.
    event ModelUpgradeApproved(
        uint256 indexed upgradeProposalId,
        uint256 timestamp
    );

    /// @notice Event emitted when a model upgrade is executed.
    /// @param upgradeProposalId The unique identifier of the proposal.
    /// @param success True if successful, false otherwise.
    /// @param timestamp The timestamp of the execution.
    event ModelUpgradeExecuted(
        uint256 indexed upgradeProposalId,
        bool success,
        uint256 timestamp
    );

    /// @notice Error indicating that the model ID is invalid.
    error InvalidModelId(uint256 modelId);

    /// @notice Error indicating that the upgrade proposal ID is invalid.
    error InvalidUpgradeProposalId(uint256 upgradeProposalId);

    /// @notice Error indicating a failure in the model upgrade process.
    error ModelUpgradeFailed(string message);
}