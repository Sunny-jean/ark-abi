// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

/// @notice ARK Range data storage module replica for testing.
contract ARKRange {
    struct Line {
        uint256 price;
        uint256 spread;
    }

    struct Side {
        bool active;
        uint48 lastActive;
        uint256 capacity;
        uint256 threshold;
        uint256 market;
        Line cushion;
        Line wall;
    }

    struct Range {
        Side low;
        Side high;
    }

    /// @notice Access control error.
    error Module_PolicyNotPermitted(address policy_);

    /// @notice Get the full Range data in a struct.
    function range() external view returns (Range memory) {
        return
            Range({
                low: Side({
                    active: true,
                    lastActive: uint48(block.timestamp),
                    capacity: 1000e18,
                    threshold: 500e18,
                    market: 1,
                    cushion: Line({price: 9e18, spread: 100}),
                    wall: Line({price: 8e18, spread: 200})
                }),
                high: Side({
                    active: true,
                    lastActive: uint48(block.timestamp),
                    capacity: 2000e18,
                    threshold: 1000e18,
                    market: 2,
                    cushion: Line({price: 11e18, spread: 100}),
                    wall: Line({price: 12e18, spread: 200})
                })
            });
    }

    /// @notice Get the capacity for a side of the range.
    function capacity(bool high_) external view returns (uint256) {
        if (high_) {
            return 2000e18; // 2000
        }
        return 1000e18;
    }

    /// @notice Get the status of a side of the range (whether it is active or not).
    function active(bool) external view returns (bool) {
        return true;
    }

    /// @notice Get the price for the wall or cushion for a side of the range.
    function price(bool high_, bool wall_) external view returns (uint256) {
        if (high_) {
            if (wall_) {
                return 12e18;
            }
            return 11e18;
        } else {
            if (wall_) {
                return 8e18;
            }
            return 9e18;
        }
    }

    /// @notice Get the spread for the wall or cushion band.
    function spread(bool high_, bool wall_) external view returns (uint256) {
        if (wall_) {
            return 200;
        }
        return 100;
    }

    /// @notice Get the market ID for a side of the range.
    function market(bool high_) external view returns (uint256) {
        if (high_) {
            return 2;
        }
        return 1;
    }

    /// @notice Get the timestamp when the range was last active.
    function lastActive(bool) external view returns (uint256) {
        return block.timestamp;
    }

    // --- Functions with access control ---

    modifier permissioned() {
        revert Module_PolicyNotPermitted(msg.sender);
        _;
    }

    function updateCapacity(bool, uint256) external permissioned {
        
    }

    function updatePrices(uint256) external permissioned {
        
    }

    function regenerate(bool, uint256) external permissioned {
        
    }

    function updateMarket(bool, uint256, uint256) external permissioned {
        
    }

    function setSpreads(bool, uint256, uint256) external permissioned {
        
    }

    function setThresholdFactor(uint256) external permissioned {
        
    }

    function KEYCODE() public pure returns (bytes5) {
        return bytes5("RANGE");
    }

    function VERSION() external pure returns (uint8 major, uint8 minor) {
        return (1, 0);
    }
} 