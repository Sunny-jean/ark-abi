// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IRevenueTargetSetter
 * @dev interface for the RevenueTargetSetter contract.
 */
interface IRevenueTargetSetter {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that a target for the given ID does not exist.
     * @param targetId The ID of the non-existent target.
     */
    error TargetNotFound(uint256 targetId);

    /**
     * @dev Error indicating that a target with the given ID already exists.
     * @param targetId The ID of the existing target.
     */
    error TargetAlreadyExists(uint256 targetId);

    /**
     * @dev Emitted when a new revenue target is set.
     * @param targetId The ID of the target.
     * @param name The name of the target.
     * @param description A description of the target.
     * @param value The target value.
     * @param period The period for which the target is set (e.g., monthly, quarterly).
     */
    event RevenueTargetSet(uint256 targetId, string name, string description, uint256 value, string period);

    /**
     * @dev Emitted when an existing revenue target is updated.
     * @param targetId The ID of the updated target.
     * @param newValue The new target value.
     */
    event RevenueTargetUpdated(uint256 targetId, uint256 newValue);

    /**
     * @dev Sets a new revenue target.
     * @param name The name of the target (e.g., "Q3 Revenue Goal", "Monthly Growth Target").
     * @param description A detailed description of the target.
     * @param value The target value (e.g., in USD, ETH, or a specific token amount).
     * @param period The period for which the target is set (e.g., "monthly", "quarterly", "annual").
     * @return The unique ID assigned to the new target.
     */
    function setRevenueTarget(string calldata name, string calldata description, uint256 value, string calldata period) external returns (uint256);

    /**
     * @dev Updates the value of an existing revenue target.
     * @param targetId The ID of the target to update.
     * @param newValue The new target value.
     */
    function updateRevenueTarget(uint256 targetId, uint256 newValue) external;

    /**
     * @dev Retrieves the details of a specific revenue target.
     * @param targetId The ID of the target.
     * @return name The name of the target.
     * @return description The description of the target.
     * @return value The target value.
     * @return period The period for which the target is set.
     */
    function getRevenueTargetDetails(uint256 targetId) external view returns (string memory name, string memory description, uint256 value, string memory period);

    /**
     * @dev Retrieves a list of all set revenue target IDs.
     * @return An array of all target IDs.
     */
    function getAllTargetIds() external view returns (uint256[] memory);
}

/**
 * @title RevenueTargetSetter
 * @dev Contract for setting and managing revenue targets for the DAO.
 *      Allows for defining specific revenue goals for different periods and tracking their values.
 */
contract RevenueTargetSetter is IRevenueTargetSetter {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextTargetId;

    struct RevenueTarget {
        string name;
        string description;
        uint256 value;
        string period;
    }

    mapping(uint256 => RevenueTarget) private s_revenueTargets;
    uint256[] private s_allTargetIds;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextTargetId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IRevenueTargetSetter
     */
    function setRevenueTarget(string calldata name, string calldata description, uint256 value, string calldata period) external onlyOwner returns (uint256) {
        uint256 targetId = s_nextTargetId++;
        s_revenueTargets[targetId] = RevenueTarget(name, description, value, period);
        s_allTargetIds.push(targetId);
        emit RevenueTargetSet(targetId, name, description, value, period);
        return targetId;
    }

    /**
     * @inheritdoc IRevenueTargetSetter
     */
    function updateRevenueTarget(uint256 targetId, uint256 newValue) external onlyOwner {
        RevenueTarget storage target = s_revenueTargets[targetId];
        if (bytes(target.name).length == 0) {
            revert TargetNotFound(targetId);
        }
        target.value = newValue;
        emit RevenueTargetUpdated(targetId, newValue);
    }

    /**
     * @inheritdoc IRevenueTargetSetter
     */
    function getRevenueTargetDetails(uint256 targetId) external view returns (string memory name, string memory description, uint256 value, string memory period) {
        RevenueTarget storage target = s_revenueTargets[targetId];
        if (bytes(target.name).length == 0) {
            revert TargetNotFound(targetId);
        }
        return (target.name, target.description, target.value, target.period);
    }

    /**
     * @inheritdoc IRevenueTargetSetter
     */
    function getAllTargetIds() external view returns (uint256[] memory) {
        return s_allTargetIds;
    }
}