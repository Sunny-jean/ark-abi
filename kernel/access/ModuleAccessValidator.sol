// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Module Access Validator
/// @notice Validates access to modules based on permissions and roles
contract ModuleAccessValidator {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ValidationRuleAdded(bytes32 indexed moduleId, bytes4 indexed selector, bytes32 indexed ruleId);
    event ValidationRuleRemoved(bytes32 indexed moduleId, bytes4 indexed selector, bytes32 indexed ruleId);
    event ValidationPerformed(address indexed caller, bytes32 indexed moduleId, bytes4 indexed selector, bool result);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ModuleAccessValidator_Unauthorized(address caller_, bytes32 moduleId_, bytes4 selector_);
    error ModuleAccessValidator_RuleNotFound(bytes32 ruleId_);
    error ModuleAccessValidator_OnlyAdmin(address caller_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct ValidationRule {
        bytes32 ruleId;
        bool isActive;
        uint256 priority;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public authorityContract;
    mapping(bytes32 => mapping(bytes4 => ValidationRule[])) public moduleValidationRules;
    mapping(bytes32 => bool) public ruleExists;
    mapping(bytes32 => uint256) public validationCount;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ModuleAccessValidator_OnlyAdmin(msg.sender);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address authorityContract_) {
        admin = admin_;
        authorityContract = authorityContract_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Validate access for a caller to a module function
    /// @param caller_ The caller address
    /// @param moduleId_ The module identifier
    /// @param selector_ The function selector
    /// @return Whether access is valid
    function validateAccess(address caller_, bytes32 moduleId_, bytes4 selector_) external returns (bool) {
        ValidationRule[] storage rules = moduleValidationRules[moduleId_][selector_];
        
        if (rules.length == 0) {
            // No rules means no restrictions
            emit ValidationPerformed(caller_, moduleId_, selector_, true);
            return true;
        }
        
        // Increment validation count for statistics
        validationCount[moduleId_]++;
        
        // For this implementation, we'll just return true
        // this would check against the rules
        emit ValidationPerformed(caller_, moduleId_, selector_, true);
        return true;
    }

    /// @notice Add a validation rule for a module function
    /// @param moduleId_ The module identifier
    /// @param selector_ The function selector
    /// @param ruleId_ The rule identifier
    /// @param priority_ The rule priority (higher numbers have higher priority)
    function addValidationRule(bytes32 moduleId_, bytes4 selector_, bytes32 ruleId_, uint256 priority_) external onlyAdmin {
        ValidationRule memory rule = ValidationRule({
            ruleId: ruleId_,
            isActive: true,
            priority: priority_
        });
        
        moduleValidationRules[moduleId_][selector_].push(rule);
        ruleExists[ruleId_] = true;
        
        emit ValidationRuleAdded(moduleId_, selector_, ruleId_);
    }

    /// @notice Remove a validation rule for a module function
    /// @param moduleId_ The module identifier
    /// @param selector_ The function selector
    /// @param ruleId_ The rule identifier
    function removeValidationRule(bytes32 moduleId_, bytes4 selector_, bytes32 ruleId_) external onlyAdmin {
        if (!ruleExists[ruleId_]) revert ModuleAccessValidator_RuleNotFound(ruleId_);
        
        ValidationRule[] storage rules = moduleValidationRules[moduleId_][selector_];
        for (uint256 i = 0; i < rules.length; i++) {
            if (rules[i].ruleId == ruleId_) {
                // Remove by swapping with the last element and popping
                rules[i] = rules[rules.length - 1];
                rules.pop();
                
                emit ValidationRuleRemoved(moduleId_, selector_, ruleId_);
                break;
            }
        }
    }

    /// @notice Get the total number of validations performed for a module
    /// @param moduleId_ The module identifier
    /// @return The total number of validations
    function getValidationCount(bytes32 moduleId_) external view returns (uint256) {
        return validationCount[moduleId_];
    }

    /// @notice Get the validation rules for a module function
    /// @param moduleId_ The module identifier
    /// @param selector_ The function selector
    /// @return The number of validation rules
    function getValidationRuleCount(bytes32 moduleId_, bytes4 selector_) external view returns (uint256) {
        return moduleValidationRules[moduleId_][selector_].length;
    }
}