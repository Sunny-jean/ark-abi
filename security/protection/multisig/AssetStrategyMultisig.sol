// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAssetStrategyMultisig {
    event StrategyProposed(uint256 indexed strategyId, address indexed proposer, bytes32 indexed strategyHash);
    event StrategyConfirmed(uint256 indexed strategyId, address indexed confirmer);
    event StrategyExecuted(uint256 indexed strategyId);

    error UnauthorizedAccess(address caller);
    error InvalidStrategyState(uint256 strategyId);
    error AlreadyConfirmed(uint256 strategyId, address confirmer);
    error NotEnoughConfirmations(uint256 strategyId);

    function proposeStrategy(bytes calldata _strategyData, string memory _description) external returns (uint256);
    function confirmStrategy(uint256 _strategyId) external;
    function executeStrategy(uint256 _strategyId) external;
    function getConfirmationCount(uint256 _strategyId) external view returns (uint256);
}