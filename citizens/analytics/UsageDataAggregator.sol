// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface UsageDataAggregator {
    /**
     * @dev Emitted when usage data is aggregated.
     * @param aggregationId The unique ID of the aggregation.
     * @param dataType The type of data aggregated.
     * @param period The aggregation period.
     */
    event DataAggregated(bytes32 indexed aggregationId, string indexed dataType, uint256 indexed period);

    /**
     * @dev Emitted when an aggregation rule is updated.
     * @param ruleId The ID of the updated rule.
     * @param ruleHash A hash of the new rule definition.
     */
    event AggregationRuleUpdated(bytes32 indexed ruleId, bytes32 ruleHash);

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
     * @dev Thrown when the specified data type is not supported for aggregation.
     */
    error UnsupportedDataType(string dataType);

    /**
     * @dev Thrown when data aggregation fails.
     */
    error AggregationFailed(string reason);

    /**
     * @dev Triggers the aggregation of raw usage data based on predefined rules.
     * This function is typically called by an off-chain process or a privileged account.
     * @param dataType The type of usage data to aggregate (e.g., "module_usage", "user_interactions").
     * @param period The aggregation period (e.g., daily, weekly, monthly).
     * @return aggregationId The unique ID generated for this aggregation task.
     */
    function aggregateUsageData(string calldata dataType, uint256 period) external returns (bytes32 aggregationId);

    /**
     * @dev Updates the rules or parameters for data aggregation.
     * @param ruleId The unique ID of the aggregation rule to update.
     * @param ruleDefinition The new definition of the aggregation rule.
     */
    function updateAggregationRule(bytes32 ruleId, bytes calldata ruleDefinition) external;

    /**
     * @dev Retrieves aggregated data for a specific type and period.
     * @param dataType The type of aggregated data.
     * @param period The aggregation period.
     * @return aggregatedResult The aggregated data in bytes.
     */
    function getAggregatedData(string calldata dataType, uint256 period) external view returns (bytes memory aggregatedResult);
}