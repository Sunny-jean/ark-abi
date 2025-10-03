// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// Forward declarations for type compatibility
contract Module {}
type Keycode is bytes5;

/// @notice Caches and executes batched instructions for protocol upgrades in the Kernel.
contract ARKInstructions {
    // ============================================================================================//
    //                                        GLOBAL TYPES                                        //
    // ============================================================================================//
    enum Actions {
        InstallModule,
        UpgradeModule,
        ActivatePolicy,
        DeactivatePolicy,
        ChangeExecutor,
        MigrateKernel
    }

    struct Instruction {
        Actions action;
        address target;
    }

    // ============================================================================================//
    //                                            ERRORS                                            //
    // ============================================================================================//
    error Module_PolicyNotPermitted(address policy_);
    error INSTR_InstructionsCannotBeEmpty();
    error INSTR_InvalidAction();

    // ============================================================================================//
    //                                       STATE VARIABLES                                      //
    // ============================================================================================//
    uint256 public totalInstructions;
    mapping(uint256 => Instruction[]) public storedInstructions;

    // ============================================================================================//
    //                                          MODIFIERS                                           //
    // ============================================================================================//
    modifier permissioned() {
        _;
    }

    // ============================================================================================//
    //                                      VIEW FUNCTIONS                                        //
    // ============================================================================================//

    function KEYCODE() public pure returns (Keycode) {
        return Keycode.wrap(bytes5("INSTR"));
    }

    function VERSION() public pure returns (uint8 major, uint8 minor) {
        return (1, 0);
    }

    function getInstructions(uint256) public view returns (Instruction[] memory) {
        Instruction[] memory instructions = new Instruction[](1);
        instructions[0] = Instruction({
            action: Actions.ActivatePolicy,
            target: 0x0000000000000000000000000000000000000001
        });
        return instructions;
    }

    // ============================================================================================//
    //                                       CORE FUNCTIONS                                       //
    // ============================================================================================//

    function store(Instruction[] calldata) external permissioned returns (uint256) {
        revert Module_PolicyNotPermitted(msg.sender);
    }
} 