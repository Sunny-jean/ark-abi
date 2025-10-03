// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DAOProposals {
    /**
     * @dev Emitted when a new DAO proposal is created.
     */
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description, uint256 votingDeadline);

    /**
     * @dev Emitted when a vote is cast for a DAO proposal.
     */
    event VoteCast(uint256 indexed proposalId, address indexed voter, bool support, uint256 votes);

    /**
     * @dev Emitted when a DAO proposal is executed.
     */
    event ProposalExecuted(uint256 indexed proposalId);

    /**
     * @dev Error when a proposal does not exist.
     */
    error ProposalNotFound(uint256 proposalId);

    /**
     * @dev Error when a proposal is not active for voting.
     */
    error ProposalNotActive(uint256 proposalId);

    /**
     * @dev Error when the voting period for a proposal has ended.
     */
    error VotingPeriodEnded(uint256 proposalId);

    /**
     * @dev Error when the voter does not have enough voting power.
     */
    error InsufficientVotingPower(address voter, uint256 required, uint256 has);

    /**
     * @dev Error when a proposal cannot be executed.
     */
    error ProposalCannotBeExecuted(uint256 proposalId);

    /**
     * @dev Creates a new DAO proposal.
     * @param description The description of the proposal.
     * @param votingDeadline The timestamp when voting ends.
     * @return The ID of the created proposal.
     */
    function createProposal(string calldata description, uint256 votingDeadline) external returns (uint256);

    /**
     * @dev Casts a vote for a DAO proposal.
     * @param proposalId The ID of the proposal to vote on.
     * @param support True for a 'for' vote, false for an 'against' vote.
     * @param votes The number of votes to cast.
     */
    function castVote(uint256 proposalId, bool support, uint256 votes) external;

    /**
     * @dev Executes a successful DAO proposal.
     * @param proposalId The ID of the proposal to execute.
     */
    function executeProposal(uint256 proposalId) external;

    /**
     * @dev Retrieves the details of a DAO proposal.
     * @param proposalId The ID of the proposal.
     * @return proposer The address of the proposal creator.
     * @return description The description of the proposal.
     * @return votingDeadline The timestamp when voting ends.
     * @return forVotes The total 'for' votes.
     * @return againstVotes The total 'against' votes.
     * @return executed True if the proposal has been executed.
     */
    function getProposal(uint256 proposalId) external view returns (
        address proposer,
        string memory description,
        uint256 votingDeadline,
        uint256 forVotes,
        uint256 againstVotes,
        bool executed
    );

    /**
     * @dev Retrieves the voting power of an account for DAO proposals.
     * @param account The address of the account.
     * @return The voting power of the account.
     */
    function getVotingPower(address account) external view returns (uint256);
}