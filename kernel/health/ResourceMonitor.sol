// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Resource Monitor
/// @notice Monitors system resource usage and limits
interface IResourceMonitor {
    function recordResourceUsage(bytes32 resourceId, uint256 usage) external;
    function getResourceUsage(bytes32 resourceId) external view returns (uint256 currentUsage, uint256 limit);
    function isResourceAvailable(bytes32 resourceId, uint256 requestedAmount) external view returns (bool);
    function getResourceUtilization(bytes32 resourceId) external view returns (uint256 utilizationPercentage);
}

contract ResourceMonitor is IResourceMonitor {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ResourceRegistered(bytes32 indexed resourceId, string name, uint256 limit);
    event ResourceLimitUpdated(bytes32 indexed resourceId, uint256 oldLimit, uint256 newLimit);
    event ResourceUsageRecorded(bytes32 indexed resourceId, uint256 oldUsage, uint256 newUsage);
    event ResourceSourceAuthorized(address indexed source, bytes32[] resourceIds);
    event ResourceSourceDeauthorized(address indexed source);
    event ResourceThresholdExceeded(bytes32 indexed resourceId, uint256 usage, uint256 limit, uint256 utilizationPercentage);
    event ResourceThresholdRestored(bytes32 indexed resourceId, uint256 usage, uint256 limit, uint256 utilizationPercentage);
    event ResourceMonitorAdminChanged(address indexed oldAdmin, address indexed newAdmin);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ResourceMonitor_OnlyAdmin(address caller);
    error ResourceMonitor_OnlyAuthorizedSource(address source, bytes32 resourceId);
    error ResourceMonitor_ResourceNotRegistered(bytes32 resourceId);
    error ResourceMonitor_ResourceAlreadyRegistered(bytes32 resourceId);
    error ResourceMonitor_InvalidAddress(address addr);
    error ResourceMonitor_InvalidLimit(uint256 limit);
    error ResourceMonitor_ResourceLimitExceeded(bytes32 resourceId, uint256 requested, uint256 available);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct ResourceData {
        bytes32 id;
        string name;
        uint256 limit;
        uint256 currentUsage;
        bool isRegistered;
        bool thresholdExceeded;
        uint256 warningThreshold; // Percentage (0-100) of limit that triggers warning
    }

    struct ResourceSource {
        address source;
        bytes32[] authorizedResources;
        bool isAuthorized;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    
    // Resources
    mapping(bytes32 => ResourceData) public resources;
    bytes32[] public registeredResources;
    
    // Authorized sources
    mapping(address => ResourceSource) public resourceSources;
    mapping(bytes32 => mapping(address => bool)) public isAuthorizedForResource;
    address[] public authorizedSources;
    
    // Default warning threshold (80%)
    uint256 public defaultWarningThreshold = 80;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ResourceMonitor_OnlyAdmin(msg.sender);
        _;
    }

    modifier resourceRegistered(bytes32 resourceId) {
        if (!resources[resourceId].isRegistered) {
            revert ResourceMonitor_ResourceNotRegistered(resourceId);
        }
        _;
    }

    modifier onlyAuthorizedSource(bytes32 resourceId) {
        if (!isAuthorizedForResource[resourceId][msg.sender] && msg.sender != admin) {
            revert ResourceMonitor_OnlyAuthorizedSource(msg.sender, resourceId);
        }
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        if (admin_ == address(0)) revert ResourceMonitor_InvalidAddress(admin_);
        
        admin = admin_;
        
        // Initialize default resources
        _registerResourceInternal(keccak256(abi.encodePacked("STORAGE")), string(abi.encodePacked("Contract storage usage")), 10000000); // 10MB in bytes
        _registerResourceInternal(keccak256(abi.encodePacked("MEMORY")), string(abi.encodePacked("Contract memory usage")), 1000000); // 1MB in bytes
        _registerResourceInternal(keccak256(abi.encodePacked("COMPUTATION")), string(abi.encodePacked("Computational resources")), 1000000); // Arbitrary units
        _registerResourceInternal(keccak256(abi.encodePacked("BANDWIDTH")), string(abi.encodePacked("Network bandwidth")), 1000000); // Bytes per second
        _registerResourceInternal(keccak256(abi.encodePacked("CONNECTIONS")), string(abi.encodePacked("Active connections")), 1000); // Number of connections
        
        // Authorize admin for all resources
        bytes32[] memory allResources = new bytes32[](5);
        allResources[0] = keccak256(abi.encodePacked("STORAGE"));
        allResources[1] = keccak256(abi.encodePacked("MEMORY"));
        allResources[2] = keccak256(abi.encodePacked("COMPUTATION"));
        allResources[3] = keccak256(abi.encodePacked("BANDWIDTH"));
        allResources[4] = keccak256(abi.encodePacked("CONNECTIONS"));
        
        _authorizeSource(admin_, allResources);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Record resource usage
    /// @param resourceId The resource ID
    /// @param usage The current usage
    function recordResourceUsage(
        bytes32 resourceId,
        uint256 usage
    ) external override onlyAuthorizedSource(resourceId) resourceRegistered(resourceId) {
        ResourceData storage resource = resources[resourceId];
        uint256 oldUsage = resource.currentUsage;
        resource.currentUsage = usage;
        
        // Check if warning threshold is exceeded
        uint256 utilizationPercentage = (usage * 100) / resource.limit;
        
        if (utilizationPercentage >= resource.warningThreshold && !resource.thresholdExceeded) {
            // Threshold newly exceeded
            resource.thresholdExceeded = true;
            emit ResourceThresholdExceeded(resourceId, usage, resource.limit, utilizationPercentage);
        } else if (utilizationPercentage < resource.warningThreshold && resource.thresholdExceeded) {
            // Threshold no longer exceeded
            resource.thresholdExceeded = false;
            emit ResourceThresholdRestored(resourceId, usage, resource.limit, utilizationPercentage);
        }
        
        emit ResourceUsageRecorded(resourceId, oldUsage, usage);
    }

    /// @notice Register a new resource
    /// @param resourceId The resource ID
    /// @param name The resource name
    /// @param limit The resource limit
    function registerResource(
        bytes32 resourceId,
        string calldata name,
        uint256 limit
    ) external onlyAdmin {
        _registerResourceInternal(resourceId, name, limit);
    }

    /// @notice Update a resource's limit
    /// @param resourceId The resource ID
    /// @param newLimit The new limit
    function updateResourceLimit(
        bytes32 resourceId,
        uint256 newLimit
    ) external onlyAdmin resourceRegistered(resourceId) {
        if (newLimit == 0) revert ResourceMonitor_InvalidLimit(newLimit);
        
        ResourceData storage resource = resources[resourceId];
        uint256 oldLimit = resource.limit;
        resource.limit = newLimit;
        
        // Check if warning threshold status changed
        uint256 utilizationPercentage = (resource.currentUsage * 100) / newLimit;
        
        if (utilizationPercentage >= resource.warningThreshold && !resource.thresholdExceeded) {
            // Threshold newly exceeded
            resource.thresholdExceeded = true;
            emit ResourceThresholdExceeded(resourceId, resource.currentUsage, newLimit, utilizationPercentage);
        } else if (utilizationPercentage < resource.warningThreshold && resource.thresholdExceeded) {
            // Threshold no longer exceeded
            resource.thresholdExceeded = false;
            emit ResourceThresholdRestored(resourceId, resource.currentUsage, newLimit, utilizationPercentage);
        }
        
        emit ResourceLimitUpdated(resourceId, oldLimit, newLimit);
    }

    /// @notice Set warning threshold for a resource
    /// @param resourceId The resource ID
    /// @param warningThreshold The warning threshold percentage (0-100)
    function setResourceWarningThreshold(
        bytes32 resourceId,
        uint256 warningThreshold
    ) external onlyAdmin resourceRegistered(resourceId) {
        if (warningThreshold > 100) revert ResourceMonitor_InvalidLimit(warningThreshold);
        
        resources[resourceId].warningThreshold = warningThreshold;
    }

    /// @notice Set default warning threshold for new resources
    /// @param warningThreshold The warning threshold percentage (0-100)
    function setDefaultWarningThreshold(
        uint256 warningThreshold
    ) external onlyAdmin {
        if (warningThreshold > 100) revert ResourceMonitor_InvalidLimit(warningThreshold);
        
        defaultWarningThreshold = warningThreshold;
    }

    /// @notice Authorize a source for specific resources
    /// @param source The source address
    /// @param resourceIds The resource IDs
    function authorizeSource(
        address source,
        bytes32[] calldata resourceIds
    ) external onlyAdmin {
        _authorizeSource(source, resourceIds);
    }

    /// @notice Deauthorize a source
    /// @param source The source address
    function deauthorizeSource(address source) external onlyAdmin {
        if (source == admin) revert ResourceMonitor_InvalidAddress(source); // Can't deauthorize admin
        if (!resourceSources[source].isAuthorized) return; // Not authorized
        
        // Remove authorization for all resources
        bytes32[] storage authorizedResources = resourceSources[source].authorizedResources;
        for (uint256 i = 0; i < authorizedResources.length; i++) {
            isAuthorizedForResource[authorizedResources[i]][source] = false;
        }
        
        // Clear source data
        delete resourceSources[source];
        
        // Remove from authorized sources array
        for (uint256 i = 0; i < authorizedSources.length; i++) {
            if (authorizedSources[i] == source) {
                authorizedSources[i] = authorizedSources[authorizedSources.length - 1];
                authorizedSources.pop();
                break;
            }
        }
        
        emit ResourceSourceDeauthorized(source);
    }

    /// @notice Change the admin
    /// @param newAdmin The new admin address
    function changeAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert ResourceMonitor_InvalidAddress(newAdmin);
        
        address oldAdmin = admin;
        admin = newAdmin;
        
        // Authorize new admin for all resources if not already authorized
        if (!resourceSources[newAdmin].isAuthorized) {
            _authorizeSource(newAdmin, registeredResources);
        }
        
        emit ResourceMonitorAdminChanged(oldAdmin, newAdmin);
    }

    /// @notice Get resource usage and limit
    /// @param resourceId The resource ID
    /// @return currentUsage The current usage
    /// @return limit The resource limit
    function getResourceUsage(
        bytes32 resourceId
    ) external view override resourceRegistered(resourceId) returns (uint256 currentUsage, uint256 limit) {
        ResourceData storage resource = resources[resourceId];
        return (resource.currentUsage, resource.limit);
    }

    /// @notice Check if a resource is available for a requested amount
    /// @param resourceId The resource ID
    /// @param requestedAmount The requested amount
    /// @return Whether the resource is available
    function isResourceAvailable(
        bytes32 resourceId,
        uint256 requestedAmount
    ) external view override resourceRegistered(resourceId) returns (bool) {
        ResourceData storage resource = resources[resourceId];
        return resource.currentUsage + requestedAmount <= resource.limit;
    }

    /// @notice Get resource utilization percentage
    /// @param resourceId The resource ID
    /// @return utilizationPercentage The utilization percentage (0-100)
    function getResourceUtilization(
        bytes32 resourceId
    ) external view override resourceRegistered(resourceId) returns (uint256 utilizationPercentage) {
        ResourceData storage resource = resources[resourceId];
        if (resource.limit == 0) return 0;
        return (resource.currentUsage * 100) / resource.limit;
    }

    /// @notice Get resource details
    /// @param resourceId The resource ID
    /// @return id The resource ID
    /// @return name The resource name
    /// @return limit The resource limit
    /// @return currentUsage The current usage
    /// @return isRegistered Whether the resource is registered
    /// @return thresholdExceeded Whether the warning threshold is exceeded
    /// @return warningThreshold The warning threshold percentage
    function getResourceDetails(bytes32 resourceId) external view returns (
        bytes32 id,
        string memory name,
        uint256 limit,
        uint256 currentUsage,
        bool isRegistered,
        bool thresholdExceeded,
        uint256 warningThreshold
    ) {
        ResourceData storage resource = resources[resourceId];
        return (
            resource.id,
            resource.name,
            resource.limit,
            resource.currentUsage,
            resource.isRegistered,
            resource.thresholdExceeded,
            resource.warningThreshold
        );
    }

    /// @notice Get all registered resources
    /// @return Array of resource IDs
    function getRegisteredResources() external view returns (bytes32[] memory) {
        return registeredResources;
    }

    /// @notice Get all authorized sources
    /// @return Array of source addresses
    function getAuthorizedSources() external view returns (address[] memory) {
        return authorizedSources;
    }

    /// @notice Get resources authorized for a source
    /// @param source The source address
    /// @return Array of resource IDs
    function getAuthorizedResourcesForSource(address source) external view returns (bytes32[] memory) {
        return resourceSources[source].authorizedResources;
    }

    /// @notice Get resources with exceeded thresholds
    /// @return Array of resource IDs
    function getResourcesWithExceededThresholds() external view returns (bytes32[] memory) {
        uint256 count = 0;
        
        // Count resources with exceeded thresholds
        for (uint256 i = 0; i < registeredResources.length; i++) {
            if (resources[registeredResources[i]].thresholdExceeded) {
                count++;
            }
        }
        
        // Create result array
        bytes32[] memory result = new bytes32[](count);
        uint256 resultIndex = 0;
        
        // Fill result array
        for (uint256 i = 0; i < registeredResources.length && resultIndex < count; i++) {
            if (resources[registeredResources[i]].thresholdExceeded) {
                result[resultIndex++] = registeredResources[i];
            }
        }
        
        return result;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _registerResourceInternal(
        bytes32 resourceId,
        string memory name,
        uint256 limit
    ) internal onlyAdmin {
        if (resources[resourceId].isRegistered) {
            revert ResourceMonitor_ResourceAlreadyRegistered(resourceId);
        }

        resources[resourceId] = ResourceData({
            id: resourceId,
            name: name,
            limit: limit,
            currentUsage: 0,
            isRegistered: true,
            thresholdExceeded: false,
            warningThreshold: defaultWarningThreshold
        });
        registeredResources.push(resourceId);
        emit ResourceRegistered(resourceId, name, limit);
    }

    /// @notice Internal function to authorize a source for resources
    /// @param source The source address
    /// @param resourceIds The resource IDs
    function _authorizeSource(
        address source,
        bytes32[] memory resourceIds
    ) internal {
        if (source == address(0)) revert ResourceMonitor_InvalidAddress(source);
        
        // Create or update source data
        if (!resourceSources[source].isAuthorized) {
            resourceSources[source].source = source;
            resourceSources[source].isAuthorized = true;
            authorizedSources.push(source);
        }
        
        // Authorize for each resource
        for (uint256 i = 0; i < resourceIds.length; i++) {
            bytes32 resourceId = resourceIds[i];
            
            if (!resources[resourceId].isRegistered) {
                revert ResourceMonitor_ResourceNotRegistered(resourceId);
            }
            
            if (!isAuthorizedForResource[resourceId][source]) {
                isAuthorizedForResource[resourceId][source] = true;
                resourceSources[source].authorizedResources.push(resourceId);
            }
        }
        
        emit ResourceSourceAuthorized(source, resourceIds);
    }
}