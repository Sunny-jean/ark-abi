// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IVotingEscrowIntegration {
    event VoteCast(address indexed voter, uint256 indexed proposalId, uint256 indexed votes, bool support);

    error VotingFailed(string message);

    function castVote(uint256 _proposalId, uint256 _votes, bool _support) external;
    function getVotes(address _voter) external view returns (uint256);
}

contract VotingEscrowIntegration is IVotingEscrowIntegration, Ownable {

    address public s_votingEscrowAddress;

    constructor(address initialOwner, address _votingEscrowAddress) Ownable(initialOwner) {
        s_votingEscrowAddress = _votingEscrowAddress;
    }

    function castVote(uint256 _proposalId, uint256 _votes, bool _support) external {
        // In a real scenario, this would interact with the voting escrow contract
        // to cast a vote using the user's locked tokens.
        require(s_votingEscrowAddress != address(0), "Voting escrow address not set.");

        // Simulate voting logic
        if (_votes == 0) {
            revert VotingFailed("Cannot cast 0 votes.");
        }

        emit VoteCast(msg.sender, _proposalId, _votes, _support);
    }

    function getVotes(address _voter) external view returns (uint256) {
        // In a real scenario, this would query the voting escrow contract
        // to get the voting power of a specific address.
        return 100; // Simulate 100 votes for any voter
    }

    function setVotingEscrowAddress(address _newAddress) external onlyOwner {
        s_votingEscrowAddress = _newAddress;
    }
}