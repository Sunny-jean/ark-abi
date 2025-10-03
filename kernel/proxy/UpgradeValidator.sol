// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Upgrade Validator
/// @notice Validates upgrade proposals to ensure they meet system requirements
contract UpgradeValidator {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ValidationRuleAdded(uint256 indexed ruleId, string name, bool isActive);
    event ValidationRuleUpdated(uint256 indexed ruleId, bool isActive);
    event ValidationRuleRemoved(uint256 indexed ruleId);
    event UpgradeValidated(address indexed implementation, bool success, string reason);
    event ValidatorAdded(address indexed validator, uint256 indexed validatorType);
    event ValidatorRemoved(address indexed validator);
    event ValidationThresholdChanged(uint256 oldThreshold, uint256 newThreshold);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error UpgradeValidator_OnlyAdmin(address caller_);
    error UpgradeValidator_InvalidAddress(address addr_);
    error UpgradeValidator_ValidationFailed(address implementation_, string reason_);
    error UpgradeValidator_RuleNotFound(uint256 ruleId_);
    error UpgradeValidator_RuleAlreadyExists(string name_);
    error UpgradeValidator_ValidatorAlreadyExists(address validator_);
    error UpgradeValidator_ValidatorNotFound(address validator_);
    error UpgradeValidator_InvalidThreshold(uint256 threshold_);
    error UpgradeValidator_InsufficientValidations(uint256 received_, uint256 required_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    enum ValidatorType {
        SecurityValidator,
        FunctionalValidator,
        PerformanceValidator,
        ComplianceValidator
    }

    struct ValidationRule {
        uint256 id;
        string name;
        string description;
        bool isActive;
        bool isCritical; // If true, failing this rule will block the upgrade
    }

    struct ValidationResult {
        bool success;
        string reason;
        uint256 timestamp;
        address validator;
    }

    struct UpgradeValidation {
        address implementation;
        mapping(uint256 => ValidationResult) ruleResults; // ruleId => result
        mapping(address => bool) validatorApprovals; // validator => approved
        uint256 approvalCount;
        bool isValid;
        uint256 timestamp;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    
    // Validation rules
    mapping(uint256 => ValidationRule) public validationRules;
    mapping(string => uint256) public ruleIdByName;
    uint256 public nextRuleId;
    uint256 public activeRuleCount;
    
    // Validators
    mapping(address => bool) public isValidator;
    mapping(address => ValidatorType) public validatorTypes;
    address[] public validators;
    
    // Validation threshold (percentage of validators required to approve)
    uint256 public validationThreshold; // 1-100 representing percentage
    
    // Upgrade validations
    mapping(address => UpgradeValidation) public upgradeValidations;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert UpgradeValidator_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyValidator() {
        if (!isValidator[msg.sender]) revert UpgradeValidator_ValidatorNotFound(msg.sender);
        _;
    }

    modifier ruleExists(uint256 ruleId_) {
        if (ruleId_ >= nextRuleId || validationRules[ruleId_].id != ruleId_) {
            revert UpgradeValidator_RuleNotFound(ruleId_);
        }
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, uint256 validationThreshold_) {
        if (admin_ == address(0)) revert UpgradeValidator_InvalidAddress(admin_);
        if (validationThreshold_ < 1 || validationThreshold_ > 100) {
            revert UpgradeValidator_InvalidThreshold(validationThreshold_);
        }
        
        admin = admin_;
        validationThreshold = validationThreshold_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Add a new validation rule
    /// @param name_ Rule name
    /// @param description_ Rule description
    /// @param isActive_ Whether the rule is active
    /// @param isCritical_ Whether failing this rule blocks the upgrade
    /// @return ruleId The ID of the new rule
    function addValidationRule(
        string calldata name_,
        string calldata description_,
        bool isActive_,
        bool isCritical_
    ) external onlyAdmin returns (uint256) {
        // Check if rule with this name already exists
        if (ruleIdByName[name_] != 0) revert UpgradeValidator_RuleAlreadyExists(name_);
        
        uint256 ruleId = nextRuleId++;
        
        // Create validation rule
        validationRules[ruleId] = ValidationRule({
            id: ruleId,
            name: name_,
            description: description_,
            isActive: isActive_,
            isCritical: isCritical_
        });
        
        // Map name to ID
        ruleIdByName[name_] = ruleId;
        
        // Update active rule count
        if (isActive_) {
            activeRuleCount++;
        }
        
        emit ValidationRuleAdded(ruleId, name_, isActive_);
        
        return ruleId;
    }

    /// @notice Update a validation rule
    /// @param ruleId_ Rule ID
    /// @param isActive_ Whether the rule is active
    /// @param isCritical_ Whether failing this rule blocks the upgrade
    function updateValidationRule(
        uint256 ruleId_,
        bool isActive_,
        bool isCritical_
    ) external onlyAdmin ruleExists(ruleId_) {
        ValidationRule storage rule = validationRules[ruleId_];
        
        // Update active rule count
        if (rule.isActive != isActive_) {
            if (isActive_) {
                activeRuleCount++;
            } else {
                activeRuleCount--;
            }
        }
        
        // Update rule
        rule.isActive = isActive_;
        rule.isCritical = isCritical_;
        
        emit ValidationRuleUpdated(ruleId_, isActive_);
    }

    /// @notice Remove a validation rule
    /// @param ruleId_ Rule ID
    function removeValidationRule(uint256 ruleId_) external onlyAdmin ruleExists(ruleId_) {
        ValidationRule storage rule = validationRules[ruleId_];
        
        // Update active rule count
        if (rule.isActive) {
            activeRuleCount--;
        }
        
        // Remove name mapping
        delete ruleIdByName[rule.name];
        
        // Remove rule
        delete validationRules[ruleId_];
        
        emit ValidationRuleRemoved(ruleId_);
    }

    /// @notice Add a validator
    /// @param validator_ Validator address
    /// @param validatorType_ Validator type
    function addValidator(address validator_, ValidatorType validatorType_) external onlyAdmin {
        if (validator_ == address(0)) revert UpgradeValidator_InvalidAddress(validator_);
        if (isValidator[validator_]) revert UpgradeValidator_ValidatorAlreadyExists(validator_);
        
        // Add validator
        isValidator[validator_] = true;
        validatorTypes[validator_] = validatorType_;
        validators.push(validator_);
        
        emit ValidatorAdded(validator_, uint256(validatorType_));
    }

    /// @notice Remove a validator
    /// @param validator_ Validator address
    function removeValidator(address validator_) external onlyAdmin {
        if (!isValidator[validator_]) revert UpgradeValidator_ValidatorNotFound(validator_);
        
        // Remove validator
        isValidator[validator_] = false;
        delete validatorTypes[validator_];
        
        // Remove from array
        for (uint256 i = 0; i < validators.length; i++) {
            if (validators[i] == validator_) {
                validators[i] = validators[validators.length - 1];
                validators.pop();
                break;
            }
        }
        
        emit ValidatorRemoved(validator_);
    }

    /// @notice Set validation threshold
    /// @param threshold_ New threshold (1-100 representing percentage)
    function setValidationThreshold(uint256 threshold_) external onlyAdmin {
        if (threshold_ < 1 || threshold_ > 100) {
            revert UpgradeValidator_InvalidThreshold(threshold_);
        }
        
        uint256 oldThreshold = validationThreshold;
        validationThreshold = threshold_;
        
        emit ValidationThresholdChanged(oldThreshold, threshold_);
    }

    /// @notice Validate an implementation against a specific rule
    /// @param implementation_ Implementation address
    /// @param ruleId_ Rule ID
    /// @param success_ Whether the validation succeeded
    /// @param reason_ Reason for validation result
    function validateRule(
        address implementation_,
        uint256 ruleId_,
        bool success_,
        string calldata reason_
    ) external onlyValidator ruleExists(ruleId_) {
        if (implementation_ == address(0)) revert UpgradeValidator_InvalidAddress(implementation_);
        
        ValidationRule storage rule = validationRules[ruleId_];
        
        // Skip inactive rules
        if (!rule.isActive) return;
        
        // Record validation result
        UpgradeValidation storage validation = upgradeValidations[implementation_];
        validation.implementation = implementation_;
        validation.ruleResults[ruleId_] = ValidationResult({
            success: success_,
            reason: reason_,
            timestamp: block.timestamp,
            validator: msg.sender
        });
        
        // If critical rule fails, mark implementation as invalid
        if (rule.isCritical && !success_) {
            validation.isValid = false;
            emit UpgradeValidated(implementation_, false, reason_);
        }
    }

    /// @notice Approve an implementation
    /// @param implementation_ Implementation address
    function approveImplementation(address implementation_) external onlyValidator {
        if (implementation_ == address(0)) revert UpgradeValidator_InvalidAddress(implementation_);
        
        UpgradeValidation storage validation = upgradeValidations[implementation_];
        
        // Record validator approval
        if (!validation.validatorApprovals[msg.sender]) {
            validation.validatorApprovals[msg.sender] = true;
            validation.approvalCount++;
        }
        
        // Check if implementation is now valid
        uint256 requiredApprovals = (validators.length * validationThreshold) / 100;
        if (validation.approvalCount >= requiredApprovals) {
            validation.isValid = true;
            validation.timestamp = block.timestamp;
            emit UpgradeValidated(implementation_, true, "Sufficient validator approvals");
        }
    }

    /// @notice Check if an implementation is valid
    /// @param implementation_ Implementation address
    /// @return Whether the implementation is valid
    function isImplementationValid(address implementation_) external view returns (bool) {
        return upgradeValidations[implementation_].isValid;
    }

    /// @notice Get validation result for a rule
    /// @param implementation_ Implementation address
    /// @param ruleId_ Rule ID
    /// @return success Whether the validation succeeded
    /// @return reason Reason for validation result
    /// @return timestamp When the validation occurred
    /// @return validator Who performed the validation
    function getValidationResult(
        address implementation_,
        uint256 ruleId_
    ) external view ruleExists(ruleId_) returns (
        bool success,
        string memory reason,
        uint256 timestamp,
        address validator
    ) {
        ValidationResult memory result = upgradeValidations[implementation_].ruleResults[ruleId_];
        return (
            result.success,
            result.reason,
            result.timestamp,
            result.validator
        );
    }

    /// @notice Get approval count for an implementation
    /// @param implementation_ Implementation address
    /// @return approvalCount Number of validator approvals
    /// @return requiredApprovals Number of approvals required for validity
    function getApprovalCounts(address implementation_) external view returns (
        uint256 approvalCount,
        uint256 requiredApprovals
    ) {
        approvalCount = upgradeValidations[implementation_].approvalCount;
        requiredApprovals = (validators.length * validationThreshold) / 100;
        return (approvalCount, requiredApprovals);
    }

    /// @notice Get all validators
    /// @return Array of validator addresses
    function getValidators() external view returns (address[] memory) {
        return validators;
    }

    /// @notice Get validator count
    /// @return Number of validators
    function getValidatorCount() external view returns (uint256) {
        return validators.length;
    }

    /// @notice Get active rule count
    /// @return Number of active validation rules
    function getActiveRuleCount() external view returns (uint256) {
        return activeRuleCount;
    }

    /// @notice Get rule details
    /// @param ruleId_ Rule ID
    /// @return id Rule ID
    /// @return name Rule name
    /// @return description Rule description
    /// @return isActive Whether the rule is active
    /// @return isCritical Whether failing this rule blocks the upgrade
    function getRuleDetails(uint256 ruleId_) external view ruleExists(ruleId_) returns (
        uint256 id,
        string memory name,
        string memory description,
        bool isActive,
        bool isCritical
    ) {
        ValidationRule memory rule = validationRules[ruleId_];
        return (
            rule.id,
            rule.name,
            rule.description,
            rule.isActive,
            rule.isCritical
        );
    }
}