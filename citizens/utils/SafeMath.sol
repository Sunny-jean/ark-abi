// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) external pure returns (uint256);

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) external pure returns (uint256);

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) external pure returns (uint256);

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) external pure returns (uint256);

    /**
     * @dev Returns the remainder of division of two unsigned integers, reverting
     * on division by zero. (unsigned integer modulo), 
     *
     * Counterpart to Solidity's `%` operator.
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) external pure returns (uint256);
}