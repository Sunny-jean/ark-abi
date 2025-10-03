// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Proxy Registry
/// @notice Registry for tracking and managing proxy contracts in the system
contract ProxyRegistry {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ProxyRegistered(address indexed proxy, address indexed implementation, bytes32 indexed proxyType);
    event ProxyImplementationUpdated(address indexed proxy, address indexed oldImplementation, address indexed newImplementation);
    event ProxyOwnershipTransferred(address indexed proxy, address indexed oldOwner, address indexed newOwner);
    event ProxyRemoved(address indexed proxy, address indexed implementation);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ProxyRegistry_OnlyAdmin(address caller_);
    error ProxyRegistry_OnlyProxyOwner(address caller_, address proxy_);
    error ProxyRegistry_ProxyAlreadyRegistered(address proxy_);
    error ProxyRegistry_ProxyNotRegistered(address proxy_);
    error ProxyRegistry_InvalidAddress(address addr_);
    error ProxyRegistry_InvalidProxyType(bytes32 proxyType_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct ProxyData {
        bool registered;
        address implementation;
        address owner;
        bytes32 proxyType;
        uint256 registeredAt;
        uint256 lastUpdatedAt;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    
    // Proxy data
    mapping(address => ProxyData) public proxies;
    
    // Proxy addresses by type
    mapping(bytes32 => address[]) public proxyAddressesByType;
    
    // Proxy addresses by implementation
    mapping(address => address[]) public proxyAddressesByImplementation;
    
    // Proxy addresses by owner
    mapping(address => address[]) public proxyAddressesByOwner;
    
    // All registered proxies
    address[] public allProxies;
    
    // Valid proxy types
    mapping(bytes32 => bool) public validProxyTypes;
    bytes32[] public allProxyTypes;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ProxyRegistry_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyProxyOwner(address proxy_) {
        if (msg.sender != proxies[proxy_].owner) revert ProxyRegistry_OnlyProxyOwner(msg.sender, proxy_);
        _;
    }

    modifier proxyExists(address proxy_) {
        if (!proxies[proxy_].registered) revert ProxyRegistry_ProxyNotRegistered(proxy_);
        _;
    }

    modifier validProxyType(bytes32 proxyType_) {
        if (!validProxyTypes[proxyType_]) revert ProxyRegistry_InvalidProxyType(proxyType_);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        if (admin_ == address(0)) revert ProxyRegistry_InvalidAddress(admin_);
        
        admin = admin_;
        
        // Initialize default proxy types
        _addProxyType("TRANSPARENT");
        _addProxyType("UUPS");
        _addProxyType("BEACON");
        _addProxyType("MINIMAL");
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Register a new proxy
    /// @param proxy_ The proxy address
    /// @param implementation_ The implementation address
    /// @param owner_ The proxy owner address
    /// @param proxyType_ The proxy type
    function registerProxy(
        address proxy_,
        address implementation_,
        address owner_,
        bytes32 proxyType_
    ) external onlyAdmin validProxyType(proxyType_) {
        if (proxy_ == address(0)) revert ProxyRegistry_InvalidAddress(proxy_);
        if (implementation_ == address(0)) revert ProxyRegistry_InvalidAddress(implementation_);
        if (owner_ == address(0)) revert ProxyRegistry_InvalidAddress(owner_);
        
        // Check if proxy is already registered
        if (proxies[proxy_].registered) {
            revert ProxyRegistry_ProxyAlreadyRegistered(proxy_);
        }
        
        // Register proxy
        proxies[proxy_] = ProxyData({
            registered: true,
            implementation: implementation_,
            owner: owner_,
            proxyType: proxyType_,
            registeredAt: block.timestamp,
            lastUpdatedAt: block.timestamp
        });
        
        // Update mappings
        proxyAddressesByType[proxyType_].push(proxy_);
        proxyAddressesByImplementation[implementation_].push(proxy_);
        proxyAddressesByOwner[owner_].push(proxy_);
        allProxies.push(proxy_);
        
        emit ProxyRegistered(proxy_, implementation_, proxyType_);
    }

    /// @notice Update proxy implementation
    /// @param proxy_ The proxy address
    /// @param newImplementation_ The new implementation address
    function updateProxyImplementation(address proxy_, address newImplementation_) external onlyProxyOwner(proxy_) proxyExists(proxy_) {
        if (newImplementation_ == address(0)) revert ProxyRegistry_InvalidAddress(newImplementation_);
        
        address oldImplementation = proxies[proxy_].implementation;
        
        // Remove from old implementation mapping
        _removeFromArray(proxyAddressesByImplementation[oldImplementation], proxy_);
        
        // Update proxy data
        proxies[proxy_].implementation = newImplementation_;
        proxies[proxy_].lastUpdatedAt = block.timestamp;
        
        // Add to new implementation mapping
        proxyAddressesByImplementation[newImplementation_].push(proxy_);
        
        emit ProxyImplementationUpdated(proxy_, oldImplementation, newImplementation_);
    }

    /// @notice Transfer proxy ownership
    /// @param proxy_ The proxy address
    /// @param newOwner_ The new owner address
    function transferProxyOwnership(address proxy_, address newOwner_) external onlyProxyOwner(proxy_) proxyExists(proxy_) {
        if (newOwner_ == address(0)) revert ProxyRegistry_InvalidAddress(newOwner_);
        
        address oldOwner = proxies[proxy_].owner;
        
        // Remove from old owner mapping
        _removeFromArray(proxyAddressesByOwner[oldOwner], proxy_);
        
        // Update proxy data
        proxies[proxy_].owner = newOwner_;
        proxies[proxy_].lastUpdatedAt = block.timestamp;
        
        // Add to new owner mapping
        proxyAddressesByOwner[newOwner_].push(proxy_);
        
        emit ProxyOwnershipTransferred(proxy_, oldOwner, newOwner_);
    }

    /// @notice Remove a proxy from the registry
    /// @param proxy_ The proxy address
    function removeProxy(address proxy_) external onlyAdmin proxyExists(proxy_) {
        ProxyData memory proxyData = proxies[proxy_];
        
        // Remove from mappings
        _removeFromArray(proxyAddressesByType[proxyData.proxyType], proxy_);
        _removeFromArray(proxyAddressesByImplementation[proxyData.implementation], proxy_);
        _removeFromArray(proxyAddressesByOwner[proxyData.owner], proxy_);
        _removeFromArray(allProxies, proxy_);
        
        // Delete proxy data
        delete proxies[proxy_];
        
        emit ProxyRemoved(proxy_, proxyData.implementation);
    }

    /// @notice Add a new valid proxy type
    /// @param proxyType_ The proxy type name
    function addProxyType(string calldata proxyType_) external onlyAdmin {
        bytes32 proxyTypeHash = keccak256(bytes(proxyType_));
        _addProxyType(proxyType_);
    }

    /// @notice Get all proxies
    /// @return Array of all proxy addresses
    function getAllProxies() external view returns (address[] memory) {
        return allProxies;
    }

    /// @notice Get proxies by type
    /// @param proxyType_ The proxy type
    /// @return Array of proxy addresses with the specified type
    function getProxiesByType(bytes32 proxyType_) external view validProxyType(proxyType_) returns (address[] memory) {
        return proxyAddressesByType[proxyType_];
    }

    /// @notice Get proxies by implementation
    /// @param implementation_ The implementation address
    /// @return Array of proxy addresses with the specified implementation
    function getProxiesByImplementation(address implementation_) external view returns (address[] memory) {
        return proxyAddressesByImplementation[implementation_];
    }

    /// @notice Get proxies by owner
    /// @param owner_ The owner address
    /// @return Array of proxy addresses with the specified owner
    function getProxiesByOwner(address owner_) external view returns (address[] memory) {
        return proxyAddressesByOwner[owner_];
    }

    /// @notice Get proxy count
    /// @return The number of registered proxies
    function getProxyCount() external view returns (uint256) {
        return allProxies.length;
    }

    /// @notice Get proxy count by type
    /// @param proxyType_ The proxy type
    /// @return The number of proxies with the specified type
    function getProxyCountByType(bytes32 proxyType_) external view validProxyType(proxyType_) returns (uint256) {
        return proxyAddressesByType[proxyType_].length;
    }

    /// @notice Get all valid proxy types
    /// @return Array of all valid proxy types
    function getAllProxyTypes() external view returns (bytes32[] memory) {
        return allProxyTypes;
    }

    /// @notice Get detailed proxy data
    /// @param proxy_ The proxy address
    /// @return registered Whether the proxy is registered
    /// @return implementation The implementation address
    /// @return owner The proxy owner address
    /// @return proxyType The proxy type
    /// @return registeredAt When the proxy was registered
    /// @return lastUpdatedAt When the proxy was last updated
    function getProxyData(address proxy_) external view proxyExists(proxy_) returns (
        bool registered,
        address implementation,
        address owner,
        bytes32 proxyType,
        uint256 registeredAt,
        uint256 lastUpdatedAt
    ) {
        ProxyData memory data = proxies[proxy_];
        return (
            data.registered,
            data.implementation,
            data.owner,
            data.proxyType,
            data.registeredAt,
            data.lastUpdatedAt
        );
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Add a new valid proxy type
    /// @param proxyType_ The proxy type name
    function _addProxyType(string memory proxyType_) internal {
        bytes32 proxyTypeHash = keccak256(bytes(proxyType_));
        if (!validProxyTypes[proxyTypeHash]) {
            validProxyTypes[proxyTypeHash] = true;
            allProxyTypes.push(proxyTypeHash);
        }
    }

    /// @notice Remove an element from an array
    /// @param array The array to remove from
    /// @param element The element to remove
    function _removeFromArray(address[] storage array, address element) internal {
        uint256 length = array.length;
        for (uint256 i = 0; i < length; i++) {
            if (array[i] == element) {
                // Replace with the last element and pop
                array[i] = array[length - 1];
                array.pop();
                break;
            }
        }
    }
}