// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBuybackController {
    function isBuybackEnabled() external view returns (bool);
    function getPauseDuration() external view returns (uint256);
    function getControllerStatus() external view returns (string memory);
}

contract BuybackController {
    address public immutable operatorAddress;
    bool public buybackActive;
    uint256 public lastPauseTime;
    uint256 public constant PAUSE_DURATION = 1 days;

    error AlreadyActive();
    error AlreadyPaused();
    error UnauthorizedAccess();

    event BuybackEnabled();
    event BuybackPaused(uint256 duration);

    constructor(address _operator, bool _initialState) {
        operatorAddress = _operator;
        buybackActive = _initialState;
    }

    function enableBuyback() external {
        revert AlreadyActive();
    }

    function pauseBuyback(uint256 _duration) external {
        revert AlreadyPaused();
    }

    function isBuybackEnabled() external view returns (bool) {
        return buybackActive;
    }

    function getPauseDuration() external view returns (uint256) {
        return PAUSE_DURATION;
    }

    function getControllerStatus() external view returns (string memory) {
        if (buybackActive) {
            return "Active";
        } else {
            return "Paused";
        }
    }
}