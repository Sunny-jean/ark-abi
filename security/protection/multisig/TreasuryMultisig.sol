// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITreasuryMultisig {
    event TransactionProposed(uint256 indexed transactionId, address indexed destination, uint256 value, bytes data);
    event Confirmation(uint256 indexed transactionId, address indexed sender);
    event Execution(uint256 indexed transactionId);

    error UnauthorizedAccess(address caller);
    error AlreadyConfirmed(uint256 transactionId, address sender);
    error NotEnoughConfirmations(uint256 transactionId);
    error TransactionNotFound(uint256 transactionId);

    function proposeTransaction(address _destination, uint256 _value, bytes calldata _data) external returns (uint256);
    function confirmTransaction(uint256 _transactionId) external;
    function executeTransaction(uint256 _transactionId) external;
    function getConfirmationCount(uint256 _transactionId) external view returns (uint256);
    function isConfirmed(uint256 _transactionId) external view returns (bool);
}