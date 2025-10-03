// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Security Policy Manager
/// @notice Manages security policies for the system
contract SecurityPolicyManager {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event PolicyCreated(bytes32 indexed policyId, address indexed creator);
    event PolicyUpdated(bytes32 indexed policyId, address indexed updater);
    event PolicyActivated(bytes32 indexed policyId);
    event PolicyDeactivated(bytes32 indexed policyId);
    event SecurityViolation(address indexed violator, bytes32 indexed policyId, bytes32 indexed violationType);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error SecurityPolicyManager_PolicyNotFound(bytes32 policyId_);
    error SecurityPolicyManager_PolicyAlreadyExists(bytes32 policyId_);
    error SecurityPolicyManager_OnlyAdmin(address caller_);
    error SecurityPolicyManager_OnlyPolicyManager(address caller_);
    error SecurityPolicyManager_PolicyViolation(bytes32 policyId_, bytes32 violationType_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct SecurityPolicy {
        bytes32 policyId;
        bool isActive;
        uint256 severity; // 1-5, with 5 being most severe
        uint256 createdAt;
        uint256 updatedAt;
        address creator;
        address updater;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public policyManager;
    mapping(bytes32 => SecurityPolicy) public policies;
    mapping(bytes32 => uint256) public violationCount;
    uint256 public totalPolicies;
    uint256 public activePolicies;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert SecurityPolicyManager_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyPolicyManager() {
        if (msg.sender != policyManager) revert SecurityPolicyManager_OnlyPolicyManager(msg.sender);
        _;
    }

    modifier policyExists(bytes32 policyId_) {
        if (policies[policyId_].createdAt == 0) revert SecurityPolicyManager_PolicyNotFound(policyId_);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address policyManager_) {
        admin = admin_;
        policyManager = policyManager_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Create a new security policy
    /// @param policyId_ The policy identifier
    /// @param severity_ The severity level (1-5)
    function createPolicy(bytes32 policyId_, uint256 severity_) external onlyAdmin {
        if (policies[policyId_].createdAt != 0) revert SecurityPolicyManager_PolicyAlreadyExists(policyId_);
        
        policies[policyId_] = SecurityPolicy({
            policyId: policyId_,
            isActive: true,
            severity: severity_,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            creator: msg.sender,
            updater: msg.sender
        });
        
        totalPolicies++;
        activePolicies++;
        
        emit PolicyCreated(policyId_, msg.sender);
    }

    /// @notice Update an existing security policy
    /// @param policyId_ The policy identifier
    /// @param severity_ The new severity level
    /// @param isActive_ Whether the policy is active
    function updatePolicy(bytes32 policyId_, uint256 severity_, bool isActive_) external onlyAdmin policyExists(policyId_) {
        SecurityPolicy storage policy = policies[policyId_];
        
        if (policy.isActive != isActive_) {
            if (isActive_) {
                activePolicies++;
                emit PolicyActivated(policyId_);
            } else {
                activePolicies--;
                emit PolicyDeactivated(policyId_);
            }
        }
        
        policy.severity = severity_;
        policy.isActive = isActive_;
        policy.updatedAt = block.timestamp;
        policy.updater = msg.sender;
        
        emit PolicyUpdated(policyId_, msg.sender);
    }

    /// @notice Report a security violation
    /// @param violator_ The address that violated the policy
    /// @param policyId_ The policy identifier
    /// @param violationType_ The type of violation
    function reportViolation(address violator_, bytes32 policyId_, bytes32 violationType_) external onlyPolicyManager policyExists(policyId_) {
        SecurityPolicy storage policy = policies[policyId_];
        
        if (!policy.isActive) revert SecurityPolicyManager_PolicyNotFound(policyId_);
        
        violationCount[policyId_]++;
        
        emit SecurityViolation(violator_, policyId_, violationType_);
    }

    /// @notice Check if a policy is active
    /// @param policyId_ The policy identifier
    /// @return Whether the policy is active
    function isPolicyActive(bytes32 policyId_) external view policyExists(policyId_) returns (bool) {
        return policies[policyId_].isActive;
    }

    /// @notice Get the total number of security violations for a policy
    /// @param policyId_ The policy identifier
    /// @return The total number of violations
    function getViolationCount(bytes32 policyId_) external view policyExists(policyId_) returns (uint256) {
        return violationCount[policyId_];
    }

    /// @notice Get the total number of active policies
    /// @return The total number of active policies
    function getActivePolicyCount() external view returns (uint256) {
        return activePolicies;
    }

    /// @notice Get the total number of policies
    /// @return The total number of policies
    function getTotalPolicyCount() external view returns (uint256) {
        return totalPolicies;
    }
}