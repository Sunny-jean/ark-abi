// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Governor {
    /**
     * @dev Emitted when a proposal is created.
     */
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, uint256 voteStart, uint256 voteEnd, string description);

    /**
     * @dev Emitted when a vote is cast.
     */
    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason);

    /**
     * @dev Emitted when a proposal is canceled.
     */
    event ProposalCanceled(uint256 indexed proposalId);

    /**
     * @dev Emitted when a proposal is queued.
     */
    event ProposalQueued(uint256 indexed proposalId, uint256 eta);

    /**
     * @dev Emitted when a proposal is executed.
     */
    event ProposalExecuted(uint256 indexed proposalId);

    /**
     * @dev Error when a proposal is not found.
     */
    error ProposalNotFound(uint256 proposalId);

    /**
     * @dev Error when a proposal is not in the correct state.
     */
    error InvalidProposalState(uint256 proposalId, uint8 expectedState);

    /**
     * @dev Error when a vote is invalid.
     */
    error InvalidVote(uint256 proposalId, address voter);

    /**
     * @dev Creates a new proposal.
     * @param targets The addresses of the contracts to call.
     * @param values The amounts of native currency to send with each call.
     * @param calldatas The calldata to send with each call.
     * @param description The description of the proposal.
     * @return The ID of the created proposal.
     */
    function propose(address[] calldata targets, uint256[] calldata values, bytes[] calldata calldatas, string calldata description) external returns (uint256);

    /**
     * @dev Casts a vote on a proposal.
     * @param proposalId The ID of the proposal.
     * @param support The vote type (0 for against, 1 for for, 2 for abstain).
     */
    function castVote(uint256 proposalId, uint8 support) external;

    /**
     * @dev Queues a proposal for execution.
     * @param proposalId The ID of the proposal.
     */
    function queue(uint256 proposalId) external;

    /**
     * @dev Executes a queued proposal.
     * @param proposalId The ID of the proposal.
     */
    function execute(uint256 proposalId) external;

    /**
     * @dev Cancels a proposal.
     * @param proposalId The ID of the proposal.
     */
    function cancel(uint256 proposalId) external;

    /**
     * @dev Returns the state of a proposal.
     * @param proposalId The ID of the proposal.
     * @return The state of the proposal (Pending, Active, Canceled, Defeated, Succeeded, Queued, Expired, Executed).
     */
    function state(uint256 proposalId) external view returns (uint8);

    /**
     * @dev Returns the voting power of an account at a specific block number.
     * @param account The address of the account.
     * @param blockNumber The block number to query.
     * @return The voting power.
     */
    function getVotes(address account, uint256 blockNumber) external view returns (uint256);
}