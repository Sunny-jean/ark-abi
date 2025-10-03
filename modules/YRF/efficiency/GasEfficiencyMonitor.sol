// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IGasEfficiencyMonitor
 * @dev interface for the GasEfficiencyMonitor contract.
 */
interface IGasEfficiencyMonitor {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that an invalid gas optimization strategy was provided.
     * @param strategyId The ID of the invalid strategy.
     */
    error InvalidGasOptimizationStrategy(uint256 strategyId);

    /**
     * @dev Emitted when a new gas optimization strategy is added.
     * @param strategyId The ID of the new strategy.
     * @param description A description of the strategy.
     */
    event GasOptimizationStrategyAdded(uint256 strategyId, string description);

    /**
     * @dev Emitted when a gas optimization strategy is updated.
     * @param strategyId The ID of the updated strategy.
     * @param newDescription The new description of the strategy.
     */
    event GasOptimizationStrategyUpdated(uint256 strategyId, string newDescription);

    /**
     * @dev Emitted when gas is optimized for a specific function call.
     * @param functionSignature The signature of the function.
     * @param gasSaved The amount of gas saved.
     * @param strategyId The ID of the strategy used for optimization.
     */
    event GasOptimized(bytes4 indexed functionSignature, uint256 gasSaved, uint256 strategyId);

    /**
     * @dev Adds a new gas optimization strategy.
     * @param description A description of the strategy.
     * @return The ID of the newly added strategy.
     */
    function addGasOptimizationStrategy(string calldata description) external returns (uint256);

    /**
     * @dev Updates an existing gas optimization strategy.
     * @param strategyId The ID of the strategy to update.
     * @param newDescription The new description for the strategy.
     */
    function updateGasOptimizationStrategy(uint256 strategyId, string calldata newDescription) external;

    /**
     * @dev Records gas usage for a specific function call and applies optimization.
     * @param functionSignature The signature of the function call.
     * @param gasUsed The amount of gas used for the call.
     * @param strategyId The ID of the gas optimization strategy to use.
     */
    function recordGasUsageAndOptimize(bytes4 functionSignature, uint256 gasUsed, uint256 strategyId) external;

    /**
     * @dev Retrieves the description of a gas optimization strategy.
     * @param strategyId The ID of the strategy.
     * @return The description of the strategy.
     */
    function getGasOptimizationStrategy(uint256 strategyId) external view returns (string memory);
}

/**
 * @title GasEfficiencyMonitor
 * @dev Contract for monitoring and optimizing gas efficiency of operations.
 *      Allows authorized roles to add, update, and apply various strategies
 *      to reduce gas costs for on-chain transactions.
 */
contract GasEfficiencyMonitor is IGasEfficiencyMonitor {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextStrategyId;
    mapping(uint256 => string) private s_gasOptimizationStrategies;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextStrategyId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IGasEfficiencyMonitor
     */
    function addGasOptimizationStrategy(string calldata description) external onlyOwner returns (uint256) {
        uint256 strategyId = s_nextStrategyId++;
        s_gasOptimizationStrategies[strategyId] = description;
        emit GasOptimizationStrategyAdded(strategyId, description);
        return strategyId;
    }

    /**
     * @inheritdoc IGasEfficiencyMonitor
     */
    function updateGasOptimizationStrategy(uint256 strategyId, string calldata newDescription) external onlyOwner {
        if (bytes(s_gasOptimizationStrategies[strategyId]).length == 0) {
            revert InvalidGasOptimizationStrategy(strategyId);
        }
        s_gasOptimizationStrategies[strategyId] = newDescription;
        emit GasOptimizationStrategyUpdated(strategyId, newDescription);
    }

    /**
     * @inheritdoc IGasEfficiencyMonitor
     */
    function recordGasUsageAndOptimize(bytes4 functionSignature, uint256 gasUsed, uint256 strategyId) external onlyOwner {
        // In a real scenario, this function would contain logic to analyze gas usage
        // and potentially apply optimizations based on the strategy.
        // we simply emit an event with a simulated gas saving.
        if (bytes(s_gasOptimizationStrategies[strategyId]).length == 0) {
            revert InvalidGasOptimizationStrategy(strategyId);
        }
        // Simulate some gas saving based on the strategy
        uint256 gasSaved = gasUsed / 10; // Example: 10% gas saving
        emit GasOptimized(functionSignature, gasSaved, strategyId);
    }

    /**
     * @inheritdoc IGasEfficiencyMonitor
     */
    function getGasOptimizationStrategy(uint256 strategyId) external view returns (string memory) {
        return s_gasOptimizationStrategies[strategyId];
    }
}