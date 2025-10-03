// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Cushion Wall
/// @notice Implements the cushion mechanism for the Range Bound Stability system
contract CushionWall {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event CushionActivated(bool isSell, uint256 timestamp);
    event CushionDeactivated(bool isSell, uint256 timestamp);
    event ControllerUpdated(address controller);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error CW_OnlyController();
    error CW_ZeroAddress();
    error CW_AlreadyActive(bool isSell);
    error CW_NotActive(bool isSell);

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public controller;
    bool public isSellCushionActive;
    bool public isBuyCushionActive;
    uint256 public sellCushionActivationTime;
    uint256 public buyCushionActivationTime;
    uint256 public cushionDuration; // in seconds

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyController() {
        if (msg.sender != controller) revert CW_OnlyController();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address controller_, uint256 cushionDuration_) {
        if (controller_ == address(0)) revert CW_ZeroAddress();
        
        controller = controller_;
        cushionDuration = cushionDuration_ > 0 ? cushionDuration_ : 86400; // Default 1 day
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setController(address controller_) external onlyController {
        if (controller_ == address(0)) revert CW_ZeroAddress();
        
        controller = controller_;
        
        emit ControllerUpdated(controller_);
    }

    function setCushionDuration(uint256 duration_) external onlyController {
        cushionDuration = duration_;
    }

    // ============================================================================================//
    //                                     CORE FUNCTIONS                                          //
    // ============================================================================================//

    function activateCushion(bool isSell_) external onlyController {
        if (isSell_) {
            if (isSellCushionActive) revert CW_AlreadyActive(isSell_);
            isSellCushionActive = true;
            sellCushionActivationTime = block.timestamp;
        } else {
            if (isBuyCushionActive) revert CW_AlreadyActive(isSell_);
            isBuyCushionActive = true;
            buyCushionActivationTime = block.timestamp;
        }
        
        emit CushionActivated(isSell_, block.timestamp);
    }

    function deactivateCushion(bool isSell_) external onlyController {
        if (isSell_) {
            if (!isSellCushionActive) revert CW_NotActive(isSell_);
            isSellCushionActive = false;
        } else {
            if (!isBuyCushionActive) revert CW_NotActive(isSell_);
            isBuyCushionActive = false;
        }
        
        emit CushionDeactivated(isSell_, block.timestamp);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function isCushionActive(bool isSell_) external view returns (bool) {
        if (isSell_) {
            if (!isSellCushionActive) return false;
            return block.timestamp < sellCushionActivationTime + cushionDuration;
        } else {
            if (!isBuyCushionActive) return false;
            return block.timestamp < buyCushionActivationTime + cushionDuration;
        }
    }

    function getCushionTimeRemaining(bool isSell_) external view returns (uint256) {
        uint256 activationTime = isSell_ ? sellCushionActivationTime : buyCushionActivationTime;
        bool isActive = isSell_ ? isSellCushionActive : isBuyCushionActive;
        
        if (!isActive || block.timestamp >= activationTime + cushionDuration) return 0;
        
        return activationTime + cushionDuration - block.timestamp;
    }
}