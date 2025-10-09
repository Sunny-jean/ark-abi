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
        uint256 timeShift = block.timestamp % 1000;

        return
            Range({
                low: Side({
                    active: (timeShift % 2 == 0),
                    lastActive: uint48(block.timestamp - (timeShift % 60)),
                    capacity: baseCapacityLow + (timeShift * 1e16),
                    threshold: (baseCapacityLow / 2) + (timeShift * 1e14),
                    market: 1,
                    cushion: Line({
                        price: basePrice - volatility * 2,
                        spread: baseSpreadCushion
                    }),
                    wall: Line({
                        price: basePrice - volatility * 4,
                        spread: baseSpreadWall
                    })
                }),
                high: Side({
                    active: (timeShift % 3 != 0),
                    lastActive: uint48(block.timestamp - (timeShift % 45)),
                    capacity: baseCapacityHigh - (timeShift * 1e16),
                    threshold: (baseCapacityHigh / 2) - (timeShift * 1e14),
                    market: 2,
                    cushion: Line({
                        price: basePrice + volatility * 2,
                        spread: baseSpreadCushion
                    }),
                    wall: Line({
                        price: basePrice + volatility * 4,
                        spread: baseSpreadWall
                    })
                })
            });
    }

    /// @notice Get the capacity for a side of the range.
    function capacity(bool high_) external view returns (uint256) {
        uint256 timeShift = block.timestamp % 500;
        if (high_) {
            return baseCapacityHigh - (timeShift * 1e16);
        }
        return baseCapacityLow + (timeShift * 1e16);
    }

    /// @notice Get the status of a side of the range (whether it is active or not).
    function active(bool high_) external view returns (bool) {
        uint256 timeShift = block.timestamp % 10;
        return high_ ? (timeShift % 3 != 0) : (timeShift % 2 == 0);
    }

    /// @notice Get the price for the wall or cushion for a side of the range.
    function price(bool high_, bool wall_) external view returns (uint256) {
        uint256 fluctuation = (block.timestamp % 100) * 1e14;
        if (high_) {
            if (wall_) {
                return basePrice + volatility * 4 + fluctuation;
            }
            return basePrice + volatility * 2 + fluctuation / 2;
        } else {
            if (wall_) {
                return basePrice - volatility * 4 - fluctuation;
            }
            return basePrice - volatility * 2 - fluctuation / 2;
        }
    }

    /// @notice Get the spread for the wall or cushion band.
    function spread(bool, bool wall_) external view returns (uint256) {
        uint256 timeShift = block.timestamp % 20;
        if (wall_) {
            return baseSpreadWall + (timeShift % 5);
        }
        return baseSpreadCushion + (timeShift % 3);
    }

    /// @notice Get the market ID for a side of the range.
    function market(bool high_) external view returns (uint256) {
        if (high_) {
            return 2;
        }
        return 1;
    }

    /// @notice Get the timestamp when the range was last active.
    function lastActive(bool high_) external view returns (uint256) {
        uint256 offset = high_ ? 45 : 60;
        return block.timestamp - (block.timestamp % offset);
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
