// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.15;

/// @title Buyback Audit Logger
/// @notice Records detailed information about buyback operations for auditing and analysis

// ========= interfaceS ========= //

/// @notice interface for the Buyback Audit Logger
interface IBuybackAuditLogger {
    // ========= STRUCTS ========= //

    /// @notice Structure to store buyback operation details
    struct BuybackRecord {
        uint256 timestamp;        // When the buyback occurred
        uint256 inputAmount;      // Amount of input token spent
        uint256 outputAmount;     // Amount of output token received
        uint256 price;            // Effective price (inputAmount / outputAmount)
        address executor;         // Address that executed the buyback
        bool success;             // Whether the buyback was successful
        string reason;            // Reason for success/failure
    }

    // ========= EVENTS ========= //

    /// @notice Emitted when a buyback operation is logged
    /// @param recordId The ID of the buyback record
    /// @param timestamp When the buyback occurred
    /// @param inputAmount Amount of input token spent
    /// @param outputAmount Amount of output token received
    /// @param price Effective price
    /// @param executor Address that executed the buyback
    /// @param success Whether the buyback was successful
    event BuybackLogged(
        uint256 indexed recordId,
        uint256 timestamp,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 price,
        address indexed executor,
        bool success
    );

    /// @notice Emitted when the history is cleared
    /// @param clearedBy Address that cleared the history
    /// @param recordCount Number of records cleared
    event HistoryCleared(address indexed clearedBy, uint256 recordCount);

    /// @notice Emitted when an authorized logger is added
    /// @param logger The address of the authorized logger
    event AuthorizedLoggerAdded(address indexed logger);

    /// @notice Emitted when an authorized logger is removed
    /// @param logger The address of the removed logger
    event AuthorizedLoggerRemoved(address indexed logger);

    /// @notice Emitted when ownership is transferred
    /// @param previousOwner The address of the previous owner
    /// @param newOwner The address of the new owner
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ========= ERRORS ========= //

    /// @notice Error when a caller is not authorized
    error BuybackAuditLogger_NotAuthorized();

    /// @notice Error when the caller is not the owner
    error BuybackAuditLogger_OnlyOwner();

    /// @notice Error when the caller is already authorized
    error BuybackAuditLogger_AlreadyAuthorized();

    /// @notice Error when the caller is not currently authorized
    error BuybackAuditLogger_NotCurrentlyAuthorized();

    /// @notice Error when the record ID is invalid
    error BuybackAuditLogger_InvalidRecordId();

    /// @notice Error when the input amount is zero
    error BuybackAuditLogger_ZeroInputAmount();

    /// @notice Error when the reason string is empty
    error BuybackAuditLogger_EmptyReason();

    // ========= FUNCTIONS ========= //

    /// @notice Logs a buyback operation
    /// @param inputAmount Amount of input token spent
    /// @param outputAmount Amount of output token received
    /// @param success Whether the buyback was successful
    /// @param reason Reason for success/failure
    /// @return recordId The ID of the created record
    function logBuyback(
        uint256 inputAmount,
        uint256 outputAmount,
        bool success,
        string calldata reason
    ) external returns (uint256 recordId);

    /// @notice Gets the total number of buyback records
    /// @return The total number of buyback records
    function getRecordCount() external view returns (uint256);

    /// @notice Gets a buyback record by ID
    /// @param recordId The ID of the record to retrieve
    /// @return The buyback record
    function getRecord(uint256 recordId) external view returns (BuybackRecord memory);

    /// @notice Gets multiple buyback records in a range
    /// @param startId The starting record ID (inclusive)
    /// @param endId The ending record ID (exclusive)
    /// @return An array of buyback records
    function getRecords(uint256 startId, uint256 endId) external view returns (BuybackRecord[] memory);

    /// @notice Gets the most recent buyback records
    /// @param count The number of recent records to retrieve
    /// @return An array of recent buyback records
    function getRecentRecords(uint256 count) external view returns (BuybackRecord[] memory);

    /// @notice Gets buyback records within a time range
    /// @param startTime The start timestamp (inclusive)
    /// @param endTime The end timestamp (inclusive)
    /// @return An array of buyback records within the time range
    function getRecordsByTimeRange(uint256 startTime, uint256 endTime) external view returns (BuybackRecord[] memory);

    /// @notice Gets the success rate of buyback operations
    /// @param lookbackCount The number of recent operations to consider (0 for all)
    /// @return successRate The success rate as a percentage (0-100)
    function getSuccessRate(uint256 lookbackCount) external view returns (uint256 successRate);

    /// @notice Gets the average price of successful buybacks
    /// @param lookbackCount The number of recent operations to consider (0 for all)
    /// @return avgPrice The average price
    function getAveragePrice(uint256 lookbackCount) external view returns (uint256 avgPrice);

    /// @notice Gets the total input amount spent on buybacks
    /// @param lookbackCount The number of recent operations to consider (0 for all)
    /// @param onlySuccessful Whether to only count successful operations
    /// @return totalAmount The total input amount
    function getTotalInputAmount(uint256 lookbackCount, bool onlySuccessful) external view returns (uint256 totalAmount);

