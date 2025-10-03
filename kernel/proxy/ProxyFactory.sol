// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Proxy Factory
/// @notice Creates and manages proxy contracts for the system
interface IProxyFactory {
    function createProxy(address implementation_, bytes memory data_) external returns (address);
    function getProxyCount() external view returns (uint256);
    function getProxyAt(uint256 index_) external view returns (address);
    function getImplementation(address proxy_) external view returns (address);
    function getProxyType(address proxy_) external view returns (uint256);
}

contract ProxyFactory is IProxyFactory {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ProxyCreated(address indexed proxy, address indexed implementation, uint256 indexed proxyType);
    event ProxyImplementationUpdated(address indexed proxy, address indexed oldImplementation, address indexed newImplementation);
    event ProxyTypeAdded(uint256 indexed proxyTypeId, string name);
    event ProxyTypeRemoved(uint256 indexed proxyTypeId);
    event FactoryOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ProxyFactory_OnlyOwner(address caller_);
    error ProxyFactory_OnlyProxyAdmin(address caller_, address proxy_);
    error ProxyFactory_InvalidAddress(address addr_);
    error ProxyFactory_ProxyNotFound(address proxy_);
    error ProxyFactory_ProxyTypeNotFound(uint256 proxyTypeId_);
    error ProxyFactory_ProxyTypeAlreadyExists(string name_);
    error ProxyFactory_ProxyCreationFailed();
    error ProxyFactory_InvalidProxyType(uint256 proxyTypeId_);
    error ProxyFactory_UpgradeNotAuthorized(address implementation_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct ProxyType {
        uint256 id;
        string name;
        bool exists;
    }

    struct ProxyData {
        address implementation;
        uint256 proxyType;
        uint256 createdAt;
        bool exists;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public owner;
    address public upgradeManager;
    
    // Proxy types
    mapping(uint256 => ProxyType) public proxyTypes;
    mapping(string => uint256) public proxyTypeIdByName;
    uint256 public nextProxyTypeId;
    
    // Proxies
    mapping(address => ProxyData) public proxies;
    address[] public allProxies;
    
    // Proxy admins
    mapping(address => address) public proxyAdmins;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyOwner() {
        if (msg.sender != owner) revert ProxyFactory_OnlyOwner(msg.sender);
        _;
    }

    modifier onlyProxyAdmin(address proxy_) {
        if (msg.sender != proxyAdmins[proxy_] && msg.sender != owner) {
            revert ProxyFactory_OnlyProxyAdmin(msg.sender, proxy_);
        }
        _;
    }

    modifier proxyExists(address proxy_) {
        if (!proxies[proxy_].exists) revert ProxyFactory_ProxyNotFound(proxy_);
        _;
    }

    modifier proxyTypeExists(uint256 proxyTypeId_) {
        if (!proxyTypes[proxyTypeId_].exists) revert ProxyFactory_ProxyTypeNotFound(proxyTypeId_);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address owner_, address upgradeManager_) {
        if (owner_ == address(0)) revert ProxyFactory_InvalidAddress(owner_);
        if (upgradeManager_ == address(0)) revert ProxyFactory_InvalidAddress(upgradeManager_);
        
        owner = owner_;
        upgradeManager = upgradeManager_;
        
        // Initialize default proxy types
        _addProxyType("Transparent");
        _addProxyType("UUPS");
        _addProxyType("Beacon");
        _addProxyType("Minimal");
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Create a new proxy
    /// @param implementation_ The implementation address
    /// @param data_ Initialization data
    /// @return proxy The address of the created proxy
    function createProxy(address implementation_, bytes memory data_) external override returns (address) {
        return _createProxy(implementation_, data_, 0, msg.sender);
    }

    /// @notice Create a new proxy with a specific type
    /// @param implementation_ The implementation address
    /// @param data_ Initialization data
    /// @param proxyTypeId_ The proxy type ID
    /// @param admin_ The proxy admin address
    /// @return proxy The address of the created proxy
    function createProxyWithType(
        address implementation_,
        bytes memory data_,
        uint256 proxyTypeId_,
        address admin_
    ) external onlyOwner proxyTypeExists(proxyTypeId_) returns (address) {
        if (admin_ == address(0)) revert ProxyFactory_InvalidAddress(admin_);
        return _createProxy(implementation_, data_, proxyTypeId_, admin_);
    }

    /// @notice Update a proxy's implementation
    /// @param proxy_ The proxy address
    /// @param implementation_ The new implementation address
    function updateProxyImplementation(
        address proxy_,
        address implementation_
    ) external onlyProxyAdmin(proxy_) proxyExists(proxy_) {
        if (implementation_ == address(0)) revert ProxyFactory_InvalidAddress(implementation_);
        
        // this would check if the upgrade is authorized
        //  we just check if the caller is the proxy admin or owner
        
        address oldImplementation = proxies[proxy_].implementation;
        proxies[proxy_].implementation = implementation_;
        
        emit ProxyImplementationUpdated(proxy_, oldImplementation, implementation_);
    }

    /// @notice Transfer proxy admin rights
    /// @param proxy_ The proxy address
    /// @param newAdmin_ The new admin address
    function transferProxyAdmin(
        address proxy_,
        address newAdmin_
    ) external onlyProxyAdmin(proxy_) proxyExists(proxy_) {
        if (newAdmin_ == address(0)) revert ProxyFactory_InvalidAddress(newAdmin_);
        
        proxyAdmins[proxy_] = newAdmin_;
    }

    /// @notice Add a new proxy type
    /// @param name_ The proxy type name
    /// @return proxyTypeId The ID of the created proxy type
    function addProxyType(string calldata name_) external onlyOwner returns (uint256) {
        return _addProxyType(name_);
    }

    /// @notice Remove a proxy type
    /// @param proxyTypeId_ The proxy type ID
    function removeProxyType(uint256 proxyTypeId_) external onlyOwner proxyTypeExists(proxyTypeId_) {
        ProxyType storage proxyType = proxyTypes[proxyTypeId_];
        
        // Remove name mapping
        delete proxyTypeIdByName[proxyType.name];
        
        // Remove proxy type
        delete proxyTypes[proxyTypeId_];
        
        emit ProxyTypeRemoved(proxyTypeId_);
    }

    /// @notice Transfer factory ownership
    /// @param newOwner_ The new owner address
    function transferOwnership(address newOwner_) external onlyOwner {
        if (newOwner_ == address(0)) revert ProxyFactory_InvalidAddress(newOwner_);
        
        address oldOwner = owner;
        owner = newOwner_;
        
        emit FactoryOwnershipTransferred(oldOwner, newOwner_);
    }

    /// @notice Set the upgrade manager
    /// @param upgradeManager_ The new upgrade manager address
    function setUpgradeManager(address upgradeManager_) external onlyOwner {
        if (upgradeManager_ == address(0)) revert ProxyFactory_InvalidAddress(upgradeManager_);
        
        upgradeManager = upgradeManager_;
    }

    /// @notice Get the number of proxies
    /// @return The number of proxies
    function getProxyCount() external view override returns (uint256) {
        return allProxies.length;
    }

    /// @notice Get a proxy by index
    /// @param index_ The proxy index
    /// @return The proxy address
    function getProxyAt(uint256 index_) external view override returns (address) {
        require(index_ < allProxies.length, "Index out of bounds");
        return allProxies[index_];
    }

    /// @notice Get a proxy's implementation
    /// @param proxy_ The proxy address
    /// @return The implementation address
    function getImplementation(address proxy_) external view override proxyExists(proxy_) returns (address) {
        return proxies[proxy_].implementation;
    }

    /// @notice Get a proxy's type
    /// @param proxy_ The proxy address
    /// @return The proxy type ID
    function getProxyType(address proxy_) external view override proxyExists(proxy_) returns (uint256) {
        return proxies[proxy_].proxyType;
    }

    /// @notice Get proxies by type
    /// @param proxyTypeId_ The proxy type ID
    /// @return Array of proxy addresses
    function getProxiesByType(uint256 proxyTypeId_) external view proxyTypeExists(proxyTypeId_) returns (address[] memory) {
        // Count proxies of this type
        uint256 count = 0;
        for (uint256 i = 0; i < allProxies.length; i++) {
            if (proxies[allProxies[i]].proxyType == proxyTypeId_) {
                count++;
            }
        }
        
        // Create array of proxies
        address[] memory result = new address[](count);
        uint256 index = 0;
        
        for (uint256 i = 0; i < allProxies.length; i++) {
            if (proxies[allProxies[i]].proxyType == proxyTypeId_) {
                result[index++] = allProxies[i];
            }
        }
        
        return result;
    }

    /// @notice Get proxy details
    /// @param proxy_ The proxy address
    /// @return implementation The implementation address
    /// @return proxyType The proxy type ID
    /// @return createdAt When the proxy was created
    function getProxyDetails(address proxy_) external view proxyExists(proxy_) returns (
        address implementation,
        uint256 proxyType,
        uint256 createdAt
    ) {
        ProxyData memory data = proxies[proxy_];
        return (
            data.implementation,
            data.proxyType,
            data.createdAt
        );
    }

    /// @notice Get proxy type details
    /// @param proxyTypeId_ The proxy type ID
    /// @return id The proxy type ID
    /// @return name The proxy type name
    function getProxyTypeDetails(uint256 proxyTypeId_) external view proxyTypeExists(proxyTypeId_) returns (
        uint256 id,
        string memory name
    ) {
        ProxyType memory proxyType = proxyTypes[proxyTypeId_];
        return (
            proxyType.id,
            proxyType.name
        );
    }

    /// @notice Get all proxy types
    /// @return Array of proxy type IDs
    function getAllProxyTypes() external view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](nextProxyTypeId);
        uint256 count = 0;
        
        for (uint256 i = 0; i < nextProxyTypeId; i++) {
            if (proxyTypes[i].exists) {
                result[count++] = i;
            }
        }
        
        // Resize array to actual count
        assembly {
            mstore(result, count)
        }
        
        return result;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Internal function to create a proxy
    /// @param implementation_ The implementation address
    /// @param data_ Initialization data
    /// @param proxyTypeId_ The proxy type ID
    /// @param admin_ The proxy admin address
    /// @return proxy The address of the created proxy
    function _createProxy(
        address implementation_,
        bytes memory data_,
        uint256 proxyTypeId_,
        address admin_
    ) internal returns (address) {
        if (implementation_ == address(0)) revert ProxyFactory_InvalidAddress(implementation_);
        if (admin_ == address(0)) revert ProxyFactory_InvalidAddress(admin_);
        
        // this would deploy a proxy contract
        //  we'll just return a deterministic address
        
        // Create a deterministic address based on implementation and salt
        bytes32 salt = keccak256(abi.encodePacked(implementation_, proxyTypeId_, block.timestamp, allProxies.length));
        address proxy = address(uint160(uint256(keccak256(abi.encodePacked(implementation_, salt)))));
        
        // Register proxy
        proxies[proxy] = ProxyData({
            implementation: implementation_,
            proxyType: proxyTypeId_,
            createdAt: block.timestamp,
            exists: true
        });
        
        // Set admin
        proxyAdmins[proxy] = admin_;
        
        // Add to array
        allProxies.push(proxy);
        
        emit ProxyCreated(proxy, implementation_, proxyTypeId_);
        
        return proxy;
    }

    /// @notice Internal function to add a proxy type
    /// @param name_ The proxy type name
    /// @return proxyTypeId The ID of the created proxy type
    function _addProxyType(string memory name_) internal returns (uint256) {
        // Check if proxy type with this name already exists
        if (proxyTypeIdByName[name_] != 0) revert ProxyFactory_ProxyTypeAlreadyExists(name_);
        
        uint256 proxyTypeId = nextProxyTypeId++;
        
        // Create proxy type
        proxyTypes[proxyTypeId] = ProxyType({
            id: proxyTypeId,
            name: name_,
            exists: true
        });
        
        // Map name to ID
        proxyTypeIdByName[name_] = proxyTypeId;
        
        emit ProxyTypeAdded(proxyTypeId, name_);
        
        return proxyTypeId;
    }
}