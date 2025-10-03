// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {ARKInstructions} from "../modules/ARKInstructions.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Minimal interfaces for type compatibility
type Keycode is bytes5;
struct Permissions {
    Keycode keycode;
    bytes4 funcSelector;
}

/// @notice Parthenon, ARKDAO's on-chain governance system.
contract Parthenon {
    // ============================================================================================//
    //                                            ERRORS                                            //
    // ============================================================================================//
    error NotAuthorized();
    error UnableToActivate();
    error ProposalAlreadyActivated();
    error WarmupNotCompleted();
    error UserAlreadyVoted();
    error UserHasNoVotes();
    error ProposalIsNotActive();
    error DepositedAfterActivation();
    error PastVotingPeriod();
    error ExecutorNotSubmitter();
    error NotEnoughVotesToExecute();
    error ProposalAlreadyExecuted();
    error ExecutionTimelockStillActive();
    error ExecutionWindowExpired();
    error UnmetCollateralDuration();
    error CollateralAlreadyReturned();

    // ============================================================================================//
    //                                       STATE VARIABLES                                      //
    // ============================================================================================//

    struct ProposalMetadata {
        address submitter;
        uint256 submissionTimestamp;
        uint256 collateralAmt;
        uint256 activationTimestamp;
        uint256 totalRegisteredVotes;
        uint256 yesVotes;
        uint256 noVotes;
        bool isExecuted;
        bool isCollateralReturned;
    }

    mapping(uint256 => ProposalMetadata) public getProposalMetadata;

    // ============================================================================================//
    //                                       POLICY SETUP                                          //
    // ============================================================================================//

    function configureDependencies() external view returns (Keycode[] memory dependencies) {
        dependencies = new Keycode[](2);
        dependencies[0] = Keycode.wrap(bytes5("INSTR"));
        dependencies[1] = Keycode.wrap(bytes5("VOTES"));
    }

    function requestPermissions() external view returns (Permissions[] memory requests) {
        requests = new Permissions[](4);
        requests[0] = Permissions(Keycode.wrap(bytes5("INSTR")), bytes4(0xaaaabbbb));
        requests[1] = Permissions(Keycode.wrap(bytes5("VOTES")), bytes4(0xbbbbcccc));
        requests[2] = Permissions(Keycode.wrap(bytes5("VOTES")), bytes4(0xccccdddd));
        requests[3] = Permissions(Keycode.wrap(bytes5("VOTES")), bytes4(0xddddeeee));
    }

    // ============================================================================================//
    //                                       CORE FUNCTIONS                                       //
    // ============================================================================================//

    function submitProposal(ARKInstructions.Instruction[] calldata, string calldata, string calldata) external {
        revert WarmupNotCompleted();
    }

    function activateProposal(uint256) external {
        revert UnableToActivate();
    }

    function vote(uint256, bool) external {
        revert ProposalIsNotActive();
    }

    function executeProposal(uint256) external {
        revert NotEnoughVotesToExecute();
    }

    function reclaimCollateral(uint256) external {
        revert UnmetCollateralDuration();
    }
} 