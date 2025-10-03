// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface VotingSystem {
    /**
     * @dev Emitted when a new proposal is created.
     * @param proposalId The unique ID of the proposal.
     * @param proposer The address of the proposer.
     * @param title The title of the proposal.
     * @param creationTime The timestamp when the proposal was created.
     */
    event ProposalCreated(bytes32 indexed proposalId, address indexed proposer, string title, uint256 creationTime);

    /**
     * @dev Emitted when a vote is cast on a proposal.
     * @param proposalId The unique ID of the proposal.
     * @param voter The address of the voter.
     * @param support True for 'for', false for 'against'.
     * @param weight The voting weight of the voter.
     */
    event VoteCast(bytes32 indexed proposalId, address indexed voter, bool support, uint256 weight);

    /**
     * @dev Emitted when a proposal's state changes (e.g., to succeeded, defeated, executed).
     * @param proposalId The unique ID of the proposal.
     * @param newState The new state of the proposal.
     */
    event ProposalStateChanged(bytes32 indexed proposalId, string newState);

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
     * @dev Thrown when a proposal with the given ID is not found.
     */
    error ProposalNotFound(bytes32 proposalId);

    /**
     * @dev Thrown when a vote is attempted on a proposal that is not in the active voting period.
     */
    error VotingPeriodInactive();

    /**
     * @dev Thrown when a voter has already cast a vote on a proposal.
     */
    error AlreadyVoted();

    /**
     * @dev Thrown when a proposal cannot be executed due to its current state or conditions.
     */
    error ProposalCannotBeExecuted();

    /**
     * @dev Creates a new governance proposal.
     * @param title The title of the proposal.
     * @param description A detailed description of the proposal.
     * @param executionCalldata The calldata for the function to be executed if the proposal passes.
     * @param votingPeriod The duration of the voting period in seconds.
     * @return proposalId The unique ID of the created proposal.
     */
    function createProposal(string calldata title, string calldata description, bytes calldata executionCalldata, uint256 votingPeriod) external returns (bytes32 proposalId);

    /**
     * @dev Casts a vote on an active proposal.
     * @param proposalId The unique ID of the proposal.
     * @param support True for 'for', false for 'against'.
     */
    function castVote(bytes32 proposalId, bool support) external;

    /**
     * @dev Executes a successful proposal.
     * @param proposalId The unique ID of the proposal to execute.
     */
    function executeProposal(bytes32 proposalId) external;

    /**
     * @dev Retrieves the current state of a proposal.
     * @param proposalId The unique ID of the proposal.
     * @return state The current state (e.g., "Pending", "Active", "Succeeded", "Defeated", "Executed").
     * @return votesFor The total votes in favor.
     * @return votesAgainst The total votes against.
     * @return quorumReached True if the quorum has been reached.
     * @return proposalExecuted True if the proposal has been executed.
     */
    function getProposalState(bytes32 proposalId) external view returns (string memory state, uint256 votesFor, uint256 votesAgainst, bool quorumReached, bool proposalExecuted);

    /**
     * @dev Retrieves the details of a proposal.
     * @param proposalId The unique ID of the proposal.
     * @return proposer The address of the proposer.
     * @return title The title of the proposal.
     * @return description A detailed description of the proposal.
     * @return executionCalldata The calldata for the function to be executed.
     * @return creationTime The timestamp when the proposal was created.
     * @return votingEndTime The timestamp when the voting period ends.
     */
    function getProposalDetails(bytes32 proposalId) external view returns (address proposer, string memory title, string memory description, bytes memory executionCalldata, uint256 creationTime, uint256 votingEndTime);
}