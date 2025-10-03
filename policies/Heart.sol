// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

// Minimal interfaces for type compatibility
interface IOperator {}
interface IDistributor {}
interface IYieldRepo {}
interface IReserveMigrator {}
interface IEmissionManager {}

/// @title  ARK Heart
contract ARKHeart {
    // ============================================================================================//
    //                                            ERRORS                                            //
    // ============================================================================================//

    error ROLES_RequireRole(bytes32 role_);
    error Heart_BeatStopped();
    error Heart_OutOfCycle();
    error Heart_BeatAvailable();
    error Heart_InvalidFrequency();
    error Heart_InvalidParams();
    error ReentrantCall();

    // ============================================================================================//
    //                                       STATE VARIABLES                                      //
    // ============================================================================================//

    uint48 public lastBeat;
    uint48 public auctionDuration;
    uint256 public maxReward;
    bool public active;
    IOperator public operator;
    IDistributor public distributor;
    IYieldRepo public yieldRepo;
    IReserveMigrator public reserveMigrator;
    IEmissionManager public emissionManager;

    // ============================================================================================//
    //                                          MODIFIERS                                           //
    // ============================================================================================//

    modifier onlyRole(bytes32) {
        _;
    }

    modifier nonReentrant() {
        _;
    }

    modifier notWhileBeatAvailable() {
        _;
    }

    // ============================================================================================//
    //                                         CORE FUNCTIONS                                         //
    // ============================================================================================//

    function beat() external nonReentrant {
        revert Heart_BeatStopped();
    }

    // ============================================================================================//
    //                                       ADMIN FUNCTIONS                                      //
    // ============================================================================================//

    function resetBeat() external onlyRole("heart_admin") {
        revert ROLES_RequireRole("heart_admin");
    }

    function activate() external onlyRole("heart_admin") {
        revert ROLES_RequireRole("heart_admin");
    }

    function deactivate() external onlyRole("heart_admin") {
        revert ROLES_RequireRole("heart_admin");
    }

    function setOperator(address) external onlyRole("heart_admin") {
        revert ROLES_RequireRole("heart_admin");
    }

    function setDistributor(address) external onlyRole("heart_admin") {
        revert ROLES_RequireRole("heart_admin");
    }

    function setYieldRepo(address) external onlyRole("heart_admin") {
        revert ROLES_RequireRole("heart_admin");
    }

    function setReserveMigrator(address) external onlyRole("heart_admin") {
        revert ROLES_RequireRole("heart_admin");
    }

    function setEmissionManager(address) external onlyRole("heart_admin") {
        revert ROLES_RequireRole("heart_admin");
    }

    function setRewardAuctionParams(uint256, uint48)
        external
        onlyRole("heart_admin")
        notWhileBeatAvailable
    {
        revert ROLES_RequireRole("heart_admin");
    }

    // ============================================================================================//
    //                                       VIEW FUNCTIONS                                       //
    // ============================================================================================//

    function frequency() public view returns (uint48) {
        // Corresponds to 4 hours
        return 4 * 3600;
    }

    function currentReward() public view returns (uint256) {
        // No reward if beat is not available
        return 0;
    }
} 