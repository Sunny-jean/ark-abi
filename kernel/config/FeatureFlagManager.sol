// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Feature Flag Manager
/// @notice Manages feature flags for enabling/disabling system features
interface IFeatureFlagManager {
    function isFeatureEnabled(bytes32 featureId) external view returns (bool);
    function enableFeature(bytes32 featureId) external;
    function disableFeature(bytes32 featureId) external;
}

contract FeatureFlagManager is IFeatureFlagManager {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event FeatureCreated(bytes32 indexed featureId, string name, string description);
    event FeatureEnabled(bytes32 indexed featureId);
    event FeatureDisabled(bytes32 indexed featureId);
    event FeatureRemoved(bytes32 indexed featureId);
    event FeatureDependencyAdded(bytes32 indexed featureId, bytes32 indexed dependencyId);
    event FeatureDependencyRemoved(bytes32 indexed featureId, bytes32 indexed dependencyId);
    event FeatureGroupCreated(bytes32 indexed groupId, string name);
    event FeatureAddedToGroup(bytes32 indexed featureId, bytes32 indexed groupId);
    event FeatureRemovedFromGroup(bytes32 indexed featureId, bytes32 indexed groupId);
    event FeatureGroupRemoved(bytes32 indexed groupId);
    event FeatureFlagManagerAdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event FeatureFlagManagerAuthorizedAddressAdded(address indexed addr);
    event FeatureFlagManagerAuthorizedAddressRemoved(address indexed addr);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error FeatureFlagManager_OnlyAdmin(address caller);
    error FeatureFlagManager_OnlyAuthorized(address caller);
    error FeatureFlagManager_InvalidAddress(address addr);
    error FeatureFlagManager_FeatureNotFound(bytes32 featureId);
    error FeatureFlagManager_FeatureAlreadyExists(bytes32 featureId);
    error FeatureFlagManager_FeatureGroupNotFound(bytes32 groupId);
    error FeatureFlagManager_FeatureGroupAlreadyExists(bytes32 groupId);
    error FeatureFlagManager_DependencyNotFound(bytes32 dependencyId);
    error FeatureFlagManager_CircularDependency(bytes32 featureId, bytes32 dependencyId);
    error FeatureFlagManager_DependencyDisabled(bytes32 featureId, bytes32 dependencyId);
    error FeatureFlagManager_DependentFeaturesEnabled(bytes32 featureId);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct Feature {
        bytes32 id;
        string name;
        string description;
        bool enabled;
        bytes32[] dependencies;
        bytes32[] dependents;
        bytes32[] groups;
        uint256 lastUpdated;
        bool exists;
    }

    struct FeatureGroup {
        bytes32 id;
        string name;
        bytes32[] features;
        bool exists;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    
    // Features
    mapping(bytes32 => Feature) public features;
    bytes32[] public featureIds;
    
    // Feature groups
    mapping(bytes32 => FeatureGroup) public featureGroups;
    bytes32[] public featureGroupIds;
    
    // Access control
    mapping(address => bool) public authorizedAddresses;
    address[] public authorizedAddressList;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert FeatureFlagManager_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyAuthorized() {
        if (msg.sender != admin && !authorizedAddresses[msg.sender]) {
            revert FeatureFlagManager_OnlyAuthorized(msg.sender);
        }
        _;
    }

    modifier featureExists(bytes32 featureId) {
        if (!features[featureId].exists) revert FeatureFlagManager_FeatureNotFound(featureId);
        _;
    }

    modifier featureGroupExists(bytes32 groupId) {
        if (!featureGroups[groupId].exists) revert FeatureFlagManager_FeatureGroupNotFound(groupId);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        if (admin_ == address(0)) revert FeatureFlagManager_InvalidAddress(admin_);
        
        admin = admin_;
        authorizedAddresses[admin_] = true;
        authorizedAddressList.push(admin_);
        
        // Create default feature groups
        _createFeatureGroup(keccak256(abi.encodePacked("CORE")), "Core system features");
        _createFeatureGroup(keccak256(abi.encodePacked("SECURITY")), "Security-related features");
        _createFeatureGroup(keccak256(abi.encodePacked("ADVANCED")), "Advanced features");
        _createFeatureGroup(keccak256(abi.encodePacked("EXPERIMENTAL")), "Experimental features");
        
        // Create default features
        _createFeature(
            "SYSTEM_CORE",
            "System Core",
            "Core system functionality",
            true,
            new bytes32[](0)
        );
        
        _createFeature(
            "ADVANCED_TRADING",
            "Advanced Trading",
            "Advanced trading functionality",
            false,
            new bytes32[](0)
        );
        
        _createFeature(
            "SECURITY_AUDIT_TRAIL",
            "Security Audit Trail",
            "Security audit trail functionality",
            true,
            new bytes32[](0)
        );
        
        _createFeature(
            "EXPERIMENTAL_AI",
            "Experimental AI",
            "Experimental AI functionality",
            false,
            new bytes32[](0)
        );
        
        // Add features to groups
        _addFeatureToGroup(keccak256(abi.encodePacked("SYSTEM_CORE")), keccak256(abi.encodePacked("CORE")));
        _addFeatureToGroup(keccak256(abi.encodePacked("ADVANCED_TRADING")), keccak256(abi.encodePacked("ADVANCED")));
        _addFeatureToGroup(keccak256(abi.encodePacked("SECURITY_AUDIT_TRAIL")), keccak256(abi.encodePacked("SECURITY")));
        _addFeatureToGroup(keccak256(abi.encodePacked("EXPERIMENTAL_AI")), keccak256(abi.encodePacked("EXPERIMENTAL")));
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Check if a feature is enabled
    /// @param featureId The feature ID
    /// @return Whether the feature is enabled
    function isFeatureEnabled(
        bytes32 featureId
    ) external view override featureExists(featureId) returns (bool) {
        return features[featureId].enabled;
    }

    /// @notice Enable a feature
    /// @param featureId The feature ID
    function enableFeature(
        bytes32 featureId
    ) external override onlyAuthorized featureExists(featureId) {
        Feature storage feature = features[featureId];
        if (feature.enabled) return; // Already enabled
        
        // Check dependencies
        for (uint256 i = 0; i < feature.dependencies.length; i++) {
            bytes32 dependencyId = feature.dependencies[i];
            if (!features[dependencyId].enabled) {
                revert FeatureFlagManager_DependencyDisabled(featureId, dependencyId);
            }
        }
        
        feature.enabled = true;
        feature.lastUpdated = block.timestamp;
        
        emit FeatureEnabled(featureId);
    }

    /// @notice Disable a feature
    /// @param featureId The feature ID
    function disableFeature(
        bytes32 featureId
    ) external override onlyAuthorized featureExists(featureId) {
        Feature storage feature = features[featureId];
        if (!feature.enabled) return; // Already disabled
        
        // Check dependents
        for (uint256 i = 0; i < feature.dependents.length; i++) {
            bytes32 dependentId = feature.dependents[i];
            if (features[dependentId].enabled) {
                revert FeatureFlagManager_DependentFeaturesEnabled(featureId);
            }
        }
        
        feature.enabled = false;
        feature.lastUpdated = block.timestamp;
        
        emit FeatureDisabled(featureId);
    }

    /// @notice Create a new feature
    /// @param featureId The feature ID
    /// @param name The feature name
    /// @param description The feature description
    /// @param enabled Whether the feature is enabled
    /// @param dependencies The feature dependencies
    function createFeature(
        bytes32 featureId,
        string calldata name,
        string calldata description,
        bool enabled,
        bytes32[] calldata dependencies
    ) external onlyAdmin {
        _createFeature(featureId, name, description, enabled, dependencies);
    }

    /// @notice Create a new feature by string ID
    /// @param featureId The feature ID string
    /// @param name The feature name
    /// @param description The feature description
    /// @param enabled Whether the feature is enabled
    /// @param dependencies The feature dependencies
    function createFeature(
        string calldata featureId,
        string calldata name,
        string calldata description,
        bool enabled,
        bytes32[] calldata dependencies
    ) external onlyAdmin {
        _createFeature(keccak256(bytes(featureId)), name, description, enabled, dependencies);
    }

    /// @notice Remove a feature
    /// @param featureId The feature ID
    function removeFeature(bytes32 featureId) external onlyAdmin featureExists(featureId) {
        Feature storage feature = features[featureId];
        
        // Check dependents
        if (feature.dependents.length > 0) {
            revert FeatureFlagManager_DependentFeaturesEnabled(featureId);
        }
        
        // Remove from dependencies' dependents
        for (uint256 i = 0; i < feature.dependencies.length; i++) {
            bytes32 dependencyId = feature.dependencies[i];
            Feature storage dependency = features[dependencyId];
            
            for (uint256 j = 0; j < dependency.dependents.length; j++) {
                if (dependency.dependents[j] == featureId) {
                    dependency.dependents[j] = dependency.dependents[dependency.dependents.length - 1];
                    dependency.dependents.pop();
                    break;
                }
            }
        }
        
        // Remove from groups
        for (uint256 i = 0; i < feature.groups.length; i++) {
            bytes32 groupId = feature.groups[i];
            FeatureGroup storage group = featureGroups[groupId];
            
            for (uint256 j = 0; j < group.features.length; j++) {
                if (group.features[j] == featureId) {
                    group.features[j] = group.features[group.features.length - 1];
                    group.features.pop();
                    break;
                }
            }
        }
        
        // Remove from feature IDs
        for (uint256 i = 0; i < featureIds.length; i++) {
            if (featureIds[i] == featureId) {
                featureIds[i] = featureIds[featureIds.length - 1];
                featureIds.pop();
                break;
            }
        }
        
        // Delete feature
        delete features[featureId];
        
        emit FeatureRemoved(featureId);
    }

    /// @notice Add a dependency to a feature
    /// @param featureId The feature ID
    /// @param dependencyId The dependency ID
    function addFeatureDependency(
        bytes32 featureId,
        bytes32 dependencyId
    ) external onlyAdmin featureExists(featureId) featureExists(dependencyId) {
        if (featureId == dependencyId) {
            revert FeatureFlagManager_CircularDependency(featureId, dependencyId);
        }
        
        Feature storage feature = features[featureId];
        Feature storage dependency = features[dependencyId];
        
        // Check for circular dependency
        if (_hasCircularDependency(dependencyId, featureId)) {
            revert FeatureFlagManager_CircularDependency(featureId, dependencyId);
        }
        
        // Check if dependency already exists
        for (uint256 i = 0; i < feature.dependencies.length; i++) {
            if (feature.dependencies[i] == dependencyId) return; // Already a dependency
        }
        
        // Add dependency
        feature.dependencies.push(dependencyId);
        dependency.dependents.push(featureId);
        
        // If feature is enabled, ensure dependency is enabled
        if (feature.enabled && !dependency.enabled) {
            revert FeatureFlagManager_DependencyDisabled(featureId, dependencyId);
        }
        
        emit FeatureDependencyAdded(featureId, dependencyId);
    }

    /// @notice Remove a dependency from a feature
    /// @param featureId The feature ID
    /// @param dependencyId The dependency ID
    function removeFeatureDependency(
        bytes32 featureId,
        bytes32 dependencyId
    ) external onlyAdmin featureExists(featureId) featureExists(dependencyId) {
        Feature storage feature = features[featureId];
        Feature storage dependency = features[dependencyId];
        
        // Remove dependency from feature
        bool found = false;
        for (uint256 i = 0; i < feature.dependencies.length; i++) {
            if (feature.dependencies[i] == dependencyId) {
                feature.dependencies[i] = feature.dependencies[feature.dependencies.length - 1];
                feature.dependencies.pop();
                found = true;
                break;
            }
        }
        
        if (!found) return; // Dependency not found
        
        // Remove feature from dependency's dependents
        for (uint256 i = 0; i < dependency.dependents.length; i++) {
            if (dependency.dependents[i] == featureId) {
                dependency.dependents[i] = dependency.dependents[dependency.dependents.length - 1];
                dependency.dependents.pop();
                break;
            }
        }
        
        emit FeatureDependencyRemoved(featureId, dependencyId);
    }

    /// @notice Create a new feature group
    /// @param groupId The group ID
    /// @param name The group name
    function createFeatureGroup(
        bytes32 groupId,
        string calldata name
    ) external onlyAdmin {
        _createFeatureGroup(groupId, name);
    }

    /// @notice Create a new feature group by string ID
    /// @param groupId The group ID string
    /// @param name The group name
    function createFeatureGroup(
        string calldata groupId,
        string calldata name
    ) external onlyAdmin {
        _createFeatureGroup(keccak256(bytes(groupId)), name);
    }

    /// @notice Add a feature to a group
    /// @param featureId The feature ID
    /// @param groupId The group ID
    function addFeatureToGroup(
        bytes32 featureId,
        bytes32 groupId
    ) external onlyAdmin featureExists(featureId) featureGroupExists(groupId) {
        _addFeatureToGroup(featureId, groupId);
    }

    /// @notice Remove a feature from a group
    /// @param featureId The feature ID
    /// @param groupId The group ID
    function removeFeatureFromGroup(
        bytes32 featureId,
        bytes32 groupId
    ) external onlyAdmin featureExists(featureId) featureGroupExists(groupId) {
        Feature storage feature = features[featureId];
        FeatureGroup storage group = featureGroups[groupId];
        
        // Remove group from feature
        bool foundInFeature = false;
        for (uint256 i = 0; i < feature.groups.length; i++) {
            if (feature.groups[i] == groupId) {
                feature.groups[i] = feature.groups[feature.groups.length - 1];
                feature.groups.pop();
                foundInFeature = true;
                break;
            }
        }
        
        // Remove feature from group
        bool foundInGroup = false;
        for (uint256 i = 0; i < group.features.length; i++) {
            if (group.features[i] == featureId) {
                group.features[i] = group.features[group.features.length - 1];
                group.features.pop();
                foundInGroup = true;
                break;
            }
        }
        
        if (foundInFeature || foundInGroup) {
            emit FeatureRemovedFromGroup(featureId, groupId);
        }
    }

    /// @notice Remove a feature group
    /// @param groupId The group ID
    function removeFeatureGroup(bytes32 groupId) external onlyAdmin featureGroupExists(groupId) {
        FeatureGroup storage group = featureGroups[groupId];
        
        // Remove group from all features
        for (uint256 i = 0; i < group.features.length; i++) {
            bytes32 featureId = group.features[i];
            Feature storage feature = features[featureId];
            
            for (uint256 j = 0; j < feature.groups.length; j++) {
                if (feature.groups[j] == groupId) {
                    feature.groups[j] = feature.groups[feature.groups.length - 1];
                    feature.groups.pop();
                    break;
                }
            }
        }
        
        // Remove from group IDs
        for (uint256 i = 0; i < featureGroupIds.length; i++) {
            if (featureGroupIds[i] == groupId) {
                featureGroupIds[i] = featureGroupIds[featureGroupIds.length - 1];
                featureGroupIds.pop();
                break;
            }
        }
        
        // Delete group
        delete featureGroups[groupId];
        
        emit FeatureGroupRemoved(groupId);
    }

    /// @notice Enable all features in a group
    /// @param groupId The group ID
    function enableFeatureGroup(bytes32 groupId) external onlyAuthorized featureGroupExists(groupId) {
        FeatureGroup storage group = featureGroups[groupId];
        
        for (uint256 i = 0; i < group.features.length; i++) {
            bytes32 featureId = group.features[i];
            Feature storage feature = features[featureId];
            
            if (!feature.enabled) {
                // Check dependencies
                bool dependenciesEnabled = true;
                for (uint256 j = 0; j < feature.dependencies.length; j++) {
                    if (!features[feature.dependencies[j]].enabled) {
                        dependenciesEnabled = false;
                        break;
                    }
                }
                
                if (dependenciesEnabled) {
                    feature.enabled = true;
                    feature.lastUpdated = block.timestamp;
                    emit FeatureEnabled(featureId);
                }
            }
        }
    }

    /// @notice Disable all features in a group
    /// @param groupId The group ID
    function disableFeatureGroup(bytes32 groupId) external onlyAuthorized featureGroupExists(groupId) {
        FeatureGroup storage group = featureGroups[groupId];
        
        // First, check if any feature in the group has dependents outside the group
        for (uint256 i = 0; i < group.features.length; i++) {
            bytes32 featureId = group.features[i];
            Feature storage feature = features[featureId];
            
            if (feature.enabled) {
                for (uint256 j = 0; j < feature.dependents.length; j++) {
                    bytes32 dependentId = feature.dependents[j];
                    
                    // Check if dependent is enabled and not in the group
                    if (features[dependentId].enabled) {
                        bool dependentInGroup = false;
                        for (uint256 k = 0; k < group.features.length; k++) {
                            if (group.features[k] == dependentId) {
                                dependentInGroup = true;
                                break;
                            }
                        }
                        
                        if (!dependentInGroup) {
                            revert FeatureFlagManager_DependentFeaturesEnabled(featureId);
                        }
                    }
                }
            }
        }
        
        // Disable all features in the group
        for (uint256 i = 0; i < group.features.length; i++) {
            bytes32 featureId = group.features[i];
            Feature storage feature = features[featureId];
            
            if (feature.enabled) {
                feature.enabled = false;
                feature.lastUpdated = block.timestamp;
                emit FeatureDisabled(featureId);
            }
        }
    }

    /// @notice Add an authorized address
    /// @param addr The address to authorize
    function addAuthorizedAddress(address addr) external onlyAdmin {
        if (addr == address(0)) revert FeatureFlagManager_InvalidAddress(addr);
        if (authorizedAddresses[addr]) return; // Already authorized
        
        authorizedAddresses[addr] = true;
        authorizedAddressList.push(addr);
        
        emit FeatureFlagManagerAuthorizedAddressAdded(addr);
    }

    /// @notice Remove an authorized address
    /// @param addr The address to deauthorize
    function removeAuthorizedAddress(address addr) external onlyAdmin {
        if (!authorizedAddresses[addr]) return; // Not authorized
        if (addr == admin) revert FeatureFlagManager_InvalidAddress(addr); // Cannot remove admin
        
        authorizedAddresses[addr] = false;
        
        // Remove from authorized address list
        for (uint256 i = 0; i < authorizedAddressList.length; i++) {
            if (authorizedAddressList[i] == addr) {
                authorizedAddressList[i] = authorizedAddressList[authorizedAddressList.length - 1];
                authorizedAddressList.pop();
                break;
            }
        }
        
        emit FeatureFlagManagerAuthorizedAddressRemoved(addr);
    }

    /// @notice Change the admin
    /// @param newAdmin The new admin address
    function changeAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert FeatureFlagManager_InvalidAddress(newAdmin);
        
        address oldAdmin = admin;
        admin = newAdmin;
        
        // Authorize new admin if not already authorized
        if (!authorizedAddresses[newAdmin]) {
            authorizedAddresses[newAdmin] = true;
            authorizedAddressList.push(newAdmin);
            emit FeatureFlagManagerAuthorizedAddressAdded(newAdmin);
        }
        
        emit FeatureFlagManagerAdminChanged(oldAdmin, newAdmin);
    }

    /// @notice Get all feature IDs
    /// @return Array of feature IDs
    function getAllFeatureIds() external view returns (bytes32[] memory) {
        return featureIds;
    }

    /// @notice Get all feature group IDs
    /// @return Array of feature group IDs
    function getAllFeatureGroupIds() external view returns (bytes32[] memory) {
        return featureGroupIds;
    }

    /// @notice Get all authorized addresses
    /// @return Array of authorized addresses
    function getAllAuthorizedAddresses() external view returns (address[] memory) {
        return authorizedAddressList;
    }

    /// @notice Get features in a group
    /// @param groupId The group ID
    /// @return Array of feature IDs
    function getGroupFeatures(bytes32 groupId) external view featureGroupExists(groupId) returns (bytes32[] memory) {
        return featureGroups[groupId].features;
    }

    /// @notice Get feature details
    /// @param featureId The feature ID
    /// @return id The feature ID
    /// @return name The feature name
    /// @return description The feature description
    /// @return enabled Whether the feature is enabled
    /// @return dependencies The feature dependencies
    /// @return dependents The feature dependents
    /// @return groups The feature groups
    /// @return lastUpdated The last updated timestamp
    /// @return exists Whether the feature exists
    function getFeatureDetails(bytes32 featureId) external view featureExists(featureId) returns (
        bytes32,
        string memory,
        string memory,
        bool,
        bytes32[] memory,
        bytes32[] memory,
        bytes32[] memory,
        uint256,
        bool
    ) {
        Feature storage feature = features[featureId];
        return (
            feature.id,
            feature.name,
            feature.description,
            feature.enabled,
            feature.dependencies,
            feature.dependents,
            feature.groups,
            feature.lastUpdated,
            feature.exists
        );
    }

    /// @notice Get feature group details
    /// @param groupId The group ID
    /// @return id The group ID
    /// @return name The group name
    /// @return features The features in the group
    /// @return exists Whether the group exists
    function getFeatureGroupDetails(bytes32 groupId) external view featureGroupExists(groupId) returns (
        bytes32,
        string memory,
        bytes32[] memory,
        bool
    ) {
        FeatureGroup storage group = featureGroups[groupId];
        return (
            group.id,
            group.name,
            group.features,
            group.exists
        );
    }

    /// @notice Get all enabled features
    /// @return Array of enabled feature IDs
    function getEnabledFeatures() external view returns (bytes32[] memory) {
        uint256 count = 0;
        
        // Count enabled features
        for (uint256 i = 0; i < featureIds.length; i++) {
            if (features[featureIds[i]].enabled) {
                count++;
            }
        }
        
        // Create result array
        bytes32[] memory result = new bytes32[](count);
        uint256 resultIndex = 0;
        
        // Fill result array
        for (uint256 i = 0; i < featureIds.length && resultIndex < count; i++) {
            if (features[featureIds[i]].enabled) {
                result[resultIndex++] = featureIds[i];
            }
        }
        
        return result;
    }

    /// @notice Get all disabled features
    /// @return Array of disabled feature IDs
    function getDisabledFeatures() external view returns (bytes32[] memory) {
        uint256 count = 0;
        
        // Count disabled features
        for (uint256 i = 0; i < featureIds.length; i++) {
            if (!features[featureIds[i]].enabled) {
                count++;
            }
        }
        
        // Create result array
        bytes32[] memory result = new bytes32[](count);
        uint256 resultIndex = 0;
        
        // Fill result array
        for (uint256 i = 0; i < featureIds.length && resultIndex < count; i++) {
            if (!features[featureIds[i]].enabled) {
                result[resultIndex++] = featureIds[i];
            }
        }
        
        return result;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Internal function to create a feature
    /// @param featureId The feature ID
    /// @param name The feature name
    /// @param description The feature description
    /// @param enabled Whether the feature is enabled
    /// @param dependencies The feature dependencies
    function _createFeature(
        bytes32 featureId,
        string memory name,
        string memory description,
        bool enabled,
        bytes32[] memory dependencies
    ) internal {
        if (features[featureId].exists) {
            revert FeatureFlagManager_FeatureAlreadyExists(featureId);
        }
        
        // Check dependencies
        for (uint256 i = 0; i < dependencies.length; i++) {
            bytes32 dependencyId = dependencies[i];
            
            if (!features[dependencyId].exists) {
                revert FeatureFlagManager_DependencyNotFound(dependencyId);
            }
            
            // If feature is enabled, ensure dependency is enabled
            if (enabled && !features[dependencyId].enabled) {
                revert FeatureFlagManager_DependencyDisabled(featureId, dependencyId);
            }
        }
        
        // Create feature
        features[featureId] = Feature({
            id: featureId,
            name: name,
            description: description,
            enabled: enabled,
            dependencies: new bytes32[](0),
            dependents: new bytes32[](0),
            groups: new bytes32[](0),
            lastUpdated: block.timestamp,
            exists: true
        });
        
        featureIds.push(featureId);
        
        // Add dependencies
        for (uint256 i = 0; i < dependencies.length; i++) {
            bytes32 dependencyId = dependencies[i];
            features[featureId].dependencies.push(dependencyId);
            features[dependencyId].dependents.push(featureId);
        }
        
        emit FeatureCreated(featureId, name, description);
        
        if (enabled) {
            emit FeatureEnabled(featureId);
        }
    }

    /// @notice Internal function to create a feature group
    /// @param groupId The group ID
    /// @param name The group name
    function _createFeatureGroup(bytes32 groupId, string memory name) internal {
        if (featureGroups[groupId].exists) {
            revert FeatureFlagManager_FeatureGroupAlreadyExists(groupId);
        }
        
        featureGroups[groupId] = FeatureGroup({
            id: groupId,
            name: name,
            features: new bytes32[](0),
            exists: true
        });
        
        featureGroupIds.push(groupId);
        
        emit FeatureGroupCreated(groupId, name);
    }

    /// @notice Internal function to create a feature group by string
    /// @param groupId The group ID string
    /// @param name The group name
    function _createFeatureGroup(string memory groupId, string memory name) internal {
        _createFeatureGroup(keccak256(bytes(groupId)), name);
    }

    /// @notice Internal function to add a feature to a group
    /// @param featureId The feature ID
    /// @param groupId The group ID
    function _addFeatureToGroup(bytes32 featureId, bytes32 groupId) internal {
        Feature storage feature = features[featureId];
        FeatureGroup storage group = featureGroups[groupId];
        
        // Check if feature is already in group
        for (uint256 i = 0; i < feature.groups.length; i++) {
            if (feature.groups[i] == groupId) return; // Already in group
        }
        
        // Add group to feature
        feature.groups.push(groupId);
        
        // Add feature to group
        group.features.push(featureId);
        
        emit FeatureAddedToGroup(featureId, groupId);
    }

    /// @notice Check if there is a circular dependency
    /// @param featureId The feature ID
    /// @param dependencyId The dependency ID
    /// @return Whether there is a circular dependency
    function _hasCircularDependency(bytes32 featureId, bytes32 dependencyId) internal view returns (bool) {
        if (featureId == dependencyId) return true;
        
        Feature storage feature = features[featureId];
        
        for (uint256 i = 0; i < feature.dependencies.length; i++) {
            if (_hasCircularDependency(feature.dependencies[i], dependencyId)) {
                return true;
            }
        }
        
        return false;
    }
}