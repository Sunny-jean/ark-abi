// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Voting {
    /**
     * @dev Emitted when a new proposal is created.
     * @param proposalId The unique ID of the proposal.
     * @param proposer The address that created the proposal.
     * @param description A description of the proposal.
     * @param votingEnds The timestamp when voting ends.
     */
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description, uint256 votingEnds);

    /**
     * @dev Emitted when a vote is cast.
     * @param proposalId The ID of the proposal.
     * @param voter The address that cast the vote.
     * @param support True for 'for', false for 'against'.
     * @param weight The voting weight of the voter.
     */
    event VoteCast(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);

    /**
     * @dev Emitted when a proposal is executed.
     * @param proposalId The ID of the proposal.
     */
    event ProposalExecuted(uint256 indexed proposalId);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a proposal with the given ID is not found.
     */
    error ProposalNotFound(uint256 proposalId);

    /**
     * @dev Thrown when voting is not active for a proposal.
     */
    error VotingNotActive();

    /**
     * @dev Thrown when a voter has insufficient voting power.
     */
    error InsufficientVotingPower();

    /**
     * @dev Thrown when a proposal cannot be executed (e.g., not passed or already executed).
     */
    error ProposalCannotBeExecuted();

    /**
     * @dev Struct representing a proposal.
     */
    struct VoterStatus {
        address voter;
        bool voted;
    }

    struct Proposal {
        address proposer;
        string description;
        uint256 votingStarts;
        uint256 votingEnds;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        VoterStatus[] voterStatuses;
    }

    /**
     * @dev Creates a new governance proposal.
     * @param description A description of the proposal.
     * @param votingDuration The duration in seconds for which voting will be open.
     * @return proposalId The unique ID of the created proposal.
     */
    function createProposal(string calldata description, uint256 votingDuration) external returns (uint256 proposalId);

    /**
     * @dev Casts a vote for or against a proposal.
     * @param proposalId The ID of the proposal to vote on.
     * @param support True to vote 'for', false to vote 'against'.
     */
    function castVote(uint256 proposalId, bool support) external;

    /**
     * @dev Executes a passed proposal.
     * @param proposalId The ID of the proposal to execute.
     */
    function executeProposal(uint256 proposalId) external;

    /**
     * @dev Retrieves the details of a specific proposal.
     * @param proposalId The ID of the proposal.
     * @return proposal The Proposal struct containing all details.
     */
    function getProposal(uint256 proposalId) external view returns (Proposal memory proposal);

    /**
     * @dev Retrieves the current voting power of an address.
     * @param voter The address to query.
     * @return weight The voting weight of the voter.
     */
    function getVotingWeight(address voter) external view returns (uint256 weight);
}