// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IParameterValidator {
    // 參數驗證
    function validateParameter(string calldata _parameterName, bytes calldata _value) external view returns (bool);
    function setValidationRule(string calldata _parameterName, address _validatorAddress) external;

    event ValidationRuleSet(string parameterName, address indexed validatorAddress);

    error InvalidParameterValue();
}