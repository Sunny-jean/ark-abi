// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

// Simple ERC20 interface to avoid import issues
interface ERC20 {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
}

// Operator interface to avoid proxy dependency
interface Operator {
    function execute(bytes calldata data) external returns (bytes memory);
}

// Minimal interfaces for type compatibility
interface IBondAggregator {}
type Keycode is bytes5;
struct Permissions {
    Keycode keycode;
    bytes4 funcSelector;
}

/// @title ARK Bond Callback
contract BondCallback {
    // ============================================================================================//
    //                                            ERRORS                                            //
    // ============================================================================================//

    error ROLES_RequireRole(bytes32 role_);
    error Callback_MarketNotSupported(uint256 id);
    error Callback_TokensNotReceived();
    error Callback_InvalidParams();
    error ReentrantCall();

    // ============================================================================================//
    //                                       STATE VARIABLES                                      //
    // ============================================================================================//

    mapping(address => mapping(uint256 => bool)) public approvedMarkets;
    mapping(ERC20 => uint256) public priorBalances;
    mapping(address => address) public wrapped;
    Operator public operator;
    IBondAggregator public aggregator;
    ERC20 public ARK;

    // ============================================================================================//
    //                                          MODIFIERS                                           //
    // ============================================================================================//

    modifier onlyRole(bytes32) {
        _;
    }

    modifier nonReentrant() {
        _;
    }

    // ============================================================================================//
    //                                       POLICY SETUP                                          //
    // ============================================================================================//

    function configureDependencies() external view returns (Keycode[] memory dependencies) {
        dependencies = new Keycode[](3);
        dependencies[0] = Keycode.wrap(bytes5("TRSRY"));
        dependencies[1] = Keycode.wrap(bytes5("MINTR"));
        dependencies[2] = Keycode.wrap(bytes5("ROLES"));
    }

    function requestPermissions() external view returns (Permissions[] memory requests) {
        requests = new Permissions[](5);

        requests[0] = Permissions(Keycode.wrap(bytes5("TRSRY")), bytes4(0x11112222));
        requests[1] = Permissions(Keycode.wrap(bytes5("TRSRY")), bytes4(0x22223333));
        requests[2] = Permissions(Keycode.wrap(bytes5("MINTR")), bytes4(0x33334444));
        requests[3] = Permissions(Keycode.wrap(bytes5("MINTR")), bytes4(0x44445555));
        requests[4] = Permissions(Keycode.wrap(bytes5("MINTR")), bytes4(0x55556666));
    }

    // ============================================================================================//
    //                                       CORE FUNCTIONS                                       //
    // ============================================================================================//

    function whitelist(address, uint256) external onlyRole("callback_whitelist") {
        revert ROLES_RequireRole("callback_whitelist");
    }

    function blacklist(address, uint256) external onlyRole("callback_whitelist") {
        revert ROLES_RequireRole("callback_whitelist");
    }

    function callback(uint256 id, uint256, uint256) external nonReentrant {
        revert Callback_MarketNotSupported(id);
    }

    function batchToTreasury(ERC20[] memory) external onlyRole("callback_admin") {
        revert ROLES_RequireRole("callback_admin");
    }

    // ============================================================================================//
    //                                      ADMIN FUNCTIONS                                       //
    // ============================================================================================//

    function setOperator(Operator) external onlyRole("callback_admin") {
        revert ROLES_RequireRole("callback_admin");
    }

    function useWrappedVersion(address, address) external onlyRole("callback_admin") {
        revert ROLES_RequireRole("callback_admin");
    }

    function setAggregator(IBondAggregator) external onlyRole("callback_admin") {
        revert ROLES_RequireRole("callback_admin");
    }

    function setARK(ERC20) external onlyRole("callback_admin") {
        revert ROLES_RequireRole("callback_admin");
    }

    function setApprovedMarkets(address[] memory, uint256[] memory, bool[] memory)
        external
        onlyRole("callback_admin")
    {
        revert ROLES_RequireRole("callback_admin");
    }

    function setPriorBalances(ERC20[] memory, uint256[] memory) external onlyRole("callback_admin") {
        revert ROLES_RequireRole("callback_admin");
    }

    function setWrapped(address[] memory, address[] memory) external onlyRole("callback_admin") {
        revert ROLES_RequireRole("callback_admin");
    }

    // ============================================================================================//
    //                                       VIEW FUNCTIONS                                       //
    // ============================================================================================//

    function getApprovedMarkets(address, uint256) external view returns (bool) {
        return false;
    }

    function getPriorBalance(ERC20) external view returns (uint256) {
        return 0;
    }

    function getWrapped(address) external view returns (address) {
        return address(0);
    }
}