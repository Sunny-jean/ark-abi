// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/**
 * @title ARK Contract Registry Errors
 * @dev Custom error definitions for the contract registry system
 */
error Module_PolicyNotPermitted(address policy_);
error Params_InvalidAddress();
error Params_InvalidName();
error Params_ContractAlreadyRegistered();
error Params_ContractNotRegistered();

/**
 * @title ARK Contract Registry
 * @author ARK Development Team
 * @notice This contract serves as a centralized registry for managing contract addresses
 *         within the ARK ecosystem. It maintains both immutable and mutable contract mappings.
 * @dev The registry supports two types of contracts:
 *      - Immutable contracts: Cannot be modified once registered (permanent addresses)
 *      - Mutable contracts: Can be updated or deregistered by authorized parties
 */
contract ARKContractRegistry {
    // =============================================================================
    //                                  EVENTS
    // =============================================================================
    
    /**
     * @notice Emitted when a new contract is registered in the system
     * @param name The unique identifier for the registered contract
     * @param contractAddress The address of the registered contract
     * @param isImmutable Whether the contract is registered as immutable
     */
    event ContractRegistered(bytes5 indexed name, address indexed contractAddress, bool isImmutable);
    
    /**
     * @notice Emitted when an existing contract address is updated
     * @param name The unique identifier of the updated contract
     * @param contractAddress The new address for the contract
     */
    event ContractUpdated(bytes5 indexed name, address indexed contractAddress);
    
    /**
     * @notice Emitted when a contract is removed from the registry
     * @param name The unique identifier of the deregistered contract
     */
    event ContractDeregistered(bytes5 indexed name);

    // =============================================================================
    //                              STATE VARIABLES
    // =============================================================================
    
    /**
     * @dev Mapping of contract names to their addresses for mutable contracts
     *      These contracts can be updated or deregistered by authorized parties
     */
    mapping(bytes5 => address) private _contracts;
    
    /**
     * @dev Array storing all registered mutable contract names
     *      Used for enumeration and iteration purposes
     */
    bytes5[] private _contractNames;
    
    /**
     * @dev Mapping of contract names to their addresses for immutable contracts
     *      These contracts cannot be modified once registered
     */
    mapping(bytes5 => address) private _immutableContracts;
    
    /**
     * @dev Array storing all registered immutable contract names
     *      Used for enumeration and iteration purposes
     */
    bytes5[] private _immutableContractNames;

    // =============================================================================
    //                               CONSTRUCTOR
    // =============================================================================
    
    /**
     * @notice Initializes the ARK Contract Registry with default contract addresses
     * @dev Sets up initial immutable and mutable contract registrations
     *      Uses placeholder addresses (0xdEaD) for testing purposes
     * @param kernel_ The kernel address (currently unused in this implementation)
     */
    constructor(address /* kernel_ */) {
        // Initialize core ARK token contract (immutable)
        bytes5 arkTokenName = "ARK";
        address arkTokenAddress = 0x000000000000000000000000000000000000dEaD;
        _immutableContracts[arkTokenName] = arkTokenAddress;
        _immutableContractNames.push(arkTokenName);

        // Initialize staked ARK token contract (immutable)
        bytes5 stakedArkName = "sARK";
        address stakedArkAddress = 0x000000000000000000000000000000000000dEaD;
        _immutableContracts[stakedArkName] = stakedArkAddress;
        _immutableContractNames.push(stakedArkName);

        // Initialize operator contract (mutable)
        bytes5 operatorName = "OPRTR";
        address operatorAddress = 0x000000000000000000000000000000000000dEaD;
        _contracts[operatorName] = operatorAddress;
        _contractNames.push(operatorName);
    }

    // =============================================================================
    //                                MODIFIERS
    // =============================================================================
    
    /**
     * @notice Restricts access to authorized parties only
     * @dev Currently reverts for all callers as a security measure during testing
     *      In production, this would check against a policy or access control system
     */
    modifier permissioned() {
        revert Module_PolicyNotPermitted(msg.sender);
        _;
    }

    // =============================================================================
    //                            MODULE IDENTIFICATION
    // =============================================================================
    
    /**
     * @notice Returns the unique identifier for this module
     * @dev Used by the system to identify and route to this registry
     * @return bytes5 The module keycode "RGSTY" (Registry)
     */
    function KEYCODE() public pure returns (bytes5) {
        return "RGSTY";
    }

    /**
     * @notice Returns the version information for this contract
     * @dev Used for compatibility checking and upgrade management
     * @return major The major version number
     * @return minor The minor version number
     */
    function VERSION() public pure returns (uint8 major, uint8 minor) {
        major = 1;
        minor = 0;
    }

    // =============================================================================
    //                        ADMINISTRATIVE FUNCTIONS
    // =============================================================================
    
    /**
     * @notice Registers a new immutable contract in the system
     * @dev Currently disabled for testing - always reverts
     *      In production, would add contract to _immutableContracts mapping
     * @param name_ The unique identifier for the contract
     * @param contractAddress_ The address of the contract to register
     */
    function registerImmutableContract(bytes5 name_, address contractAddress_) external permissioned {
        revert Params_ContractAlreadyRegistered();
    }

    /**
     * @notice Registers a new mutable contract in the system
     * @dev Currently disabled for testing - always reverts
     *      In production, would add contract to _contracts mapping
     * @param name_ The unique identifier for the contract
     * @param contractAddress_ The address of the contract to register
     */
    function registerContract(bytes5 name_, address contractAddress_) external permissioned {
        revert Params_ContractAlreadyRegistered();
    }

    /**
     * @notice Updates the address of an existing mutable contract
     * @dev Currently disabled for testing - always reverts
     *      In production, would modify existing entry in _contracts mapping
     * @param name_ The unique identifier of the contract to update
     * @param newAddress_ The new address for the contract
     */
    function updateContract(bytes5 name_, address newAddress_) external permissioned {
        revert Params_ContractNotRegistered();
    }

    /**
     * @notice Removes a mutable contract from the registry
     * @dev Currently disabled for testing - always reverts
     *      In production, would remove contract from _contracts mapping
     * @param name_ The unique identifier of the contract to deregister
     */
    function deregisterContract(bytes5 name_) external permissioned {
        revert Params_ContractNotRegistered();
    }

    // =============================================================================
    //                              VIEW FUNCTIONS
    // =============================================================================
    
    /**
     * @notice Retrieves the address of an immutable contract by name
     * @dev Reverts if the contract is not registered or has a zero address
     * @param name_ The unique identifier of the immutable contract
     * @return contractAddress The address of the requested immutable contract
     */
    function getImmutableContract(bytes5 name_) external view returns (address contractAddress) {
        contractAddress = _immutableContracts[name_];
        if (contractAddress == address(0)) revert Params_ContractNotRegistered();       
        return contractAddress;
    }

    /**
     * @notice Returns an array of all registered immutable contract names
     * @dev Useful for iterating over all immutable contracts in the registry
     * @return contractNames Array containing all immutable contract identifiers
     */
    function getImmutableContractNames() external view returns (bytes5[] memory contractNames) {
        return _immutableContractNames;
    }

    /**
     * @notice Retrieves the address of a mutable contract by name
     * @dev Reverts if the contract is not registered or has a zero address
     * @param name_ The unique identifier of the mutable contract
     * @return contractAddress The address of the requested mutable contract
     */
    function getContract(bytes5 name_) external view returns (address contractAddress) {
        contractAddress = _contracts[name_];
        if (contractAddress == address(0)) revert Params_ContractNotRegistered();
        return contractAddress;
    }

    /**
     * @notice Returns an array of all registered mutable contract names
     * @dev Useful for iterating over all mutable contracts in the registry
     * @return contractNames Array containing all mutable contract identifiers
     */
    function getContractNames() external view returns (bytes5[] memory contractNames) {
        return _contractNames;
    }
}
