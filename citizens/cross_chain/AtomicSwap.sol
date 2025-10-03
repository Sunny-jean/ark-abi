// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AtomicSwap {
    /**
     * @dev Emitted when a new atomic swap is initiated.
     * @param swapId The unique ID of the swap.
     * @param initiator The address that initiated the swap.
     * @param participant The address of the counterparty.
     * @param assetA The address of the asset offered by the initiator.
     * @param amountA The amount of assetA.
     * @param assetB The address of the asset requested by the initiator.
     * @param amountB The amount of assetB.
     * @param expiry The timestamp when the swap expires.
     */
    event SwapInitiated(bytes32 indexed swapId, address indexed initiator, address indexed participant, address assetA, uint256 amountA, address assetB, uint256 amountB, uint256 expiry);

    /**
     * @dev Emitted when an atomic swap is completed successfully.
     * @param swapId The unique ID of the swap.
     */
    event SwapCompleted(bytes32 indexed swapId);

    /**
     * @dev Emitted when an atomic swap is canceled or refunded.
     * @param swapId The unique ID of the swap.
     */
    event SwapCanceled(bytes32 indexed swapId);

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
     * @dev Thrown when a swap with the given ID is not found.
     */
    error SwapNotFound(bytes32 swapId);

    /**
     * @dev Thrown when attempting to interact with a swap that is already completed or expired.
     */
    error InvalidSwapState(bytes32 swapId);

    /**
     * @dev Initiates a new atomic swap.
     * The initiator locks assetA and specifies assetB they wish to receive.
     * @param participant The address of the counterparty for the swap.
     * @param assetA The address of the token or native asset the initiator is offering.
     * @param amountA The amount of assetA.
     * @param assetB The address of the token or native asset the initiator is requesting.
     * @param amountB The amount of assetB.
     * @param expiry The timestamp after which the swap can be canceled by the initiator.
     * @return swapId The unique ID for this atomic swap.
     */
    function initiateSwap(address participant, address assetA, uint256 amountA, address assetB, uint256 amountB, uint256 expiry) external returns (bytes32 swapId);

    /**
     * @dev Participates in an initiated atomic swap.
     * The participant locks assetB to complete the swap.
     * @param swapId The ID of the swap to participate in.
     */
    function participateInSwap(bytes32 swapId) external;

    /**
     * @dev Completes an atomic swap, releasing assets to both parties.
     * Only callable after both parties have locked their assets.
     * @param swapId The ID of the swap to complete.
     */
    function completeSwap(bytes32 swapId) external;

    /**
     * @dev Cancels an atomic swap and refunds assetA to the initiator.
     * Only callable by the initiator after the expiry time, or by either party if the swap is not yet participated in.
     * @param swapId The ID of the swap to cancel.
     */
    function cancelSwap(bytes32 swapId) external;

    /**
     * @dev Retrieves the details of an atomic swap.
     * @param swapId The ID of the swap.
     * @return initiator The address that initiated the swap.
     * @return participant The address of the counterparty.
     * @return assetA The asset offered by the initiator.
     * @return amountA The amount of assetA.
     * @return assetB The asset requested by the initiator.
     * @return amountB The amount of assetB.
     * @return expiry The expiry timestamp.
     * @return status The current status of the swap (e.g., "initiated", "locked", "completed", "canceled").
     */
    function getSwapDetails(bytes32 swapId) external view returns (address initiator, address participant, address assetA, uint256 amountA, address assetB, uint256 amountB, uint256 expiry, string memory status);
}