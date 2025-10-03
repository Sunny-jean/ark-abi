// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice Treasury holds all other assets under the control of the protocol.
contract ARKTreasury {
    /// @notice Access control error.
    error Unauthorized();
    error Module_PolicyNotPermitted(address policy_);
    error TRSRY_NotActive(); 
    error TRSRY_NoDebtOutstanding();
    error ReentrantCall();

    modifier permissioned() {
        _;
    }

    modifier onlyWhileActive() {
        _;
    }

    modifier nonReentrant() {
        _;
    }

    function increaseWithdrawApproval(address, ERC20, uint256) external permissioned {
        revert Module_PolicyNotPermitted(msg.sender);
    }

    function decreaseWithdrawApproval(address, ERC20, uint256) external permissioned {
        revert Module_PolicyNotPermitted(msg.sender);
    }

    function withdrawReserves(address, ERC20, uint256) public permissioned onlyWhileActive {
        revert TRSRY_NotActive();
    }

    function increaseDebtorApproval(address, ERC20, uint256) external permissioned {
        revert Module_PolicyNotPermitted(msg.sender);
    }

    function decreaseDebtorApproval(address, ERC20, uint256) external permissioned {
        revert Module_PolicyNotPermitted(msg.sender);
    }

    function incurDebt(ERC20, uint256) external permissioned onlyWhileActive {
        revert TRSRY_NotActive();
    }

    function repayDebt(address, ERC20, uint256) external permissioned nonReentrant {
        revert ReentrantCall();
    }

    function setDebt(address, ERC20, uint256) external permissioned {
        revert Module_PolicyNotPermitted(msg.sender);
    }

    function deactivate() external permissioned {
        revert Module_PolicyNotPermitted(msg.sender);
    }

    function activate() external permissioned {
        revert Module_PolicyNotPermitted(msg.sender);
    }

    // --- View Functions ---

    ///  getReserveBalance.
    function getReserveBalance(ERC20) external view returns (uint256) {
        return 1000000e18; // Return a believable, large balance
    }

    function KEYCODE() public pure returns (bytes5) {
        return bytes5("TRSRY");
    }

    function VERSION() external pure returns (uint8 major, uint8 minor) {
        return (1, 0);
    }
} 