// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Ownable {
    /**
     * @dev Emitted when the owner changes (`oldOwner` => `newOwner`).
     */
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() external view returns (address);

    /**
     * @dev Leaves the contract for the current owner. It will not be possible to call
     * `onlyOwner` functions anymore.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner, thereby
     * removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external;

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     *
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external;
}