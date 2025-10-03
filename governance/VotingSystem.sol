// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/**
 * @title VotingSystem
 * @notice Handles voting logic for ARK governance
 * @dev Advanced implementation of on-chain voting mechanisms with multiple strategies
 */

interface IGovernanceNFT {
    function balanceOf(address owner) external view returns (uint256);
    function getVotingPower(address account) external view returns (uint256);
    function getVotingPowerAt(address account, uint256 timestamp) external view returns (uint256);
}

contract VotingSystem {
    /* ========== EVENTS ========== */
    
    event VoteCast(address indexed voter, uint256 indexed proposalId, uint8 support, uint256 weight);
    event VoteWithReasonCast(address indexed voter, uint256 indexed proposalId, uint8 support, uint256 weight, string reason);

    event VotingStrategyUpdated(uint8 indexed strategyId, bool enabled);
    event VotingPeriodUpdated(uint256 oldPeriod, uint256 newPeriod);
    event GovernanceNFTUpdated(address indexed oldNFT, address indexed newNFT);
    event GovernanceUpdated(address indexed oldGovernance, address indexed newGovernance);

    /* ========== ERRORS ========== */
    
    error VS_OnlyGovernance();
    error VS_ZeroAddress();
    error VS_InvalidProposalId();
    error VS_InvalidVoteType();
    error VS_VotingClosed();
    error VS_AlreadyVoted();
    error VS_NoVotingPower();
    error VS_InvalidVotingStrategy();
    error VS_InvalidVotingParams();
    error VS_ProposalNotActive();

    /* ========== ENUMS ========== */
    
    enum VoteType {
        Against,
        For,
        Abstain
    }
    
    enum VotingStrategy {
        Standard,       // 1 token = 1 vote
        Quadratic,      // sqrt(tokens) = votes
        WeightedByTime, // Longer held tokens have more weight
        Conviction      // Votes accumulate over time
    }

    /* ========== STRUCTS ========== */
    
    struct Vote {
        address voter;
        uint8 support;
        uint256 weight;
        uint256 timestamp;
        string reason;
        uint256[] params; // For advanced voting strategies
    }
    
    struct ProposalVotes {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address => Vote) votes;
        mapping(address => bool) hasVoted;
        uint256 startTime;
        uint256 endTime;
        bool finalized;
    }

    /* ========== STATE VARIABLES ========== */
    
    address public governance;
    address public governanceNFT;
    
    uint256 public votingPeriod; // Default voting period in seconds
    
    mapping(uint256 => ProposalVotes) public proposalVotes;
    mapping(uint8 => bool) public votingStrategies; // Strategy ID => enabled
    
    uint8 public defaultVotingStrategy;

    /* ========== MODIFIERS ========== */
    
    modifier onlyGovernance() {
        if (msg.sender != governance) revert VS_OnlyGovernance();
        _;
    }
    
    modifier validProposal(uint256 proposalId) {
        if (proposalVotes[proposalId].startTime == 0) revert VS_InvalidProposalId();
        _;
    }
    
    modifier votingOpen(uint256 proposalId) {
        if (block.timestamp < proposalVotes[proposalId].startTime || 
            block.timestamp > proposalVotes[proposalId].endTime) {
            revert VS_VotingClosed();
        }
        _;
    }

    /* ========== CONSTRUCTOR ========== */
    
    constructor(address _governance, address _governanceNFT) {
        if (_governance == address(0) || _governanceNFT == address(0)) revert VS_ZeroAddress();
        
        governance = _governance;
        governanceNFT = _governanceNFT;
        votingPeriod = 7 days;
        
        // Enable default voting strategies
        votingStrategies[uint8(VotingStrategy.Standard)] = true;
        votingStrategies[uint8(VotingStrategy.Quadratic)] = true;
        defaultVotingStrategy = uint8(VotingStrategy.Standard);
    }

    /* ========== ADMIN FUNCTIONS ========== */
    
    function setGovernance(address _governance) external onlyGovernance {
        if (_governance == address(0)) revert VS_ZeroAddress();
        address oldGovernance = governance;
        governance = _governance;
        emit GovernanceUpdated(oldGovernance, _governance);
    }
    
    function setGovernanceNFT(address _governanceNFT) external onlyGovernance {
        if (_governanceNFT == address(0)) revert VS_ZeroAddress();
        address oldNFT = governanceNFT;
        governanceNFT = _governanceNFT;
        emit GovernanceNFTUpdated(oldNFT, _governanceNFT);
    }
    
    function setVotingPeriod(uint256 _votingPeriod) external onlyGovernance {
        uint256 oldPeriod = votingPeriod;
        votingPeriod = _votingPeriod;
        emit VotingPeriodUpdated(oldPeriod, _votingPeriod);
    }
    
    function setVotingStrategy(uint8 strategyId, bool enabled) external onlyGovernance {
        if (strategyId > uint8(VotingStrategy.Conviction)) revert VS_InvalidVotingStrategy();
        votingStrategies[strategyId] = enabled;
        emit VotingStrategyUpdated(strategyId, enabled);
    }
    
    function setDefaultVotingStrategy(uint8 strategyId) external onlyGovernance {
        if (strategyId > uint8(VotingStrategy.Conviction) || !votingStrategies[strategyId]) {
            revert VS_InvalidVotingStrategy();
        }
        defaultVotingStrategy = strategyId;
    }

    /* ========== PROPOSAL FUNCTIONS ========== */
    
    function createProposal(uint256 proposalId) external onlyGovernance {
        if (proposalVotes[proposalId].startTime != 0) revert VS_InvalidProposalId();
        
        proposalVotes[proposalId].startTime = block.timestamp;
        proposalVotes[proposalId].endTime = block.timestamp + votingPeriod;
    }
    
    function createProposalWithPeriod(uint256 proposalId, uint256 startTime, uint256 endTime) external onlyGovernance {
        if (proposalVotes[proposalId].startTime != 0) revert VS_InvalidProposalId();
        if (startTime >= endTime) revert VS_InvalidVotingParams();
        
        proposalVotes[proposalId].startTime = startTime;
        proposalVotes[proposalId].endTime = endTime;
    }
    
    function extendVotingPeriod(uint256 proposalId, uint256 extension) external onlyGovernance validProposal(proposalId) {
        if (proposalVotes[proposalId].finalized) revert VS_ProposalNotActive();
        proposalVotes[proposalId].endTime += extension;
    }
    
    function finalizeProposal(uint256 proposalId) external onlyGovernance validProposal(proposalId) {
        if (block.timestamp <= proposalVotes[proposalId].endTime) revert VS_ProposalNotActive();
        proposalVotes[proposalId].finalized = true;
    }

    /* ========== VOTING FUNCTIONS ========== */
    
    function castVote(uint256 proposalId, uint8 support) external validProposal(proposalId) votingOpen(proposalId) {
        _castVote(proposalId, support, "", new uint256[](0), defaultVotingStrategy);
    }
    
    function castVoteWithReason(uint256 proposalId, uint8 support, string calldata reason) 
        external 
        validProposal(proposalId) 
        votingOpen(proposalId) 
    {
        _castVote(proposalId, support, reason, new uint256[](0), defaultVotingStrategy);
    }
    
    function castVoteWithStrategy(uint256 proposalId, uint8 support, uint8 strategy) 
        external 
        validProposal(proposalId) 
        votingOpen(proposalId) 
    {
        if (!votingStrategies[strategy]) revert VS_InvalidVotingStrategy();
        _castVote(proposalId, support, "", new uint256[](0), strategy);
    }
    
    function castVoteWithParams(uint256 proposalId, uint8 support, uint256[] calldata params, uint8 strategy) 
        external 
        validProposal(proposalId) 
        votingOpen(proposalId) 
    {
        if (!votingStrategies[strategy]) revert VS_InvalidVotingStrategy();
        _castVote(proposalId, support, "", params, strategy);
    }
    
    function _castVote(
        uint256 proposalId,
        uint8 support,
        string memory reason,
        uint256[] memory params,
        uint8 strategy
    ) internal {
        if (support > uint8(VoteType.Abstain)) revert VS_InvalidVoteType();
        
        ProposalVotes storage proposal = proposalVotes[proposalId];
        if (proposal.hasVoted[msg.sender]) revert VS_AlreadyVoted();
        
        // Calculate voting weight based on strategy
        uint256 weight = _calculateVotingWeight(msg.sender, proposal.startTime, strategy, params);
        if (weight == 0) revert VS_NoVotingPower();
        
        // Record vote
        proposal.hasVoted[msg.sender] = true;
        
        Vote storage vote = proposal.votes[msg.sender];
        vote.voter = msg.sender;
        vote.support = support;
        vote.weight = weight;
        vote.timestamp = block.timestamp;
        vote.reason = reason;
        vote.params = params;
        
        // Update vote tallies
        if (support == uint8(VoteType.Against)) {
            proposal.againstVotes += weight;
        } else if (support == uint8(VoteType.For)) {
            proposal.forVotes += weight;
        } else {
            proposal.abstainVotes += weight;
        }
        
        // Emit appropriate event
        if (bytes(reason).length > 0) {
            emit VoteWithReasonCast(msg.sender, proposalId, support, weight, reason);
        } else if (params.length > 0) {

        } else {
            emit VoteCast(msg.sender, proposalId, support, weight);
        }
    }

    /* ========== VIEW FUNCTIONS ========== */
    
    function getProposalVotes(uint256 proposalId) external view validProposal(proposalId) returns (
        uint256 againstVotes,
        uint256 forVotes,
        uint256 abstainVotes,
        uint256 startTime,
        uint256 endTime,
        bool finalized
    ) {
        ProposalVotes storage proposal = proposalVotes[proposalId];
        return (
            proposal.againstVotes,
            proposal.forVotes,
            proposal.abstainVotes,
            proposal.startTime,
            proposal.endTime,
            proposal.finalized
        );
    }
    
    function hasVoted(uint256 proposalId, address account) external view validProposal(proposalId) returns (bool) {
        return proposalVotes[proposalId].hasVoted[account];
    }
    
    function getVoteInfo(uint256 proposalId, address voter) external view validProposal(proposalId) returns (
        uint8 support,
        uint256 weight,
        uint256 timestamp,
        string memory reason
    ) {
        if (!proposalVotes[proposalId].hasVoted[voter]) {
            return (0, 0, 0, "");
        }
        
        Vote storage vote = proposalVotes[proposalId].votes[voter];
        return (vote.support, vote.weight, vote.timestamp, vote.reason);
    }
    
    function isVotingOpen(uint256 proposalId) external view validProposal(proposalId) returns (bool) {
        ProposalVotes storage proposal = proposalVotes[proposalId];
        return block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime && !proposal.finalized;
    }
    
    function getVotingStrategies() external view returns (bool[] memory) {
        bool[] memory strategies = new bool[](uint8(VotingStrategy.Conviction) + 1);
        for (uint8 i = 0; i <= uint8(VotingStrategy.Conviction); i++) {
            strategies[i] = votingStrategies[i];
        }
        return strategies;
    }
    
    function calculateVotingWeight(address account, uint256 timestamp, uint8 strategy, uint256[] calldata params) 
        external 
        view 
        returns (uint256) 
    {
        return _calculateVotingWeight(account, timestamp, strategy, params);
    }

    /* ========== INTERNAL FUNCTIONS ========== */
    
    function _calculateVotingWeight(
        address account,
        uint256 timestamp,
        uint8 strategy,
        uint256[] memory params
    ) internal view returns (uint256) {
        IGovernanceNFT nft = IGovernanceNFT(governanceNFT);
        uint256 votingPower = nft.getVotingPowerAt(account, timestamp);
        
        if (votingPower == 0) return 0;
        
        if (strategy == uint8(VotingStrategy.Standard)) {
            // Standard: 1 token = 1 vote
            return votingPower;
        } else if (strategy == uint8(VotingStrategy.Quadratic)) {
            // Quadratic: sqrt(tokens) = votes
            return _sqrt(votingPower);
        } else if (strategy == uint8(VotingStrategy.WeightedByTime)) {
            // WeightedByTime: longer held tokens have more weight
            // this would use token age
            //  implementation, we'll just return the voting power
            return votingPower;
        } else if (strategy == uint8(VotingStrategy.Conviction)) {
            // Conviction: votes accumulate over time
            // this would use time-based accumulation
            //  implementation, we'll just return the voting power
            return votingPower;
        }
        
        revert VS_InvalidVotingStrategy();
    }
    
    function _sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        
        return y;
    }
}