// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDAOProposalExecutor {
    // DAO 提案執行
    function executeDAOProposal(uint256 _proposalId) external;
    function setExecutorRole(address _executor, bool _enabled) external;
    function getExecutorRole(address _executor) external view returns (bool);

    event DAOProposalExecuted(uint256 indexed proposalId);
    event ExecutorRoleSet(address indexed executor, bool enabled);

    error ProposalNotExecutable();
}