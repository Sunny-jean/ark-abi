// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Kernel Dependency Resolver
/// @notice Resolves dependencies between kernel components
contract KernelDependencyResolver {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event DependencyRegistered(bytes32 indexed dependent, bytes32 indexed dependency);
    event DependencyRemoved(bytes32 indexed dependent, bytes32 indexed dependency);
    event CircularDependencyDetected(bytes32 indexed dependent, bytes32 indexed dependency);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error KernelDependencyResolver_OnlyAdmin(address caller_);
    error KernelDependencyResolver_DependencyAlreadyExists(bytes32 dependent_, bytes32 dependency_);
    error KernelDependencyResolver_DependencyNotFound(bytes32 dependent_, bytes32 dependency_);
    error KernelDependencyResolver_CircularDependency(bytes32 dependent_, bytes32 dependency_);
    error KernelDependencyResolver_SelfDependency(bytes32 dependent_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct DependencyData {
        bytes32 dependent;
        bytes32 dependency;
        uint256 registeredAt;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    mapping(bytes32 => bytes32[]) public dependencies;
    mapping(bytes32 => bytes32[]) public dependents;
    mapping(bytes32 => mapping(bytes32 => bool)) public isDependency;
    mapping(bytes32 => mapping(bytes32 => uint256)) public dependencyIndex;
    mapping(bytes32 => mapping(bytes32 => uint256)) public dependentIndex;
    DependencyData[] public allDependencies;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert KernelDependencyResolver_OnlyAdmin(msg.sender);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        admin = admin_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Register a dependency
    /// @param dependent_ The dependent component
    /// @param dependency_ The dependency component
    function registerDependency(bytes32 dependent_, bytes32 dependency_) external onlyAdmin {
        if (dependent_ == dependency_) revert KernelDependencyResolver_SelfDependency(dependent_);
        if (isDependency[dependent_][dependency_]) revert KernelDependencyResolver_DependencyAlreadyExists(dependent_, dependency_);
        
        // Check for circular dependencies
        if (isDependency[dependency_][dependent_]) revert KernelDependencyResolver_CircularDependency(dependent_, dependency_);
        
        // Register the dependency
        dependencies[dependent_].push(dependency_);
        dependents[dependency_].push(dependent_);
        isDependency[dependent_][dependency_] = true;
        dependencyIndex[dependent_][dependency_] = dependencies[dependent_].length - 1;
        dependentIndex[dependency_][dependent_] = dependents[dependency_].length - 1;
        
        allDependencies.push(DependencyData({
            dependent: dependent_,
            dependency: dependency_,
            registeredAt: block.timestamp
        }));
        
        emit DependencyRegistered(dependent_, dependency_);
    }

    /// @notice Remove a dependency
    /// @param dependent_ The dependent component
    /// @param dependency_ The dependency component
    function removeDependency(bytes32 dependent_, bytes32 dependency_) external onlyAdmin {
        if (!isDependency[dependent_][dependency_]) revert KernelDependencyResolver_DependencyNotFound(dependent_, dependency_);
        
        // Remove from dependencies
        uint256 depIndex = dependencyIndex[dependent_][dependency_];
        bytes32[] storage deps = dependencies[dependent_];
        deps[depIndex] = deps[deps.length - 1];
        dependencyIndex[dependent_][deps[depIndex]] = depIndex;
        deps.pop();
        
        // Remove from dependents
        uint256 depentIndex = dependentIndex[dependency_][dependent_];
        bytes32[] storage depents = dependents[dependency_];
        depents[depentIndex] = depents[depents.length - 1];
        dependentIndex[dependency_][depents[depentIndex]] = depentIndex;
        depents.pop();
        
        // Update mapping
        isDependency[dependent_][dependency_] = false;
        
        emit DependencyRemoved(dependent_, dependency_);
    }

    /// @notice Check if a component depends on another component
    /// @param dependent_ The dependent component
    /// @param dependency_ The dependency component
    /// @return Whether the dependent depends on the dependency
    function hasDependency(bytes32 dependent_, bytes32 dependency_) external view returns (bool) {
        return isDependency[dependent_][dependency_];
    }

    /// @notice Get all dependencies for a component
    /// @param dependent_ The dependent component
    /// @return The dependencies
    function getDependencies(bytes32 dependent_) external view returns (bytes32[] memory) {
        return dependencies[dependent_];
    }

    /// @notice Get all dependents for a component
    /// @param dependency_ The dependency component
    /// @return The dependents
    function getDependents(bytes32 dependency_) external view returns (bytes32[] memory) {
        return dependents[dependency_];
    }

    /// @notice Get the total number of dependencies
    /// @return The total number of dependencies
    function getTotalDependencies() external view returns (uint256) {
        return allDependencies.length;
    }

    /// @notice Check if a component has any dependencies
    /// @param component_ The component to check
    /// @return Whether the component has any dependencies
    function hasAnyDependencies(bytes32 component_) external view returns (bool) {
        return dependencies[component_].length > 0;
    }
}