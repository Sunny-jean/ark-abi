// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ProposalManager {
    /**
     * @dev Emitted when a new proposal is created.
     * @param proposalId The unique ID of the proposal.
     * @param proposer The address that created the proposal.
     * @param descriptionHash A hash of the proposal's description.
     * @param creationTime The timestamp when the proposal was created.
     */
    event ProposalCreated(bytes32 indexed proposalId, address indexed proposer, bytes32 descriptionHash, uint256 creationTime);

    /**
     * @dev Emitted when a vote is cast on a proposal.
     * @param proposalId The unique ID of the proposal.
     * @param voter The address that cast the vote.
     * @param support True for 'for', false for 'against'.
     * @param votes The amount of voting power used.
     */
    event VoteCast(bytes32 indexed proposalId, address indexed voter, bool support, uint256 votes);

    /**
     * @dev Emitted when a proposal's state changes (e.g., from active to succeeded).
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
     * @dev Thrown when a proposal with the given ID does not exist.
     */
    error ProposalNotFound(bytes32 proposalId);

    /**
     * @dev Thrown when a vote is cast on a proposal that is not in an active voting state.
     */
    error VotingNotActive(bytes32 proposalId);

    /**
     * @dev Thrown when a user attempts to vote multiple times on the same proposal.
     */
    error AlreadyVoted(bytes32 proposalId, address voter);

    /**
     * @dev Creates a new governance proposal.
     * @param descriptionHash A hash of the proposal's detailed description.
     * @param targetContract The address of the contract to call if the proposal passes.
     * @param callData The calldata to execute on the target contract if the proposal passes.
     * @param votingPeriod The duration in seconds for which the proposal will be open for voting.
     * @return proposalId The unique ID of the created proposal.
     */
    function createProposal(bytes32 descriptionHash, address targetContract, bytes calldata callData, uint256 votingPeriod) external returns (bytes32 proposalId);

    /**
     * @dev Casts a vote on an active proposal.
     * @param proposalId The unique ID of the proposal to vote on.
     * @param support True for 'for' the proposal, false for 'against'.
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
     * @return state The current state of the proposal (e.g., "Pending", "Active", "Succeeded", "Defeated", "Executed").
     */
    function getProposalState(bytes32 proposalId) external view returns (string memory state);

    /**
     * @dev Retrieves the voting results for a proposal.
     * @param proposalId The unique ID of the proposal.
     * @return forVotes The total votes in favor.
     * @return againstVotes The total votes against.
     * @return totalVotes The total votes cast.
     */
    function getProposalVotes(bytes32 proposalId) external view returns (uint256 forVotes, uint256 againstVotes, uint256 totalVotes);
}