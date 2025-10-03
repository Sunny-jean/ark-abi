// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMultisigTransactionValidator {
    event TransactionValidated(uint256 indexed transactionId, bool isValid);

    error InvalidSignature(address signer);
    error InvalidTransactionData(bytes data);
    error UnauthorizedValidator(address caller);

    function validateTransaction(uint256 _transactionId, bytes[] calldata _signatures) external view returns (bool);
    function isValidSignature(uint256 _transactionId, bytes calldata _signature, address _signer) external view returns (bool);
}