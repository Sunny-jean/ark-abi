// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICrossChainProposalRelayer {
    function relayProposal(uint256 _proposalId, uint256 _targetChainId) external;
    function setRelayerAddress(address _relayer) external;
    function getRelayerAddress() external view returns (address);

    event ProposalRelayed(uint256 indexed proposalId, uint256 indexed targetChainId);
    event RelayerAddressSet(address indexed relayer);

    error RelayFailed();
}