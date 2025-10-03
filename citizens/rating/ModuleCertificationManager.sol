// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModuleCertificationManager {
    /**
     * @dev Emitted when a module is certified.
     * @param moduleId The ID of the certified module.
     * @param certificationId The unique ID of the certification.
     * @param certifier The address of the entity that issued the certification.
     */
    event ModuleCertified(bytes32 indexed moduleId, bytes32 indexed certificationId, address indexed certifier);

    /**
     * @dev Emitted when a certification is revoked.
     * @param certificationId The unique ID of the revoked certification.
     * @param reason The reason for revocation.
     */
    event CertificationRevoked(bytes32 indexed certificationId, string reason);

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
     * @dev Thrown when the specified module is not found.
     */
    error ModuleNotFound(bytes32 moduleId);

    /**
     * @dev Thrown when a certification is not found.
     */
    error CertificationNotFound(bytes32 certificationId);

    /**
     * @dev Certifies a module after it meets specific quality or compliance standards.
     * @param moduleId The unique ID of the module to certify.
     * @param certifier The address of the entity issuing the certification.
     * @param certificationDetails Details about the certification (e.g., standards met, expiry date).
     * @return certificationId The unique ID generated for the certification.
     */
    function certifyModule(bytes32 moduleId, address certifier, bytes calldata certificationDetails) external returns (bytes32 certificationId);

    /**
     * @dev Revokes an existing module certification.
     * @param certificationId The unique ID of the certification to revoke.
     * @param reason The reason for revoking the certification.
     */
    function revokeCertification(bytes32 certificationId, string calldata reason) external;

    /**
     * @dev Retrieves the certification status and details for a module.
     * @param moduleId The unique ID of the module.
     * @return isCertified True if the module is currently certified, false otherwise.
     * @return certificationDetails Details about the active certification.
     */
    function getCertificationStatus(bytes32 moduleId) external view returns (bool isCertified, bytes memory certificationDetails);
}