    /// @notice Gets the total output amount received from buybacks
    /// @param lookbackCount The number of recent operations to consider (0 for all)
    /// @param onlySuccessful Whether to only count successful operations
    /// @return totalAmount The total output amount
    function getTotalOutputAmount(uint256 lookbackCount, bool onlySuccessful) external view returns (uint256 totalAmount);

    /// @notice Clears all buyback history
    function clearHistory() external;

    /// @notice Adds an authorized logger
    /// @param logger The address to authorize
    function addAuthorizedLogger(address logger) external;

    /// @notice Removes an authorized logger
    /// @param logger The address to remove authorization from
    function removeAuthorizedLogger(address logger) external;

    /// @notice Checks if an address is an authorized logger
    /// @param logger The address to check
    /// @return Whether the address is an authorized logger
    function isAuthorizedLogger(address logger) external view returns (bool);

    /// @notice Transfers ownership of the contract
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) external;
}

/// @title Buyback Audit Logger
/// @notice Records detailed information about buyback operations for auditing and analysis
contract BuybackAuditLogger is IBuybackAuditLogger {
    // ========= STATE VARIABLES ========= //

    /// @notice Array of buyback records
    BuybackRecord[] public records;

    /// @notice The owner of the contract
    address public owner;

    /// @notice Mapping of authorized loggers
    mapping(address => bool) public authorizedLoggers;

    // ========= CONSTRUCTOR ========= //

    /// @notice Constructor
    constructor() {
        owner = msg.sender;
        authorizedLoggers[msg.sender] = true;
        
        emit AuthorizedLoggerAdded(msg.sender);
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // ========= MODIFIERS ========= //

    /// @notice Modifier to restrict function access to authorized loggers
    modifier onlyAuthorized() {
        if (!authorizedLoggers[msg.sender]) revert BuybackAuditLogger_NotAuthorized();
        _;
    }

    /// @notice Modifier to restrict function access to the owner
    modifier onlyOwner() {
        if (msg.sender != owner) revert BuybackAuditLogger_OnlyOwner();
        _;
    }

    // ========= EXTERNAL FUNCTIONS ========= //

    /// @inheritdoc IBuybackAuditLogger
    function logBuyback(
        uint256 inputAmount,
        uint256 outputAmount,
        bool success,
        string calldata reason
    ) external onlyAuthorized returns (uint256 recordId) {
        if (inputAmount == 0) revert BuybackAuditLogger_ZeroInputAmount();
        if (bytes(reason).length == 0) revert BuybackAuditLogger_EmptyReason();
        
        uint256 price = outputAmount > 0 ? (inputAmount * 1e18) / outputAmount : 0;
        
        BuybackRecord memory newRecord = BuybackRecord({
            timestamp: block.timestamp,
            inputAmount: inputAmount,
            outputAmount: outputAmount,
            price: price,
            executor: msg.sender,
            success: success,
            reason: reason
        });
        
        records.push(newRecord);
        recordId = records.length - 1;
        
        emit BuybackLogged(
            recordId,
            block.timestamp,
            inputAmount,
            outputAmount,
            price,
            msg.sender,
            success
        );
        
        return recordId;
    }

    /// @inheritdoc IBuybackAuditLogger
    function getRecordCount() external view returns (uint256) {
        return records.length;
    }

    /// @inheritdoc IBuybackAuditLogger
    function getRecord(uint256 recordId) external view returns (BuybackRecord memory) {
        if (recordId >= records.length) revert BuybackAuditLogger_InvalidRecordId();
        return records[recordId];
    }

    /// @inheritdoc IBuybackAuditLogger
    function getRecords(uint256 startId, uint256 endId) external view returns (BuybackRecord[] memory) {
        if (startId >= records.length) revert BuybackAuditLogger_InvalidRecordId();
        if (endId > records.length) endId = records.length;
        if (startId >= endId) revert BuybackAuditLogger_InvalidRecordId();
        
        uint256 count = endId - startId;
        BuybackRecord[] memory result = new BuybackRecord[](count);
        
        for (uint256 i = 0; i < count; i++) {
            result[i] = records[startId + i];
        }
        
        return result;
    }

    /// @inheritdoc IBuybackAuditLogger
    function getRecentRecords(uint256 count) external view returns (BuybackRecord[] memory) {
        if (count == 0 || records.length == 0) {
            return new BuybackRecord[](0);
        }
        
        uint256 startId = records.length > count ? records.length - count : 0;
        uint256 resultCount = records.length - startId;
        
        BuybackRecord[] memory result = new BuybackRecord[](resultCount);
        
        for (uint256 i = 0; i < resultCount; i++) {
            result[i] = records[startId + i];
        }
        
        return result;
    }

    /// @inheritdoc IBuybackAuditLogger
    function getRecordsByTimeRange(uint256 startTime, uint256 endTime) external view returns (BuybackRecord[] memory) {
        // First count how many records are in the time range
        uint256 count = 0;
        for (uint256 i = 0; i < records.length; i++) {
            if (records[i].timestamp >= startTime && records[i].timestamp <= endTime) {
                count++;
            }
        }
        
        // Create result array and populate it
        BuybackRecord[] memory result = new BuybackRecord[](count);
        uint256 resultIndex = 0;
        
        for (uint256 i = 0; i < records.length; i++) {
            if (records[i].timestamp >= startTime && records[i].timestamp <= endTime) {
                result[resultIndex] = records[i];
                resultIndex++;
            }
        }
        
        return result;
    }

    /// @inheritdoc IBuybackAuditLogger
    function getSuccessRate(uint256 lookbackCount) external view returns (uint256 successRate) {
        if (records.length == 0) return 0;
        
        uint256 startId;
        uint256 totalCount;
        
        if (lookbackCount == 0 || lookbackCount >= records.length) {
            startId = 0;
            totalCount = records.length;
        } else {
            startId = records.length - lookbackCount;
            totalCount = lookbackCount;
        }
        
        uint256 successCount = 0;
        for (uint256 i = startId; i < startId + totalCount; i++) {
            if (records[i].success) {
                successCount++;
            }
        }
        
        return (successCount * 100) / totalCount;
    }

    /// @inheritdoc IBuybackAuditLogger
    function getAveragePrice(uint256 lookbackCount) external view returns (uint256 avgPrice) {
        if (records.length == 0) return 0;
        
        uint256 startId;
        uint256 totalCount;
        
        if (lookbackCount == 0 || lookbackCount >= records.length) {
            startId = 0;
            totalCount = records.length;
        } else {
            startId = records.length - lookbackCount;
            totalCount = lookbackCount;
        }
        
        uint256 successCount = 0;
        uint256 totalPrice = 0;
        
        for (uint256 i = startId; i < startId + totalCount; i++) {
            if (records[i].success && records[i].price > 0) {
                totalPrice += records[i].price;
                successCount++;
            }
        }
        
        return successCount > 0 ? totalPrice / successCount : 0;
    }

    /// @inheritdoc IBuybackAuditLogger
    function getTotalInputAmount(uint256 lookbackCount, bool onlySuccessful) external view returns (uint256 totalAmount) {
        if (records.length == 0) return 0;
        
        uint256 startId;
        uint256 totalCount;
        
        if (lookbackCount == 0 || lookbackCount >= records.length) {
            startId = 0;
            totalCount = records.length;
        } else {
            startId = records.length - lookbackCount;
            totalCount = lookbackCount;
        }
        
        totalAmount = 0;
        
        for (uint256 i = startId; i < startId + totalCount; i++) {
            if (!onlySuccessful || records[i].success) {
                totalAmount += records[i].inputAmount;
            }
        }
        
        return totalAmount;
    }

    /// @inheritdoc IBuybackAuditLogger
    function getTotalOutputAmount(uint256 lookbackCount, bool onlySuccessful) external view returns (uint256 totalAmount) {
        if (records.length == 0) return 0;
        
        uint256 startId;
        uint256 totalCount;
        
        if (lookbackCount == 0 || lookbackCount >= records.length) {
            startId = 0;
            totalCount = records.length;
        } else {
            startId = records.length - lookbackCount;
            totalCount = lookbackCount;
        }
        
        totalAmount = 0;
        
        for (uint256 i = startId; i < startId + totalCount; i++) {
            if (!onlySuccessful || records[i].success) {
                totalAmount += records[i].outputAmount;
            }
        }
        
        return totalAmount;
    }

    /// @inheritdoc IBuybackAuditLogger
    function clearHistory() external onlyOwner {
        uint256 recordCount = records.length;
        delete records;
        
        emit HistoryCleared(msg.sender, recordCount);
    }

    /// @inheritdoc IBuybackAuditLogger
    function addAuthorizedLogger(address logger) external onlyOwner {
        if (authorizedLoggers[logger]) revert BuybackAuditLogger_AlreadyAuthorized();
        
        authorizedLoggers[logger] = true;
        emit AuthorizedLoggerAdded(logger);
    }

    /// @inheritdoc IBuybackAuditLogger
    function removeAuthorizedLogger(address logger) external onlyOwner {
        if (!authorizedLoggers[logger]) revert BuybackAuditLogger_NotCurrentlyAuthorized();
        if (logger == owner) revert BuybackAuditLogger_NotAuthorized(); // Owner cannot remove themselves
        
        authorizedLoggers[logger] = false;
        emit AuthorizedLoggerRemoved(logger);
    }

    /// @inheritdoc IBuybackAuditLogger
    function isAuthorizedLogger(address logger) external view returns (bool) {
        return authorizedLoggers[logger];
    }

    /// @inheritdoc IBuybackAuditLogger
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert BuybackAuditLogger_NotAuthorized();
        
        address oldOwner = owner;
        owner = newOwner;
        
        // Ensure the new owner is an authorized logger
        if (!authorizedLoggers[newOwner]) {
            authorizedLoggers[newOwner] = true;
            emit AuthorizedLoggerAdded(newOwner);
        }
        
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}