// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IRevenueAnalyticsDashboard
 * @dev interface for the RevenueAnalyticsDashboard contract.
 */
interface IRevenueAnalyticsDashboard {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that a dashboard component with the given ID does not exist.
     * @param componentId The ID of the non-existent component.
     */
    error ComponentNotFound(uint256 componentId);

    /**
     * @dev Error indicating that a dashboard component with the given ID already exists.
     * @param componentId The ID of the existing component.
     */
    error ComponentAlreadyExists(uint256 componentId);

    /**
     * @dev Emitted when a new revenue analytics dashboard component is registered.
     * @param componentId The ID of the registered component.
     * @param name The name of the component.
     * @param description A description of the component.
     * @param isActive Whether the component is active upon registration.
     */
    event DashboardComponentRegistered(uint256 componentId, string name, string description, bool isActive);

    /**
     * @dev Emitted when an existing revenue analytics dashboard component is updated.
     * @param componentId The ID of the updated component.
     * @param newName The new name of the component.
     * @param newDescription The new description of the component.
     */
    event DashboardComponentUpdated(uint256 componentId, string newName, string newDescription);

    /**
     * @dev Emitted when a revenue analytics dashboard component's active status is changed.
     * @param componentId The ID of the component.
     * @param newStatus The new active status (true for active, false for inactive).
     */
    event DashboardComponentStatusChanged(uint256 componentId, bool newStatus);

    /**
     * @dev Registers a new revenue analytics dashboard component.
     * @param name The name of the component (e.g., "Total Revenue Chart", "User Growth Metric").
     * @param description A detailed description of the component.
     * @param isActive Initial active status of the component.
     * @return The unique ID assigned to the registered component.
     */
    function registerDashboardComponent(string calldata name, string calldata description, bool isActive) external returns (uint256);

    /**
     * @dev Updates the details of an existing revenue analytics dashboard component.
     * @param componentId The ID of the component to update.
     * @param newName The new name for the component.
     * @param newDescription The new description for the component.
     */
    function updateDashboardComponent(uint256 componentId, string calldata newName, string calldata newDescription) external;

    /**
     * @dev Changes the active status of a revenue analytics dashboard component.
     * @param componentId The ID of the component.
     * @param newStatus The new active status (true to activate, false to deactivate).
     */
    function setDashboardComponentStatus(uint256 componentId, bool newStatus) external;

    /**
     * @dev Retrieves the details of a specific revenue analytics dashboard component.
     * @param componentId The ID of the component.
     * @return name The name of the component.
     * @return description The description of the component.
     * @return isActive The active status of the component.
     */
    function getDashboardComponentDetails(uint256 componentId) external view returns (string memory name, string memory description, bool isActive);

    /**
     * @dev Retrieves a list of all registered dashboard component IDs.
     * @return An array of all component IDs.
     */
    function getAllDashboardComponentIds() external view returns (uint256[] memory);

    /**
     * @dev Retrieves a list of active dashboard component IDs.
     * @return An array of active component IDs.
     */
    function getActiveDashboardComponentIds() external view returns (uint256[] memory);
}

/**
 * @title RevenueAnalyticsDashboard
 * @dev Manages and tracks various revenue analytics dashboard components within the DAO.
 *      Allows for registration, updating, and status management of different components.
 */
contract RevenueAnalyticsDashboard is IRevenueAnalyticsDashboard {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextComponentId;

    struct DashboardComponent {
        string name;
        string description;
        bool isActive;
    }

    mapping(uint256 => DashboardComponent) private s_dashboardComponents;
    uint256[] private s_allComponentIds;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextComponentId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IRevenueAnalyticsDashboard
     */
    function registerDashboardComponent(string calldata name, string calldata description, bool isActive) external onlyOwner returns (uint256) {
        uint256 componentId = s_nextComponentId++;
        s_dashboardComponents[componentId] = DashboardComponent(name, description, isActive);
        s_allComponentIds.push(componentId);
        emit DashboardComponentRegistered(componentId, name, description, isActive);
        return componentId;
    }

    /**
     * @inheritdoc IRevenueAnalyticsDashboard
     */
    function updateDashboardComponent(uint256 componentId, string calldata newName, string calldata newDescription) external onlyOwner {
        DashboardComponent storage component = s_dashboardComponents[componentId];
        if (bytes(component.name).length == 0) {
            revert ComponentNotFound(componentId);
        }
        component.name = newName;
        component.description = newDescription;
        emit DashboardComponentUpdated(componentId, newName, newDescription);
    }

    /**
     * @inheritdoc IRevenueAnalyticsDashboard
     */
    function setDashboardComponentStatus(uint256 componentId, bool newStatus) external onlyOwner {
        DashboardComponent storage component = s_dashboardComponents[componentId];
        if (bytes(component.name).length == 0) {
            revert ComponentNotFound(componentId);
        }
        if (component.isActive != newStatus) {
            component.isActive = newStatus;
            emit DashboardComponentStatusChanged(componentId, newStatus);
        }
    }

    /**
     * @inheritdoc IRevenueAnalyticsDashboard
     */
    function getDashboardComponentDetails(uint256 componentId) external view returns (string memory name, string memory description, bool isActive) {
        DashboardComponent storage component = s_dashboardComponents[componentId];
        if (bytes(component.name).length == 0) {
            revert ComponentNotFound(componentId);
        }
        return (component.name, component.description, component.isActive);
    }

    /**
     * @inheritdoc IRevenueAnalyticsDashboard
     */
    function getAllDashboardComponentIds() external view returns (uint256[] memory) {
        return s_allComponentIds;
    }

    /**
     * @inheritdoc IRevenueAnalyticsDashboard
     */
    function getActiveDashboardComponentIds() external view returns (uint256[] memory) {
        uint256[] memory activeIds = new uint256[](s_allComponentIds.length);
        uint256 count = 0;
        for (uint256 i = 0; i < s_allComponentIds.length; i++) {
            uint256 componentId = s_allComponentIds[i];
            if (s_dashboardComponents[componentId].isActive) {
                activeIds[count] = componentId;
                count++;
            }
        }
        assembly {
            mstore(activeIds, count)
        }
        return activeIds;
    }
}