// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMultisigKeyManager {
    event KeyAdded(address indexed key, uint256 indexed threshold);
    event KeyRemoved(address indexed key, uint256 indexed threshold);
    event ThresholdChanged(uint256 oldThreshold, uint256 newThreshold);

    error UnauthorizedAccess(address caller);
    error InvalidKey(address key);
    error InvalidThreshold(uint256 threshold);

    function addKey(address _key) external;
    function removeKey(address _key) external;
    function changeThreshold(uint256 _newThreshold) external;
    function isKey(address _key) external view returns (bool);
    function getThreshold() external view returns (uint256);
    function getKeys() external view returns (address[] memory);
}