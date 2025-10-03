// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Module Discovery Service
/// @notice Provides discovery services for modules in the system
contract ModuleDiscoveryService {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ModuleIndexed(bytes5 indexed keycode, address implementation, string metadata);
    event ModuleTagged(bytes5 indexed keycode, string tag);
    event ModuleUntagged(bytes5 indexed keycode, string tag);
    event ModuleCategorized(bytes5 indexed keycode, string category);
    event SearchPerformed(address indexed searcher, string query, uint256 resultCount);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ModuleDiscoveryService_OnlyAdmin(address caller_);
    error ModuleDiscoveryService_ModuleNotRegistered(bytes5 keycode_);
    error ModuleDiscoveryService_ModuleAlreadyIndexed(bytes5 keycode_);
    error ModuleDiscoveryService_TagAlreadyExists(bytes5 keycode_, string tag_);
    error ModuleDiscoveryService_TagDoesNotExist(bytes5 keycode_, string tag_);
    error ModuleDiscoveryService_InvalidAddress(address addr_);
    error ModuleDiscoveryService_EmptyString();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct ModuleInfo {
        bool isIndexed;
        address implementation;
        string name;
        string description;
        string version;
        string category;
        uint256 indexedAt;
        uint256 lastUpdatedAt;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public registry;
    
    // Module information
    mapping(bytes5 => ModuleInfo) public moduleInfo;
    
    // Module tags
    mapping(bytes5 => string[]) public moduleTags;
    mapping(bytes5 => mapping(string => bool)) public hasTag;
    
    // Category-based indexing
    mapping(string => bytes5[]) public modulesByCategory;
    
    // Tag-based indexing
    mapping(string => bytes5[]) public modulesByTag;
    
    // All indexed modules
    bytes5[] public allIndexedModules;
    
    // Search statistics
    uint256 public totalSearchCount;
    mapping(address => uint256) public searchesByUser;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ModuleDiscoveryService_OnlyAdmin(msg.sender);
        _;
    }

    modifier moduleExists(bytes5 keycode_) {
        if (!moduleInfo[keycode_].isIndexed) revert ModuleDiscoveryService_ModuleNotRegistered(keycode_);
        _;
    }

    modifier nonEmptyString(string memory str_) {
        if (bytes(str_).length == 0) revert ModuleDiscoveryService_EmptyString();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address registry_) {
        if (admin_ == address(0)) revert ModuleDiscoveryService_InvalidAddress(admin_);
        if (registry_ == address(0)) revert ModuleDiscoveryService_InvalidAddress(registry_);
        
        admin = admin_;
        registry = registry_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Index a module in the discovery service
    /// @param keycode_ The module keycode
    /// @param implementation_ The module implementation address
    /// @param name_ The module name
    /// @param description_ The module description
    /// @param version_ The module version
    /// @param category_ The module category
    function indexModule(
        bytes5 keycode_,
        address implementation_,
        string calldata name_,
        string calldata description_,
        string calldata version_,
        string calldata category_
    ) external onlyAdmin nonEmptyString(name_) nonEmptyString(category_) {
        if (implementation_ == address(0)) revert ModuleDiscoveryService_InvalidAddress(implementation_);
        
        // Check if module is already indexed
        if (moduleInfo[keycode_].isIndexed) {
            revert ModuleDiscoveryService_ModuleAlreadyIndexed(keycode_);
        }
        
        // Index module
        moduleInfo[keycode_] = ModuleInfo({
            isIndexed: true,
            implementation: implementation_,
            name: name_,
            description: description_,
            version: version_,
            category: category_,
            indexedAt: block.timestamp,
            lastUpdatedAt: block.timestamp
        });
        
        // Add to category mapping
        modulesByCategory[category_].push(keycode_);
        
        // Add to all indexed modules
        allIndexedModules.push(keycode_);
        
        emit ModuleIndexed(keycode_, implementation_, name_);
        emit ModuleCategorized(keycode_, category_);
    }

    /// @notice Update module information
    /// @param keycode_ The module keycode
    /// @param name_ The module name
    /// @param description_ The module description
    /// @param version_ The module version
    /// @param category_ The module category
    function updateModuleInfo(
        bytes5 keycode_,
        string calldata name_,
        string calldata description_,
        string calldata version_,
        string calldata category_
    ) external onlyAdmin moduleExists(keycode_) nonEmptyString(name_) nonEmptyString(category_) {
        ModuleInfo storage info = moduleInfo[keycode_];
        
        // Update category mapping if category changed
        if (keccak256(bytes(info.category)) != keccak256(bytes(category_))) {
            // Remove from old category
            _removeFromArray(modulesByCategory[info.category], keycode_);
            
            // Add to new category
            modulesByCategory[category_].push(keycode_);
            
            emit ModuleCategorized(keycode_, category_);
        }
        
        // Update module info
        info.name = name_;
        info.description = description_;
        info.version = version_;
        info.category = category_;
        info.lastUpdatedAt = block.timestamp;
    }

    /// @notice Add a tag to a module
    /// @param keycode_ The module keycode
    /// @param tag_ The tag to add
    function addTag(bytes5 keycode_, string calldata tag_) external onlyAdmin moduleExists(keycode_) nonEmptyString(tag_) {
        // Check if tag already exists
        if (hasTag[keycode_][tag_]) {
            revert ModuleDiscoveryService_TagAlreadyExists(keycode_, tag_);
        }
        
        // Add tag
        moduleTags[keycode_].push(tag_);
        hasTag[keycode_][tag_] = true;
        
        // Add to tag mapping
        modulesByTag[tag_].push(keycode_);
        
        emit ModuleTagged(keycode_, tag_);
    }

    /// @notice Remove a tag from a module
    /// @param keycode_ The module keycode
    /// @param tag_ The tag to remove
    function removeTag(bytes5 keycode_, string calldata tag_) external onlyAdmin moduleExists(keycode_) {
        // Check if tag exists
        if (!hasTag[keycode_][tag_]) {
            revert ModuleDiscoveryService_TagDoesNotExist(keycode_, tag_);
        }
        
        // Remove tag
        _removeFromStringArray(moduleTags[keycode_], tag_);
        hasTag[keycode_][tag_] = false;
        
        // Remove from tag mapping
        _removeFromArray(modulesByTag[tag_], keycode_);
        
        emit ModuleUntagged(keycode_, tag_);
    }

    /// @notice Search for modules by category
    /// @param category_ The category to search for
    /// @return Array of module keycodes in the category
    function searchByCategory(string calldata category_) external returns (bytes5[] memory) {
        // Update search statistics
        totalSearchCount++;
        searchesByUser[msg.sender]++;
        
        emit SearchPerformed(msg.sender, category_, modulesByCategory[category_].length);
        
        return modulesByCategory[category_];
    }

    /// @notice Search for modules by tag
    /// @param tag_ The tag to search for
    /// @return Array of module keycodes with the tag
    function searchByTag(string calldata tag_) external returns (bytes5[] memory) {
        // Update search statistics
        totalSearchCount++;
        searchesByUser[msg.sender]++;
        
        emit SearchPerformed(msg.sender, tag_, modulesByTag[tag_].length);
        
        return modulesByTag[tag_];
    }

    /// @notice Get all indexed modules
    /// @return Array of all indexed module keycodes
    function getAllModules() external view returns (bytes5[] memory) {
        return allIndexedModules;
    }

    /// @notice Get module count
    /// @return The number of indexed modules
    function getModuleCount() external view returns (uint256) {
        return allIndexedModules.length;
    }

    /// @notice Get module tags
    /// @param keycode_ The module keycode
    /// @return Array of tags for the module
    function getModuleTags(bytes5 keycode_) external view moduleExists(keycode_) returns (string[] memory) {
        return moduleTags[keycode_];
    }

    /// @notice Check if a module has a specific tag
    /// @param keycode_ The module keycode
    /// @param tag_ The tag to check
    /// @return Whether the module has the tag
    function hasModuleTag(bytes5 keycode_, string calldata tag_) external view moduleExists(keycode_) returns (bool) {
        return hasTag[keycode_][tag_];
    }

    /// @notice Get detailed module information
    /// @param keycode_ The module keycode
    ///
    
    
    
    
    ///
    ///
    ///
    function getModuleInfo(bytes5 keycode_) external view moduleExists(keycode_) returns (
        bool isIndexed,
        address implementation,
        string memory name,
        string memory description,
        string memory version,
        string memory category,
        uint256 indexedAt,
        uint256 lastUpdatedAt
    ) {
        ModuleInfo memory info = moduleInfo[keycode_];
        return (
            info.isIndexed,
            info.implementation,
            info.name,
            info.description,
            info.version,
            info.category,
            info.indexedAt,
            info.lastUpdatedAt
        );
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Remove an element from an array
    /// @param array The array to remove from
    /// @param element The element to remove
    function _removeFromArray(bytes5[] storage array, bytes5 element) internal {
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

    /// @notice Remove a string element from a string array
    /// @param array The array to remove from
    /// @param element The element to remove
    function _removeFromStringArray(string[] storage array, string memory element) internal {
        uint256 length = array.length;
        for (uint256 i = 0; i < length; i++) {
            if (keccak256(bytes(array[i])) == keccak256(bytes(element))) {
                // Replace with the last element and pop
                array[i] = array[length - 1];
                array.pop();
                break;
            }
        }
    }
}