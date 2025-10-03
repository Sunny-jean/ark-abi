// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface SignatureVerifier {
    /**
     * @dev Emitted when a signature is successfully verified.
     * @param signer The address that signed the message.
     * @param messageHash The hash of the message that was signed.
     */
    event SignatureVerified(address indexed signer, bytes32 indexed messageHash);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a required parameter is missing or invalid.
     */
    error InvalidParameter(string parameterName, string description);

    /**
     * @dev Thrown when a signature is invalid or does not match the message and signer.
     */
    error InvalidSignature();

    /**
     * @dev Verifies an ECDSA signature.
     * @param messageHash The hash of the message that was signed.
     * @param signature The ECDSA signature.
     * @return isValid True if the signature is valid for the given message hash and signer, false otherwise.
     */
    function verify(bytes32 messageHash, bytes calldata signature) external view returns (bool isValid);

    /**
     * @dev Recovers the signer's address from an ECDSA signature.
     * @param messageHash The hash of the message that was signed.
     * @param signature The ECDSA signature.
     * @return signer The address of the signer.
     */
    function recoverSigner(bytes32 messageHash, bytes calldata signature) external view returns (address signer);

    /**
     * @dev Verifies an EIP-712 typed data signature.
     * @param domainSeparator The EIP-712 domain separator.
     * @param structHash The hash of the EIP-712 struct.
     * @param signature The ECDSA signature.
     * @return isValid True if the signature is valid for the given typed data and signer, false otherwise.
     */
    function verifyEIP712(bytes32 domainSeparator, bytes32 structHash, bytes calldata signature) external view returns (bool isValid);
}