// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DisputeResolution {
    /**
     * @dev Emitted when a new dispute is created.
     * @param disputeId The unique ID of the dispute.
     * @param initiator The address that initiated the dispute.
     * @param counterparty The address of the counterparty in the dispute.
     * @param disputeType The type of dispute (e.g., "payment", "service").
     */
    event DisputeCreated(bytes32 indexed disputeId, address indexed initiator, address indexed counterparty, string disputeType);

    /**
     * @dev Emitted when a dispute's status is updated.
     * @param disputeId The ID of the dispute.
     * @param newStatus The new status of the dispute (e.g., "pending", "resolved", "arbitrated").
     */
    event DisputeStatusUpdated(bytes32 indexed disputeId, string newStatus);

    /**
     * @dev Emitted when a dispute is resolved.
     * @param disputeId The ID of the dispute.
     * @param resolution The outcome of the dispute.
     * @param resolvedBy The address that resolved the dispute.
     */
    event DisputeResolved(bytes32 indexed disputeId, string resolution, address indexed resolvedBy);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */

    /**
     * @dev Thrown when a required parameter is missing or invalid.
     */
    error InvalidParameter(string parameterName, string description);

    /**
     * @dev Thrown when a dispute with the given ID is not found.
     */
    error DisputeNotFound(bytes32 disputeId);

    /**
     * @dev Thrown when attempting to update a dispute that is already resolved.
     */
    error DisputeAlreadyResolved(bytes32 disputeId);

    /**
     * @dev Creates a new dispute.
     * @param counterparty The address of the other party involved in the dispute.
     * @param disputeType The type of dispute (e.g., "payment", "service").
     * @param detailsHash A hash of the dispute details (e.g., IPFS hash of evidence).
     */
    function createDispute(address counterparty, string calldata disputeType, bytes32 detailsHash) external returns (bytes32 disputeId);

    /**
     * @dev Updates the status of an existing dispute.
     * Only callable by authorized dispute resolvers or parties involved.
     * @param disputeId The ID of the dispute to update.
     * @param newStatus The new status (e.g., "pending_evidence", "under_review", "resolved").
     */
    function updateDisputeStatus(bytes32 disputeId, string calldata newStatus) external;

    /**
     * @dev Resolves a dispute with a specific outcome.
     * Only callable by authorized dispute resolvers.
     * @param disputeId The ID of the dispute to resolve.
     * @param resolution The outcome of the dispute (e.g., "favor_initiator", "favor_counterparty", "split").
     */
    function resolveDispute(bytes32 disputeId, string calldata resolution) external;

    /**
     * @dev Retrieves the details of a dispute.
     * @param disputeId The ID of the dispute.
     * @return initiator The address that initiated the dispute.
     * @return counterparty The address of the counterparty.
     * @return disputeType The type of dispute.
     * @return detailsHash The hash of the dispute details.
     * @return status The current status of the dispute.
     * @return resolution The resolution of the dispute, if resolved.
     */
    function getDisputeDetails(bytes32 disputeId) external view returns (address initiator, address counterparty, string memory disputeType, bytes32 detailsHash, string memory status, string memory resolution);

    /**
     * @dev Retrieves a list of disputes involving a specific address.
     * @param participant The address to query disputes for.
     * @return disputeIds An array of dispute IDs involving the participant.
     */
    function getDisputesForAddress(address participant) external view returns (bytes32[] memory disputeIds);
}