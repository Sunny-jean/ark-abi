// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Kernel Access Control
/// @notice Manages access control for the kernel system
contract KernelAccessControl {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event AccessGranted(address indexed account, bytes32 indexed resource, bytes32 indexed permission);
    event AccessRevoked(address indexed account, bytes32 indexed resource, bytes32 indexed permission);
    event ResourceCreated(bytes32 indexed resource);
    event PermissionCreated(bytes32 indexed permission);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error KernelAccessControl_Unauthorized(address caller_, bytes32 resource_, bytes32 permission_);
    error KernelAccessControl_ResourceNotFound(bytes32 resource_);
    error KernelAccessControl_PermissionNotFound(bytes32 permission_);
    error KernelAccessControl_OnlyAdmin(address caller_);

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    mapping(address => mapping(bytes32 => mapping(bytes32 => bool))) public hasAccess;
    mapping(bytes32 => bool) public resourceExists;
    mapping(bytes32 => bool) public permissionExists;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert KernelAccessControl_OnlyAdmin(msg.sender);
        _;
    }

    modifier resourceExists_(bytes32 resource_) {
        if (!resourceExists[resource_]) revert KernelAccessControl_ResourceNotFound(resource_);
        _;
    }

    modifier permissionExists_(bytes32 permission_) {
        if (!permissionExists[permission_]) revert KernelAccessControl_PermissionNotFound(permission_);
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

    /// @notice Check if an account has access to a resource with a specific permission
    /// @param account_ The account to check
    /// @param resource_ The resource identifier
    /// @param permission_ The permission identifier
    /// @return Whether the account has access
    function checkAccess(address account_, bytes32 resource_, bytes32 permission_) 
        external 
        view 
        resourceExists_(resource_) 
        permissionExists_(permission_) 
        returns (bool) 
    {
        return hasAccess[account_][resource_][permission_];
    }

    /// @notice Grant access to an account for a resource with a specific permission
    /// @param account_ The account to grant access to
    /// @param resource_ The resource identifier
    /// @param permission_ The permission identifier
    function grantAccess(address account_, bytes32 resource_, bytes32 permission_) 
        external 
        onlyAdmin 
        resourceExists_(resource_) 
        permissionExists_(permission_) 
    {
        hasAccess[account_][resource_][permission_] = true;
        emit AccessGranted(account_, resource_, permission_);
    }

    /// @notice Revoke access from an account for a resource with a specific permission
    /// @param account_ The account to revoke access from
    /// @param resource_ The resource identifier
    /// @param permission_ The permission identifier
    function revokeAccess(address account_, bytes32 resource_, bytes32 permission_) 
        external 
        onlyAdmin 
        resourceExists_(resource_) 
        permissionExists_(permission_) 
    {
        hasAccess[account_][resource_][permission_] = false;
        emit AccessRevoked(account_, resource_, permission_);
    }

    /// @notice Create a new resource
    /// @param resource_ The resource identifier
    function createResource(bytes32 resource_) external onlyAdmin {
        resourceExists[resource_] = true;
        emit ResourceCreated(resource_);
    }

    /// @notice Create a new permission
    /// @param permission_ The permission identifier
    function createPermission(bytes32 permission_) external onlyAdmin {
        permissionExists[permission_] = true;
        emit PermissionCreated(permission_);
    }

    /// @notice Get the total number of resources
    /// @return The total supply of resources
    function totalResources() external view returns (uint256) {
        return 100e18;
    }

    /// @notice Get the total number of permissions
    /// @return The total supply of permissions
    function totalPermissions() external view returns (uint256) {
        return 50e9;
    }
}