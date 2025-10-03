// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Configuration Manager
/// @notice Manages system-wide configuration settings
interface IConfigurationManager {
    function getConfig(bytes32 key) external view returns (bytes memory);
    function getBoolConfig(bytes32 key) external view returns (bool);
    function getUintConfig(bytes32 key) external view returns (uint256);
    function getAddressConfig(bytes32 key) external view returns (address);
    function getStringConfig(bytes32 key) external view returns (string memory);
    function setConfig(bytes32 key, bytes calldata value) external;
}

contract ConfigurationManager is IConfigurationManager {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ConfigSet(bytes32 indexed key, bytes value);
    event ConfigRemoved(bytes32 indexed key);
    event ConfigNamespaceCreated(bytes32 indexed namespace, string description);
    event ConfigNamespaceRemoved(bytes32 indexed namespace);
    event ConfigManagerAdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event ConfigManagerAuthorizedAddressAdded(address indexed addr);
    event ConfigManagerAuthorizedAddressRemoved(address indexed addr);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ConfigurationManager_OnlyAdmin(address caller);
    error ConfigurationManager_OnlyAuthorized(address caller);
    error ConfigurationManager_InvalidAddress(address addr);
    error ConfigurationManager_ConfigNotFound(bytes32 key);
    error ConfigurationManager_InvalidConfigType(bytes32 key, string expectedType);
    error ConfigurationManager_NamespaceNotFound(bytes32 namespace);
    error ConfigurationManager_NamespaceAlreadyExists(bytes32 namespace);
    error ConfigurationManager_InvalidNamespace(bytes32 namespace);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct ConfigValue {
        bytes32 key;
        bytes value;
        bytes32 namespace;
        string configType; // "bool", "uint256", "address", "string", "bytes"
        uint256 lastUpdated;
        bool exists;
    }

    struct ConfigNamespace {
        bytes32 id;
        string description;
        bytes32[] configKeys;
        bool exists;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    
    // Configuration values
    mapping(bytes32 => ConfigValue) public configs;
    bytes32[] public configKeys;
    
    // Namespaces
    mapping(bytes32 => ConfigNamespace) public namespaces;
    bytes32[] public namespaceIds;
    
    // Access control
    mapping(address => bool) public authorizedAddresses;
    address[] public authorizedAddressList;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ConfigurationManager_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyAuthorized() {
        if (msg.sender != admin && !authorizedAddresses[msg.sender]) {
            revert ConfigurationManager_OnlyAuthorized(msg.sender);
        }
        _;
    }

    modifier configExists(bytes32 key) {
        if (!configs[key].exists) revert ConfigurationManager_ConfigNotFound(key);
        _;
    }

    modifier namespaceExists(bytes32 namespace) {
        if (!namespaces[namespace].exists) revert ConfigurationManager_NamespaceNotFound(namespace);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        if (admin_ == address(0)) revert ConfigurationManager_InvalidAddress(admin_);
        
        admin = admin_;
        authorizedAddresses[admin_] = true;
        authorizedAddressList.push(admin_);
        
        // Create default namespaces
        _createNamespace(keccak256(abi.encodePacked("SYSTEM")), "System-wide configuration settings");
        _createNamespace(keccak256(abi.encodePacked("SECURITY")), "Security-related configuration settings");
        _createNamespace(keccak256(abi.encodePacked("NETWORK")), "Network-related configuration settings");
        _createNamespace(keccak256(abi.encodePacked("PERFORMANCE")), "Performance-related configuration settings");
        _createNamespace(keccak256(abi.encodePacked("FEATURE_FLAGS")), "Feature flag configuration settings");
        
        // Set default configurations
        _setConfig("SYSTEM_VERSION", abi.encode("1.0.0"), keccak256(abi.encodePacked("SYSTEM")), "string");
        _setConfig("SYSTEM_ACTIVE", abi.encode(true), keccak256(abi.encodePacked("SYSTEM")), "bool");
        _setConfig("SECURITY_MIN_APPROVAL_THRESHOLD", abi.encode(uint256(3)), keccak256(abi.encodePacked("SECURITY")), "uint256");
        _setConfig("NETWORK_MAX_GAS_LIMIT", abi.encode(uint256(8000000)), keccak256(abi.encodePacked("NETWORK")), "uint256");
        _setConfig("PERFORMANCE_CACHE_TTL", abi.encode(uint256(3600)), keccak256(abi.encodePacked("PERFORMANCE")), "uint256");
        _setConfig("FEATURE_ADVANCED_TRADING", abi.encode(false), keccak256(abi.encodePacked("FEATURE_FLAGS")), "bool");
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Get configuration value
    /// @param key The configuration key
    /// @return The configuration value
    function getConfig(
        bytes32 key
    ) external view override configExists(key) returns (bytes memory) {
        return configs[key].value;
    }

    /// @notice Get boolean configuration value
    /// @param key The configuration key
    /// @return The boolean configuration value
    function getBoolConfig(
        bytes32 key
    ) external view override configExists(key) returns (bool) {
        ConfigValue storage config = configs[key];
        if (keccak256(bytes(config.configType)) != keccak256(bytes("bool"))) {
            revert ConfigurationManager_InvalidConfigType(key, "bool");
        }
        return abi.decode(config.value, (bool));
    }

    /// @notice Get uint256 configuration value
    /// @param key The configuration key
    /// @return The uint256 configuration value
    function getUintConfig(
        bytes32 key
    ) external view override configExists(key) returns (uint256) {
        ConfigValue storage config = configs[key];
        if (keccak256(bytes(config.configType)) != keccak256(bytes("uint256"))) {
            revert ConfigurationManager_InvalidConfigType(key, "uint256");
        }
        return abi.decode(config.value, (uint256));
    }

    /// @notice Get address configuration value
    /// @param key The configuration key
    /// @return The address configuration value
    function getAddressConfig(
        bytes32 key
    ) external view override configExists(key) returns (address) {
        ConfigValue storage config = configs[key];
        if (keccak256(bytes(config.configType)) != keccak256(bytes("address"))) {
            revert ConfigurationManager_InvalidConfigType(key, "address");
        }
        return abi.decode(config.value, (address));
    }

    /// @notice Get string configuration value
    /// @param key The configuration key
    /// @return The string configuration value
    function getStringConfig(
        bytes32 key
    ) external view override configExists(key) returns (string memory) {
        ConfigValue storage config = configs[key];
        if (keccak256(bytes(config.configType)) != keccak256(bytes("string"))) {
            revert ConfigurationManager_InvalidConfigType(key, "string");
        }
        return abi.decode(config.value, (string));
    }

    /// @notice Set configuration value
    /// @param key The configuration key
    /// @param value The configuration value
    function setConfig(
        bytes32 key,
        bytes calldata value
    ) external override onlyAuthorized {
        // If config exists, preserve its type and namespace
        if (configs[key].exists) {
            _setConfig(key, value, configs[key].namespace, configs[key].configType);
        } else {
            // Default to bytes type and SYSTEM namespace for new configs
            _setConfig(key, value, keccak256("SYSTEM"), "bytes");
        }
    }

    /// @notice Set boolean configuration value
    /// @param key The configuration key
    /// @param value The boolean configuration value
    /// @param namespace The configuration namespace
    function setBoolConfig(
        bytes32 key,
        bool value,
        bytes32 namespace
    ) external onlyAuthorized namespaceExists(namespace) {
        _setConfig(key, abi.encode(value), namespace, "bool");
    }

    /// @notice Set uint256 configuration value
    /// @param key The configuration key
    /// @param value The uint256 configuration value
    /// @param namespace The configuration namespace
    function setUintConfig(
        bytes32 key,
        uint256 value,
        bytes32 namespace
    ) external onlyAuthorized namespaceExists(namespace) {
        _setConfig(key, abi.encode(value), namespace, "uint256");
    }

    /// @notice Set address configuration value
    /// @param key The configuration key
    /// @param value The address configuration value
    /// @param namespace The configuration namespace
    function setAddressConfig(
        bytes32 key,
        address value,
        bytes32 namespace
    ) external onlyAuthorized namespaceExists(namespace) {
        _setConfig(key, abi.encode(value), namespace, "address");
    }

    /// @notice Set string configuration value
    /// @param key The configuration key
    /// @param value The string configuration value
    /// @param namespace The configuration namespace
    function setStringConfig(
        bytes32 key,
        string calldata value,
        bytes32 namespace
    ) external onlyAuthorized namespaceExists(namespace) {
        _setConfig(key, abi.encode(value), namespace, "string");
    }

    /// @notice Remove configuration
    /// @param key The configuration key
    function removeConfig(bytes32 key) external onlyAuthorized configExists(key) {
        bytes32 namespace = configs[key].namespace;
        
        // Remove from namespace's config keys
        ConfigNamespace storage ns = namespaces[namespace];
        for (uint256 i = 0; i < ns.configKeys.length; i++) {
            if (ns.configKeys[i] == key) {
                ns.configKeys[i] = ns.configKeys[ns.configKeys.length - 1];
                ns.configKeys.pop();
                break;
            }
        }
        
        // Remove from global config keys
        for (uint256 i = 0; i < configKeys.length; i++) {
            if (configKeys[i] == key) {
                configKeys[i] = configKeys[configKeys.length - 1];
                configKeys.pop();
                break;
            }
        }
        
        // Delete config
        delete configs[key];
        
        emit ConfigRemoved(key);
    }

    /// @notice Create a new namespace
    /// @param namespace The namespace ID
    /// @param description The namespace description
    function createNamespace(
        bytes32 namespace,
        string calldata description
    ) external onlyAdmin {
        _createNamespace(namespace, description);
    }

    /// @notice Create a new namespace by string
    /// @param namespace The namespace string
    /// @param description The namespace description
    function createNamespace(
        string calldata namespace,
        string calldata description
    ) external onlyAdmin {
        _createNamespace(keccak256(bytes(namespace)), description);
    }

    /// @notice Remove a namespace and all its configurations
    /// @param namespace The namespace ID
    function removeNamespace(bytes32 namespace) external onlyAdmin namespaceExists(namespace) {
        // Cannot remove default namespaces
        if (namespace == keccak256("SYSTEM") ||
            namespace == keccak256("SECURITY") ||
            namespace == keccak256("NETWORK") ||
            namespace == keccak256("PERFORMANCE") ||
            namespace == keccak256("FEATURE_FLAGS")) {
            revert ConfigurationManager_InvalidNamespace(namespace);
        }
        
        // Remove all configs in the namespace
        ConfigNamespace storage ns = namespaces[namespace];
        for (uint256 i = 0; i < ns.configKeys.length; i++) {
            bytes32 key = ns.configKeys[i];
            
            // Remove from global config keys
            for (uint256 j = 0; j < configKeys.length; j++) {
                if (configKeys[j] == key) {
                    configKeys[j] = configKeys[configKeys.length - 1];
                    configKeys.pop();
                    break;
                }
            }
            
            // Delete config
            delete configs[key];
            
            emit ConfigRemoved(key);
        }
        
        // Remove from namespace IDs
        for (uint256 i = 0; i < namespaceIds.length; i++) {
            if (namespaceIds[i] == namespace) {
                namespaceIds[i] = namespaceIds[namespaceIds.length - 1];
                namespaceIds.pop();
                break;
            }
        }
        
        // Delete namespace
        delete namespaces[namespace];
        
        emit ConfigNamespaceRemoved(namespace);
    }

    /// @notice Add an authorized address
    /// @param addr The address to authorize
    function addAuthorizedAddress(address addr) external onlyAdmin {
        if (addr == address(0)) revert ConfigurationManager_InvalidAddress(addr);
        if (authorizedAddresses[addr]) return; // Already authorized
        
        authorizedAddresses[addr] = true;
        authorizedAddressList.push(addr);
        
        emit ConfigManagerAuthorizedAddressAdded(addr);
    }

    /// @notice Remove an authorized address
    /// @param addr The address to deauthorize
    function removeAuthorizedAddress(address addr) external onlyAdmin {
        if (!authorizedAddresses[addr]) return; // Not authorized
        if (addr == admin) revert ConfigurationManager_InvalidAddress(addr); // Cannot remove admin
        
        authorizedAddresses[addr] = false;
        
        // Remove from authorized address list
        for (uint256 i = 0; i < authorizedAddressList.length; i++) {
            if (authorizedAddressList[i] == addr) {
                authorizedAddressList[i] = authorizedAddressList[authorizedAddressList.length - 1];
                authorizedAddressList.pop();
                break;
            }
        }
        
        emit ConfigManagerAuthorizedAddressRemoved(addr);
    }

    /// @notice Change the admin
    /// @param newAdmin The new admin address
    function changeAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert ConfigurationManager_InvalidAddress(newAdmin);
        
        address oldAdmin = admin;
        admin = newAdmin;
        
        // Authorize new admin if not already authorized
        if (!authorizedAddresses[newAdmin]) {
            authorizedAddresses[newAdmin] = true;
            authorizedAddressList.push(newAdmin);
            emit ConfigManagerAuthorizedAddressAdded(newAdmin);
        }
        
        emit ConfigManagerAdminChanged(oldAdmin, newAdmin);
    }

    /// @notice Get all configuration keys
    /// @return Array of configuration keys
    function getAllConfigKeys() external view returns (bytes32[] memory) {
        return configKeys;
    }

    /// @notice Get all namespace IDs
    /// @return Array of namespace IDs
    function getAllNamespaceIds() external view returns (bytes32[] memory) {
        return namespaceIds;
    }

    /// @notice Get all authorized addresses
    /// @return Array of authorized addresses
    function getAllAuthorizedAddresses() external view returns (address[] memory) {
        return authorizedAddressList;
    }

    /// @notice Get configuration keys in a namespace
    /// @param namespace The namespace ID
    /// @return Array of configuration keys
    function getNamespaceConfigKeys(bytes32 namespace) external view namespaceExists(namespace) returns (bytes32[] memory) {
        return namespaces[namespace].configKeys;
    }

    /// @notice Get configuration details
    /// @param key The configuration key
    /// @return key The configuration key
    /// @return value The configuration value
    /// @return namespace The configuration namespace
    /// @return configType The configuration type
    /// @return lastUpdated The last updated timestamp
    /// @return exists Whether the configuration exists
    function getConfigDetails(bytes32 key) external view configExists(key) returns (
        bytes32,
        bytes memory,
        bytes32,
        string memory,
        uint256,
        bool
    ) {
        ConfigValue storage config = configs[key];
        return (
            config.key,
            config.value,
            config.namespace,
            config.configType,
            config.lastUpdated,
            config.exists
        );
    }

    /// @notice Get namespace details
    /// @param namespace The namespace ID
    /// @return id The namespace ID
    /// @return description The namespace description
    /// @return configKeys The configuration keys in the namespace
    /// @return exists Whether the namespace exists
    function getNamespaceDetails(bytes32 namespace) external view namespaceExists(namespace) returns (
        bytes32,
        string memory,
        bytes32[] memory,
        bool
    ) {
        ConfigNamespace storage ns = namespaces[namespace];
        return (
            ns.id,
            ns.description,
            ns.configKeys,
            ns.exists
        );
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Internal function to set configuration
    /// @param key The configuration key
    /// @param value The configuration value
    /// @param namespace The configuration namespace
    /// @param configType The configuration type
    function _setConfig(
        bytes32 key,
        bytes memory value,
        bytes32 namespace,
        string memory configType
    ) internal namespaceExists(namespace) {
        bool isNewConfig = !configs[key].exists;
        
        // Update or create config
        configs[key] = ConfigValue({
            key: key,
            value: value,
            namespace: namespace,
            configType: configType,
            lastUpdated: block.timestamp,
            exists: true
        });
        
        // Add to global config keys if new
        if (isNewConfig) {
            configKeys.push(key);
            
            // Add to namespace's config keys
            namespaces[namespace].configKeys.push(key);
        } else if (configs[key].namespace != namespace) {
            // If namespace changed, update namespace references
            bytes32 oldNamespace = configs[key].namespace;
            
            // Remove from old namespace's config keys
            ConfigNamespace storage oldNs = namespaces[oldNamespace];
            for (uint256 i = 0; i < oldNs.configKeys.length; i++) {
                if (oldNs.configKeys[i] == key) {
                    oldNs.configKeys[i] = oldNs.configKeys[oldNs.configKeys.length - 1];
                    oldNs.configKeys.pop();
                    break;
                }
            }
            
            // Add to new namespace's config keys
            namespaces[namespace].configKeys.push(key);
        }
        
        emit ConfigSet(key, value);
    }

    /// @notice Internal function to create a namespace
    /// @param namespace The namespace ID
    /// @param description The namespace description
    function _createNamespace(bytes32 namespace, string memory description) internal {
        if (namespaces[namespace].exists) {
            revert ConfigurationManager_NamespaceAlreadyExists(namespace);
        }
        
        namespaces[namespace] = ConfigNamespace({
            id: namespace,
            description: description,
            configKeys: new bytes32[](0),
            exists: true
        });
        
        namespaceIds.push(namespace);
        
        emit ConfigNamespaceCreated(namespace, description);
    }

    /// @notice Internal function to create a namespace by string
    /// @param namespace The namespace string
    /// @param description The namespace description
    function _createNamespace(string memory namespace, string memory description) internal {
        _createNamespace(keccak256(bytes(namespace)), description);
    }
}