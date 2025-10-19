// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTTradeValidator {
    function validateTrade(uint256 _tokenId, address _buyer, uint256 _price) external view returns (bool);
    function setValidationRule(uint256 _ruleId, bool _enabled) external;

    event ValidationRuleSet(uint256 indexed ruleId, bool enabled);

    error InvalidTrade();
}