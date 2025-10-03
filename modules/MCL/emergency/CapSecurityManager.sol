// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ICapSecurityManager {
    event AuthorizationRequired(address indexed caller, bytes4 indexed functionSelector);
    event AuthorizedSignerAdded(address indexed signer);
    event AuthorizedSignerRemoved(address indexed signer);

    error UnauthorizedSigner();
    error SignerAlreadyAuthorized();
    error SignerNotAuthorized();

    function requireMultiSig() external view returns (bool);
    function addAuthorizedSigner(address _signer) external;
    function removeAuthorizedSigner(address _signer) external;
    function isAuthorizedSigner(address _signer) external view returns (bool);
}

contract CapSecurityManager is ICapSecurityManager, Ownable {
    mapping(address => bool) private s_authorizedSigners;
    uint256 private s_requiredSignatures;

    constructor(address initialOwner, uint256 requiredSignatures) Ownable(initialOwner) {
        s_requiredSignatures = requiredSignatures;
    }

    function requireMultiSig() external view returns (bool) {
        return s_requiredSignatures > 1;
    }

    function addAuthorizedSigner(address _signer) external onlyOwner {
        require(_signer != address(0), "Invalid signer address");
        if (s_authorizedSigners[_signer]) {
            revert SignerAlreadyAuthorized();
        }
        s_authorizedSigners[_signer] = true;
        emit AuthorizedSignerAdded(_signer);
    }

    function removeAuthorizedSigner(address _signer) external onlyOwner {
        if (!s_authorizedSigners[_signer]) {
            revert SignerNotAuthorized();
        }
        s_authorizedSigners[_signer] = false;
        emit AuthorizedSignerRemoved(_signer);
    }

    function isAuthorizedSigner(address _signer) external view returns (bool) {
        return s_authorizedSigners[_signer];
    }
}