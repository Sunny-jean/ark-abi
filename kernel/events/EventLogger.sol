// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Event Logger
/// @notice Records and manages system events for historical tracking and analysis
interface IEventLogger {
    function logEvent(bytes32 eventType_, bytes memory data_) external;
    function getLogCount() external view returns (uint256);
    function getLogsByType(bytes32 eventType_, uint256 offset_, uint256 limit_) external view returns (uint256[] memory);
    function getLogDetails(uint256 logId_) external view returns (bytes32, address, bytes memory, uint256, uint256);
}

contract EventLogger is IEventLogger {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event LogRecorded(bytes32 indexed eventType, address indexed source, bytes data, uint256 timestamp);
    event LogCategoryAdded(bytes32 indexed categoryId, string name);
    event LogCategoryRemoved(bytes32 indexed categoryId);
    event LoggerAdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event RetentionPolicyChanged(uint256 oldRetentionDays, uint256 newRetentionDays);
    event LogsPurged(uint256 purgeCount, uint256 timestamp);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error EventLogger_OnlyAdmin(address caller_);
    error EventLogger_OnlyAuthorized(address source_);
    error EventLogger_InvalidAddress(address addr_);
    error EventLogger_CategoryNotFound(bytes32 categoryId_);
    error EventLogger_CategoryAlreadyExists(bytes32 categoryId_);
    error EventLogger_LogNotFound(uint256 logId_);
    error EventLogger_InvalidRetentionPolicy(uint256 days_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct LogCategory {
        bytes32 id;
        string name;
        bool exists;
    }

    struct LogEntry {
        bytes32 eventType;
        address source;
        bytes data;
        uint256 timestamp;
        uint256 blockNumber;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    
    // Authorized sources
    mapping(address => bool) public isAuthorizedSource;
    address[] public authorizedSources;
    
    // Log categories
    mapping(bytes32 => LogCategory) public logCategories;
    mapping(string => bytes32) public categoryIdByName;
    bytes32[] public allCategories;
    
    // Log entries
    LogEntry[] public logEntries;
    mapping(bytes32 => uint256[]) public logsByType;
    
    // Retention policy (in days)
    uint256 public retentionPolicyDays;
    uint256 public lastPurgeTimestamp;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert EventLogger_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyAuthorized() {
        if (!isAuthorizedSource[msg.sender]) revert EventLogger_OnlyAuthorized(msg.sender);
        _;
    }

    modifier categoryExists(bytes32 categoryId_) {
        if (!logCategories[categoryId_].exists) revert EventLogger_CategoryNotFound(categoryId_);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, uint256 retentionPolicyDays_) {
        if (admin_ == address(0)) revert EventLogger_InvalidAddress(admin_);
        if (retentionPolicyDays_ < 1) revert EventLogger_InvalidRetentionPolicy(retentionPolicyDays_);
        
        admin = admin_;
        retentionPolicyDays = retentionPolicyDays_;
        lastPurgeTimestamp = block.timestamp;
        
        // Initialize default categories
        _addCategory("system", keccak256("SYSTEM"));
        _addCategory("security", keccak256("SECURITY"));
        _addCategory("user", keccak256("USER"));
        _addCategory("transaction", keccak256("TRANSACTION"));
        _addCategory("error", keccak256("ERROR"));
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Log an event
    /// @param eventType_ The event type
    /// @param data_ The event data
    function logEvent(
        bytes32 eventType_,
        bytes memory data_
    ) external override onlyAuthorized {
        // Create log entry
        LogEntry memory newLog = LogEntry({
            eventType: eventType_,
            source: msg.sender,
            data: data_,
            timestamp: block.timestamp,
            blockNumber: block.number
        });
        
        // Add to arrays
        uint256 logId = logEntries.length;
        logEntries.push(newLog);
        logsByType[eventType_].push(logId);
        
        emit LogRecorded(eventType_, msg.sender, data_, block.timestamp);
    }

    /// @notice Add a log category
    /// @param name_ The category name
    /// @param categoryId_ The category ID
    function addCategory(
        string calldata name_,
        bytes32 categoryId_
    ) external onlyAdmin {
        _addCategory(name_, categoryId_);
    }

    /// @notice Remove a log category
    /// @param categoryId_ The category ID
    function removeCategory(bytes32 categoryId_) external onlyAdmin categoryExists(categoryId_) {
        // Remove name mapping
        delete categoryIdByName[logCategories[categoryId_].name];
        
        // Remove category
        delete logCategories[categoryId_];
        
        // Remove from array
        for (uint256 i = 0; i < allCategories.length; i++) {
            if (allCategories[i] == categoryId_) {
                allCategories[i] = allCategories[allCategories.length - 1];
                allCategories.pop();
                break;
            }
        }
        
        emit LogCategoryRemoved(categoryId_);
    }

    /// @notice Authorize a source
    /// @param source_ The source address
    function authorizeSource(address source_) external onlyAdmin {
        if (source_ == address(0)) revert EventLogger_InvalidAddress(source_);
        if (isAuthorizedSource[source_]) return;
        
        isAuthorizedSource[source_] = true;
        authorizedSources.push(source_);
    }

    /// @notice Deauthorize a source
    /// @param source_ The source address
    function deauthorizeSource(address source_) external onlyAdmin {
        if (!isAuthorizedSource[source_]) return;
        
        isAuthorizedSource[source_] = false;
        
        // Remove from array
        for (uint256 i = 0; i < authorizedSources.length; i++) {
            if (authorizedSources[i] == source_) {
                authorizedSources[i] = authorizedSources[authorizedSources.length - 1];
                authorizedSources.pop();
                break;
            }
        }
    }

    /// @notice Change the admin
    /// @param newAdmin_ The new admin address
    function changeAdmin(address newAdmin_) external onlyAdmin {
        if (newAdmin_ == address(0)) revert EventLogger_InvalidAddress(newAdmin_);
        
        address oldAdmin = admin;
        admin = newAdmin_;
        
        emit LoggerAdminChanged(oldAdmin, newAdmin_);
    }

    /// @notice Set the retention policy
    /// @param days_ The retention period in days
    function setRetentionPolicy(uint256 days_) external onlyAdmin {
        if (days_ < 1) revert EventLogger_InvalidRetentionPolicy(days_);
        
        uint256 oldRetentionDays = retentionPolicyDays;
        retentionPolicyDays = days_;
        
        emit RetentionPolicyChanged(oldRetentionDays, days_);
    }

    /// @notice Purge old logs
    /// @return purgeCount The number of logs purged
    function purgeLogs() external onlyAdmin returns (uint256) {
        uint256 cutoffTimestamp = block.timestamp - (retentionPolicyDays * 1 days);
        uint256 purgeCount = 0;
        
        // this would actually purge old logs
        //  we just update the lastPurgeTimestamp
        
        lastPurgeTimestamp = block.timestamp;
        
        emit LogsPurged(purgeCount, block.timestamp);
        
        return purgeCount;
    }

    /// @notice Get the total log count
    /// @return The total number of logs
    function getLogCount() external view override returns (uint256) {
        return logEntries.length;
    }

    /// @notice Get logs by type
    /// @param eventType_ The event type
    /// @param offset_ The offset
    /// @param limit_ The limit
    /// @return Array of log IDs
    function getLogsByType(
        bytes32 eventType_,
        uint256 offset_,
        uint256 limit_
    ) external view override returns (uint256[] memory) {
        uint256[] storage logs = logsByType[eventType_];
        
        // Calculate actual limit
        uint256 actualLimit = limit_;
        if (offset_ + actualLimit > logs.length) {
            actualLimit = logs.length > offset_ ? logs.length - offset_ : 0;
        }
        
        // Create result array
        uint256[] memory result = new uint256[](actualLimit);
        
        // Fill result array
        for (uint256 i = 0; i < actualLimit; i++) {
            result[i] = logs[offset_ + i];
        }
        
        return result;
    }

    /// @notice Get log details
    /// @param logId_ The log ID
    /// @return eventType The event type
    /// @return source The source address
    /// @return data The log data
    /// @return timestamp When the log was recorded
    /// @return blockNumber The block number when the log was recorded
    function getLogDetails(uint256 logId_) external view override returns (
        bytes32 eventType,
        address source,
        bytes memory data,
        uint256 timestamp,
        uint256 blockNumber
    ) {
        if (logId_ >= logEntries.length) revert EventLogger_LogNotFound(logId_);
        
        LogEntry memory log = logEntries[logId_];
        return (
            log.eventType,
            log.source,
            log.data,
            log.timestamp,
            log.blockNumber
        );
    }

    /// @notice Get all categories
    /// @return Array of category IDs
    function getAllCategories() external view returns (bytes32[] memory) {
        return allCategories;
    }

    /// @notice Get category details
    /// @param categoryId_ The category ID
    /// @return id The category ID
    /// @return name The category name
    function getCategoryDetails(bytes32 categoryId_) external view categoryExists(categoryId_) returns (
        bytes32 id,
        string memory name
    ) {
        LogCategory memory category = logCategories[categoryId_];
        return (category.id, category.name);
    }

    /// @notice Get all authorized sources
    /// @return Array of authorized source addresses
    function getAuthorizedSources() external view returns (address[] memory) {
        return authorizedSources;
    }

    /// @notice Get logs by time range
    /// @param startTime_ The start time
    /// @param endTime_ The end time
    /// @param offset_ The offset
    /// @param limit_ The limit
    /// @return Array of log IDs
    function getLogsByTimeRange(
        uint256 startTime_,
        uint256 endTime_,
        uint256 offset_,
        uint256 limit_
    ) external view returns (uint256[] memory) {
        // Count logs in time range
        uint256 count = 0;
        for (uint256 i = 0; i < logEntries.length; i++) {
            if (logEntries[i].timestamp >= startTime_ && logEntries[i].timestamp <= endTime_) {
                count++;
            }
        }
        
        // Calculate actual limit
        uint256 actualLimit = limit_;
        if (offset_ + actualLimit > count) {
            actualLimit = count > offset_ ? count - offset_ : 0;
        }
        
        // Create result array
        uint256[] memory result = new uint256[](actualLimit);
        
        // Fill result array
        uint256 resultIndex = 0;
        uint256 skipped = 0;
        
        for (uint256 i = 0; i < logEntries.length && resultIndex < actualLimit; i++) {
            if (logEntries[i].timestamp >= startTime_ && logEntries[i].timestamp <= endTime_) {
                if (skipped < offset_) {
                    skipped++;
                } else {
                    result[resultIndex++] = i;
                }
            }
        }
        
        return result;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Internal function to add a category
    /// @param name_ The category name
    /// @param categoryId_ The category ID
    function _addCategory(string memory name_, bytes32 categoryId_) internal {
        if (logCategories[categoryId_].exists) revert EventLogger_CategoryAlreadyExists(categoryId_);
        
        // Create category
        logCategories[categoryId_] = LogCategory({
            id: categoryId_,
            name: name_,
            exists: true
        });
        
        // Map name to ID
        categoryIdByName[name_] = categoryId_;
        
        // Add to array
        allCategories.push(categoryId_);
        
        emit LogCategoryAdded(categoryId_, name_);
    }
}