// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Module Dependency Manager
/// @notice Manages dependencies between modules in the system
contract ModuleDependencyManager {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event DependencyRegistered(bytes5 indexed dependent, bytes5 indexed dependency);
    event DependencyRemoved(bytes5 indexed dependent, bytes5 indexed dependency);
    event DependencyValidated(bytes5 indexed dependent, bytes5 indexed dependency, bool valid);
    event CircularDependencyDetected(bytes5 indexed moduleA, bytes5 indexed moduleB);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ModuleDependencyManager_OnlyAdmin(address caller_);
    error ModuleDependencyManager_ModuleNotRegistered(bytes5 keycode_);
    error ModuleDependencyManager_DependencyAlreadyRegistered(bytes5 dependent_, bytes5 dependency_);
    error ModuleDependencyManager_DependencyNotRegistered(bytes5 dependent_, bytes5 dependency_);
    error ModuleDependencyManager_CircularDependencyDetected(bytes5 moduleA_, bytes5 moduleB_);
    error ModuleDependencyManager_SelfDependencyNotAllowed(bytes5 module_);
    error ModuleDependencyManager_InvalidAddress(address addr_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct DependencyData {
        bool exists;
        uint256 registeredAt;
        uint256 lastValidatedAt;
        bool isValid;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public registry;
    
    // Module dependencies: dependent => dependency => DependencyData
    mapping(bytes5 => mapping(bytes5 => DependencyData)) public dependencies;
    
    // Reverse lookup: dependency => dependent => bool
    mapping(bytes5 => mapping(bytes5 => bool)) public reverseDependencies;
    
    // All dependencies for a module
    mapping(bytes5 => bytes5[]) public allDependenciesForModule;
    
    // All dependents for a module
    mapping(bytes5 => bytes5[]) public allDependentsForModule;
    
    // Total dependency count
    uint256 public totalDependencyCount;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ModuleDependencyManager_OnlyAdmin(msg.sender);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address registry_) {
        if (admin_ == address(0)) revert ModuleDependencyManager_InvalidAddress(admin_);
        if (registry_ == address(0)) revert ModuleDependencyManager_InvalidAddress(registry_);
        
        admin = admin_;
        registry = registry_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Register a dependency between two modules
    /// @param dependent_ The dependent module keycode
    /// @param dependency_ The dependency module keycode
    function registerDependency(bytes5 dependent_, bytes5 dependency_) external onlyAdmin {
        // Check for self-dependency
        if (dependent_ == dependency_) revert ModuleDependencyManager_SelfDependencyNotAllowed(dependent_);
        
        // Check if dependency already exists
        if (dependencies[dependent_][dependency_].exists) {
            revert ModuleDependencyManager_DependencyAlreadyRegistered(dependent_, dependency_);
        }
        
        // Check for circular dependency
        if (reverseDependencies[dependent_][dependency_]) {
            revert ModuleDependencyManager_CircularDependencyDetected(dependent_, dependency_);
        }
        
        // Register dependency
        dependencies[dependent_][dependency_] = DependencyData({
            exists: true,
            registeredAt: block.timestamp,
            lastValidatedAt: 0,
            isValid: false
        });
        
        // Update reverse lookup
        reverseDependencies[dependency_][dependent_] = true;
        
        // Update arrays
        allDependenciesForModule[dependent_].push(dependency_);
        allDependentsForModule[dependency_].push(dependent_);
        
        // Increment total count
        totalDependencyCount++;
        
        emit DependencyRegistered(dependent_, dependency_);
    }

    /// @notice Remove a dependency between two modules
    /// @param dependent_ The dependent module keycode
    /// @param dependency_ The dependency module keycode
    function removeDependency(bytes5 dependent_, bytes5 dependency_) external onlyAdmin {
        // Check if dependency exists
        if (!dependencies[dependent_][dependency_].exists) {
            revert ModuleDependencyManager_DependencyNotRegistered(dependent_, dependency_);
        }
        
        // Remove dependency
        delete dependencies[dependent_][dependency_];
        
        // Update reverse lookup
        reverseDependencies[dependency_][dependent_] = false;
        
        // Update arrays (remove from arrays)
        _removeFromArray(allDependenciesForModule[dependent_], dependency_);
        _removeFromArray(allDependentsForModule[dependency_], dependent_);
        
        // Decrement total count
        totalDependencyCount--;
        
        emit DependencyRemoved(dependent_, dependency_);
    }

    /// @notice Validate a dependency between two modules
    /// @param dependent_ The dependent module keycode
    /// @param dependency_ The dependency module keycode
    /// @param valid_ Whether the dependency is valid
    function validateDependency(bytes5 dependent_, bytes5 dependency_, bool valid_) external onlyAdmin {
        // Check if dependency exists
        if (!dependencies[dependent_][dependency_].exists) {
            revert ModuleDependencyManager_DependencyNotRegistered(dependent_, dependency_);
        }
        
        // Update validation status
        dependencies[dependent_][dependency_].lastValidatedAt = block.timestamp;
        dependencies[dependent_][dependency_].isValid = valid_;
        
        emit DependencyValidated(dependent_, dependency_, valid_);
    }

    /// @notice Check if a module has a dependency on another module
    /// @param dependent_ The dependent module keycode
    /// @param dependency_ The dependency module keycode
    /// @return Whether the dependency exists
    function hasDependency(bytes5 dependent_, bytes5 dependency_) external view returns (bool) {
        return dependencies[dependent_][dependency_].exists;
    }

    /// @notice Check if a dependency is valid
    /// @param dependent_ The dependent module keycode
    /// @param dependency_ The dependency module keycode
    /// @return Whether the dependency is valid
    function isDependencyValid(bytes5 dependent_, bytes5 dependency_) external view returns (bool) {
        if (!dependencies[dependent_][dependency_].exists) return false;
        return dependencies[dependent_][dependency_].isValid;
    }

    /// @notice Get all dependencies for a module
    /// @param module_ The module keycode
    /// @return Array of dependency keycodes
    function getDependenciesForModule(bytes5 module_) external view returns (bytes5[] memory) {
        return allDependenciesForModule[module_];
    }

    /// @notice Get all dependents for a module
    /// @param module_ The module keycode
    /// @return Array of dependent keycodes
    function getDependentsForModule(bytes5 module_) external view returns (bytes5[] memory) {
        return allDependentsForModule[module_];
    }

    /// @notice Get dependency count for a module
    /// @param module_ The module keycode
    /// @return The number of dependencies
    function getDependencyCount(bytes5 module_) external view returns (uint256) {
        return allDependenciesForModule[module_].length;
    }

    /// @notice Get dependent count for a module
    /// @param module_ The module keycode
    /// @return The number of dependents
    function getDependentCount(bytes5 module_) external view returns (uint256) {
        return allDependentsForModule[module_].length;
    }

    /// @notice Get total dependency count in the system
    /// @return The total number of dependencies
    function getTotalDependencyCount() external view returns (uint256) {
        return totalDependencyCount;
    }

    /// @notice Get detailed dependency data
    /// @param dependent_ The dependent module keycode
    /// @param dependency_ The dependency module keycode
    /// @return exists Whether the dependency exists
    /// @return registeredAt When the dependency was registered
    /// @return lastValidatedAt When the dependency was last validated
    /// @return isValid Whether the dependency is valid
    function getDependencyData(bytes5 dependent_, bytes5 dependency_) external view returns (
        bool exists,
        uint256 registeredAt,
        uint256 lastValidatedAt,
        bool isValid
    ) {
        DependencyData memory data = dependencies[dependent_][dependency_];
        return (
            data.exists,
            data.registeredAt,
            data.lastValidatedAt,
            data.isValid
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
}