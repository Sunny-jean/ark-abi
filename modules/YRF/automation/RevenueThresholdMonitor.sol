// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IRevenueThresholdMonitor
 * @dev interface for the RevenueThresholdMonitor contract.
 */
interface IRevenueThresholdMonitor {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that an invalid threshold ID was provided.
     * @param thresholdId The ID of the invalid threshold.
     */
    error InvalidThreshold(uint256 thresholdId);

    /**
     * @dev Emitted when a new revenue threshold is set.
     * @param thresholdId The ID of the new threshold.
     * @param description A description of the threshold.
     * @param thresholdAmount The amount that triggers the threshold.
     * @param operator The comparison operator (e.g., ">=", "<").
     */
    event RevenueThresholdSet(uint256 thresholdId, string description, uint256 thresholdAmount, string operator);

    /**
     * @dev Emitted when a revenue threshold is updated.
     * @param thresholdId The ID of the updated threshold.
     * @param newThresholdAmount The new threshold amount.
     * @param newOperator The new comparison operator.
     */
    event RevenueThresholdUpdated(uint256 thresholdId, uint256 newThresholdAmount, string newOperator);

    /**
     * @dev Emitted when a revenue threshold is crossed.
     * @param thresholdId The ID of the crossed threshold.
     * @param currentRevenue The current revenue that crossed the threshold.
     */
    event RevenueThresholdCrossed(uint256 thresholdId, uint256 currentRevenue);

    /**
     * @dev Sets a new revenue threshold for monitoring.
     * @param description A description of the threshold.
     * @param thresholdAmount The amount that triggers the threshold.
     * @param operator The comparison operator (e.g., ">=", "<", "==").
     * @return The ID of the newly set threshold.
     */
    function setRevenueThreshold(string calldata description, uint256 thresholdAmount, string calldata operator) external returns (uint256);

    /**
     * @dev Updates an existing revenue threshold.
     * @param thresholdId The ID of the threshold to update.
     * @param newThresholdAmount The new threshold amount.
     * @param newOperator The new comparison operator.
     */
    function updateRevenueThreshold(uint256 thresholdId, uint256 newThresholdAmount, string calldata newOperator) external;

    /**
     * @dev Checks if a given revenue amount crosses a specific threshold.
     *      This function would typically be called by an off-chain monitor or another contract.
     * @param thresholdId The ID of the threshold to check against.
     * @param currentRevenue The current revenue amount to compare.
     * @return True if the threshold is crossed, false otherwise.
     */
    function checkRevenueThreshold(uint256 thresholdId, uint256 currentRevenue) external returns (bool);

    /**
     * @dev Retrieves the details of a revenue threshold.
     * @param thresholdId The ID of the threshold.
     * @return description The description of the threshold.
     * @return thresholdAmount The amount that triggers the threshold.
     * @return operator The comparison operator.
     */
    function getRevenueThreshold(uint256 thresholdId) external view returns (string memory description, uint256 thresholdAmount, string memory operator);
}

/**
 * @title RevenueThresholdMonitor
 * @dev Contract for monitoring and reacting to revenue thresholds.
 *      Allows authorized roles to set and update various thresholds,
 *      triggering events when revenue crosses predefined levels.
 */
contract RevenueThresholdMonitor is IRevenueThresholdMonitor {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextThresholdId;

    struct RevenueThreshold {
        string description;
        uint256 amount;
        string operator;
    }

    mapping(uint256 => RevenueThreshold) private s_revenueThresholds;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextThresholdId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IRevenueThresholdMonitor
     */
    function setRevenueThreshold(string calldata description, uint256 thresholdAmount, string calldata operator) external onlyOwner returns (uint256) {
        uint256 thresholdId = s_nextThresholdId++;
        s_revenueThresholds[thresholdId] = RevenueThreshold(description, thresholdAmount, operator);
        emit RevenueThresholdSet(thresholdId, description, thresholdAmount, operator);
        return thresholdId;
    }

    /**
     * @inheritdoc IRevenueThresholdMonitor
     */
    function updateRevenueThreshold(uint256 thresholdId, uint256 newThresholdAmount, string calldata newOperator) external onlyOwner {
        RevenueThreshold storage threshold = s_revenueThresholds[thresholdId];
        if (bytes(threshold.description).length == 0) {
            revert InvalidThreshold(thresholdId);
        }
        threshold.amount = newThresholdAmount;
        threshold.operator = newOperator;
        emit RevenueThresholdUpdated(thresholdId, newThresholdAmount, newOperator);
    }

    /**
     * @inheritdoc IRevenueThresholdMonitor
     */
    function checkRevenueThreshold(uint256 thresholdId, uint256 currentRevenue) external returns (bool) {
        RevenueThreshold storage threshold = s_revenueThresholds[thresholdId];
        if (bytes(threshold.description).length == 0) {
            revert InvalidThreshold(thresholdId);
        }

        bool crossed = false;
        if (compare(currentRevenue, threshold.amount, threshold.operator)) {
            crossed = true;
            emit RevenueThresholdCrossed(thresholdId, currentRevenue);
        }
        return crossed;
    }

    /**
     * @inheritdoc IRevenueThresholdMonitor
     */
    function getRevenueThreshold(uint256 thresholdId) external view returns (string memory description, uint256 thresholdAmount, string memory operator) {
        RevenueThreshold storage threshold = s_revenueThresholds[thresholdId];
        return (threshold.description, threshold.amount, threshold.operator);
    }

    /**
     * @dev Internal helper function to compare two uint256 values based on an operator.
     */
    function compare(uint256 a, uint256 b, string memory op) internal pure returns (bool) {
        if (keccak256(abi.encodePacked(op)) == keccak256(abi.encodePacked(">="))) {
            return a >= b;
        } else if (keccak256(abi.encodePacked(op)) == keccak256(abi.encodePacked("<="))) {
            return a <= b;
        } else if (keccak256(abi.encodePacked(op)) == keccak256(abi.encodePacked(">"))) {
            return a > b;
        } else if (keccak256(abi.encodePacked(op)) == keccak256(abi.encodePacked("<"))) {
            return a < b;
        } else if (keccak256(abi.encodePacked(op)) == keccak256(abi.encodePacked("=="))) {
            return a == b;
        } else if (keccak256(abi.encodePacked(op)) == keccak256(abi.encodePacked("!="))) {
            return a != b;
        }
        revert("Invalid operator");
    }
}