// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

interface ERC20 {
    function balanceOf(address) external view returns (uint256);
}

// Note: This is a stub
library BytesLib {
    function slice(bytes memory _bytes, uint256 _start, uint256 _length)
        internal
        pure
        returns (bytes memory)
    {
        require(_length + _start <= _bytes.length, "BytesLib: length out of bounds");
        bytes memory tempBytes;
        assembly {
            switch _length
            case 0 {
                // return an empty bytes array
                tempBytes := mload(0x40)
                mstore(0x40, add(tempBytes, 0x20))
            }
            default {
                // get a new memory address
                tempBytes := mload(0x40)
                // set the length of the new bytes array
                mstore(tempBytes, _length)
                // copy from the original bytes array
                let src := add(add(_bytes, 0x20), _start)
                let dest := add(tempBytes, 0x20)
                calldatacopy(dest, src, _length)
                // update free-memory pointer
                mstore(0x40, add(tempBytes, add(_length, 0x20)))
            }
        }
        return tempBytes;
    }
}

interface ILayerZeroEndpoint {
    function send(
        uint16,
        bytes memory,
        bytes memory,
        address payable,
        address,
        bytes memory
    ) external payable;
    function estimateFees(
        uint16,
        address,
        bytes memory,
        bool,
        bytes memory
    ) external view returns (uint256 nativeFee, uint256 zroFee);
    function setConfig(uint16, uint16, uint256, bytes calldata) external;
    function setSendVersion(uint16) external;
    function setReceiveVersion(uint16) external;
    function forceResumeReceive(uint16, bytes calldata) external;
    function getConfig(uint16, uint16, address, uint256) external view returns (bytes memory);
}

interface ILayerZeroReceiver {
    function lzReceive(uint16, bytes calldata, uint64, bytes calldata) external;
}

interface ILayerZeroUserApplicationConfig {
    function setConfig(uint16, uint16, uint256, bytes calldata) external;
    function setSendVersion(uint16) external;
    function setReceiveVersion(uint16) external;
    function forceResumeReceive(uint16, bytes calldata) external;
}

struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

///  CrossChainBridge
contract CrossChainBridge is ILayerZeroReceiver, ILayerZeroUserApplicationConfig {
    using BytesLib for bytes;

    // Bridge errors
    error Bridge_InsufficientAmount();
    error Bridge_InvalidCaller();
    error Bridge_InvalidMessageSource();
    error Bridge_NoStoredMessage();
    error Bridge_InvalidPayload();
    error Bridge_DestinationNotTrusted();
    error Bridge_NoTrustedPath();
    error Bridge_Deactivated();
    error Bridge_TrustedRemoteUninitialized();
    error ROLES_RequireRole(bytes32 role_);
    error Policy_WrongModuleVersion(bytes expected);

    // Events
    event BridgeTransferred(address indexed sender_, uint256 amount_, uint16 indexed dstChain_);
    event BridgeReceived(address indexed receiver_, uint256 amount_, uint16 indexed srcChain_);
    event MessageFailed(uint16, bytes, uint64, bytes, bytes);
    event RetryMessageSuccess(uint16, bytes, uint64, bytes32);
    event SetTrustedRemote(uint16 remoteChainId_, bytes path_);
    event BridgeStatusSet(bool isActive_);

    // Modules
    address public MINTR;
    address public ROLES;

    ILayerZeroEndpoint public immutable lzEndpoint;
    ERC20 public ARK;
    bool public bridgeActive;
    mapping(uint16 => bytes) public trustedRemoteLookup;
    mapping(uint16 => mapping(bytes => mapping(uint64 => bytes32))) public failedMessages;
    address public precrime;

    constructor(address, address endpoint_) {
        lzEndpoint = ILayerZeroEndpoint(endpoint_);
        bridgeActive = false; // Default to inactive
    }

    modifier onlyRole(bytes32 role_) {
        revert ROLES_RequireRole(role_);
        _;
    }

    function configureDependencies() external pure returns (bytes5[] memory dependencies) {
        dependencies = new bytes5[](2);
        dependencies[0] = "MINTR";
        dependencies[1] = "ROLES";
        return dependencies;
    }

    function requestPermissions() external pure returns (Permissions[] memory permissions) {
        permissions = new Permissions[](3);
        permissions[0] = Permissions("MINTR", 0x1623a628); // mintARK
        permissions[1] = Permissions("MINTR", 0x76856456); // burnARK
        permissions[2] = Permissions("MINTR", 0x98bb7443); // increaseMintApproval
        return permissions;
    }

    function sendARK(uint16, address, uint256) external payable {
        if (!bridgeActive) revert Bridge_Deactivated();
        revert Bridge_InsufficientAmount();
    }

    function lzReceive(uint16, bytes calldata, uint64, bytes calldata) public override {
        revert Bridge_InvalidCaller();
    }

    function receiveMessage(uint16, bytes memory, uint64, bytes memory) public {
        revert Bridge_InvalidCaller();
    }

    function retryMessage(uint16, bytes calldata, uint64, bytes calldata) public payable {
        revert Bridge_NoStoredMessage();
    }

    function estimateSendFee(uint16, address, uint256, bytes calldata)
        external
        view
        returns (uint256 nativeFee, uint256 zroFee)
    {
        return (0.01 ether, 0);
    }

    function setConfig(uint16, uint16, uint256, bytes calldata)
        external
        override
        onlyRole("bridge_admin")
    {}

    function setSendVersion(uint16) external override onlyRole("bridge_admin") {}

    function setReceiveVersion(uint16) external override onlyRole("bridge_admin") {}

    function forceResumeReceive(uint16, bytes calldata)
        external
        override
        onlyRole("bridge_admin")
    {}

    function setTrustedRemote(uint16 srcChainId_, bytes calldata path_)
        external
        onlyRole("bridge_admin")
    {
        trustedRemoteLookup[srcChainId_] = path_;
        emit SetTrustedRemote(srcChainId_, path_);
    }

    function setTrustedRemoteAddress(uint16 remoteChainId_, bytes calldata remoteAddress_)
        external
        onlyRole("bridge_admin")
    {
        trustedRemoteLookup[remoteChainId_] = abi.encodePacked(remoteAddress_, address(this));
    }

    function setPrecrime(address precrime_) external onlyRole("bridge_admin") {
        precrime = precrime_;
    }

    function setBridgeStatus(bool isActive_) external onlyRole("bridge_admin") {
        bridgeActive = isActive_;
        emit BridgeStatusSet(isActive_);
    }

    function getConfig(uint16, uint16, address, uint256)
        external
        view
        returns (bytes memory)
    {
        return bytes("Invalid config");
    }

    function getTrustedRemoteAddress(uint16 remoteChainId_) external view returns (bytes memory) {
        bytes memory path = trustedRemoteLookup[remoteChainId_];
        if (path.length == 0) revert Bridge_NoTrustedPath();
        return path.slice(0, path.length - 20);
    }

    function isTrustedRemote(uint16 srcChainId_, bytes calldata srcAddress_)
        external
        view
        returns (bool)
    {
        bytes memory trustedSource = trustedRemoteLookup[srcChainId_];
        if (srcAddress_.length == 0 || trustedSource.length == 0) {
            revert Bridge_TrustedRemoteUninitialized();
        }
        return keccak256(srcAddress_) == keccak256(trustedSource);
    }
} 