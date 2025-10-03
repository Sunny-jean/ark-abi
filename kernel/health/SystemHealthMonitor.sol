// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title System Health Monitor
/// @notice Monitors the health of the system and reports issues
interface ISystemHealthMonitor {
    function getSystemHealth() external view returns (uint256 healthScore, bool isHealthy);
    function getComponentHealth(bytes32 componentId) external view returns (uint256 healthScore, bool isHealthy);
    function getActiveAlerts() external view returns (bytes32[] memory);
    function getLastHealthCheck() external view returns (uint256 timestamp, bool passed);
}

contract SystemHealthMonitor is ISystemHealthMonitor {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ComponentRegistered(bytes32 indexed componentId, string name, address indexed componentAddress);
    event ComponentRemoved(bytes32 indexed componentId);
    event HealthCheckPerformed(uint256 indexed timestamp, bool passed, uint256 systemHealthScore);
    event ComponentHealthUpdated(bytes32 indexed componentId, uint256 oldScore, uint256 newScore, bool isHealthy);
    event AlertTriggered(bytes32 indexed alertId, bytes32 indexed componentId, uint256 severity, string message);
    event AlertResolved(bytes32 indexed alertId);
    event HealthThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
    event MonitorAdminChanged(address indexed oldAdmin, address indexed newAdmin);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error SystemHealthMonitor_OnlyAdmin(address caller);
    error SystemHealthMonitor_OnlyAuthorizedMonitor(address caller);
    error SystemHealthMonitor_ComponentNotRegistered(bytes32 componentId);
    error SystemHealthMonitor_ComponentAlreadyRegistered(bytes32 componentId);
    error SystemHealthMonitor_InvalidAddress(address addr);
    error SystemHealthMonitor_InvalidHealthScore(uint256 score);
    error SystemHealthMonitor_InvalidSeverity(uint256 severity);
    error SystemHealthMonitor_AlertNotActive(bytes32 alertId);
    error SystemHealthMonitor_SystemPaused();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct ComponentData {
        bytes32 id;
        string name;
        address componentAddress;
        uint256 healthScore; // 0-100, where 100 is perfectly healthy
        bool isActive;
        uint256 lastChecked;
        bytes32[] activeAlerts;
    }

    struct AlertData {
        bytes32 id;
        bytes32 componentId;
        uint256 severity; // 1-5, where 5 is most severe
        string message;
        uint256 timestamp;
        bool isActive;
    }

    struct HealthCheckResult {
        uint256 timestamp;
        bool passed;
        uint256 systemHealthScore;
        bytes32[] failedComponents;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address[] public authorizedMonitors;
    mapping(address => bool) public isAuthorizedMonitor;
    
    // Components
    mapping(bytes32 => ComponentData) public components;
    bytes32[] public registeredComponents;
    
    // Alerts
    mapping(bytes32 => AlertData) public alerts;
    bytes32[] public activeAlerts;
    
    // Health checks
    HealthCheckResult[] public healthCheckHistory;
    uint256 public healthThreshold = 70; // System is healthy if score >= threshold
    
    // System state
    bool public systemPaused;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert SystemHealthMonitor_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyAuthorizedMonitor() {
        if (!isAuthorizedMonitor[msg.sender] && msg.sender != admin) {
            revert SystemHealthMonitor_OnlyAuthorizedMonitor(msg.sender);
        }
        _;
    }

    modifier whenNotPaused() {
        if (systemPaused) revert SystemHealthMonitor_SystemPaused();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address[] memory initialMonitors_) {
        if (admin_ == address(0)) revert SystemHealthMonitor_InvalidAddress(admin_);
        
        admin = admin_;
        isAuthorizedMonitor[admin_] = true;
        authorizedMonitors.push(admin_);
        
        // Add initial monitors
        for (uint256 i = 0; i < initialMonitors_.length; i++) {
            address monitor = initialMonitors_[i];
            if (monitor != address(0) && monitor != admin_ && !isAuthorizedMonitor[monitor]) {
                isAuthorizedMonitor[monitor] = true;
                authorizedMonitors.push(monitor);
            }
        }
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Register a component to be monitored
    /// @param componentId The component ID
    /// @param name The component name
    /// @param componentAddress The component address
    function registerComponent(
        bytes32 componentId,
        string calldata name,
        address componentAddress
    ) external onlyAdmin {
        if (componentAddress == address(0)) revert SystemHealthMonitor_InvalidAddress(componentAddress);
        if (components[componentId].isActive) revert SystemHealthMonitor_ComponentAlreadyRegistered(componentId);
        
        components[componentId] = ComponentData({
            id: componentId,
            name: name,
            componentAddress: componentAddress,
            healthScore: 100, // Start with perfect health
            isActive: true,
            lastChecked: block.timestamp,
            activeAlerts: new bytes32[](0)
        });
        
        registeredComponents.push(componentId);
        
        emit ComponentRegistered(componentId, name, componentAddress);
    }

    /// @notice Remove a component from monitoring
    /// @param componentId The component ID
    function removeComponent(bytes32 componentId) external onlyAdmin {
        if (!components[componentId].isActive) revert SystemHealthMonitor_ComponentNotRegistered(componentId);
        
        // Resolve any active alerts for this component
        bytes32[] storage componentAlerts = components[componentId].activeAlerts;
        for (uint256 i = 0; i < componentAlerts.length; i++) {
            bytes32 alertId = componentAlerts[i];
            if (alerts[alertId].isActive) {
                _resolveAlert(alertId);
            }
        }
        
        // Deactivate component
        components[componentId].isActive = false;
        
        // Remove from array
        for (uint256 i = 0; i < registeredComponents.length; i++) {
            if (registeredComponents[i] == componentId) {
                registeredComponents[i] = registeredComponents[registeredComponents.length - 1];
                registeredComponents.pop();
                break;
            }
        }
        
        emit ComponentRemoved(componentId);
    }

    /// @notice Update the health score of a component
    /// @param componentId The component ID
    /// @param healthScore The new health score (0-100)
    function updateComponentHealth(
        bytes32 componentId,
        uint256 healthScore
    ) external onlyAuthorizedMonitor {
        if (!components[componentId].isActive) revert SystemHealthMonitor_ComponentNotRegistered(componentId);
        if (healthScore > 100) revert SystemHealthMonitor_InvalidHealthScore(healthScore);
        
        ComponentData storage component = components[componentId];
        uint256 oldScore = component.healthScore;
        component.healthScore = healthScore;
        component.lastChecked = block.timestamp;
        
        bool isHealthy = healthScore >= healthThreshold;
        
        emit ComponentHealthUpdated(componentId, oldScore, healthScore, isHealthy);
    }

    /// @notice Perform a health check on all components
    /// @return passed Whether the system passed the health check
    function performHealthCheck() external onlyAuthorizedMonitor returns (bool passed) {
        uint256 totalScore = 0;
        uint256 componentCount = 0;
        bytes32[] memory failedComponents = new bytes32[](registeredComponents.length);
        uint256 failedCount = 0;
        
        // Check each component
        for (uint256 i = 0; i < registeredComponents.length; i++) {
            bytes32 componentId = registeredComponents[i];
            ComponentData storage component = components[componentId];
            
            if (component.isActive) {
                componentCount++;
                totalScore += component.healthScore;
                
                // Record failed components
                if (component.healthScore < healthThreshold) {
                    failedComponents[failedCount++] = componentId;
                }
            }
        }
        
        // Calculate system health score
        uint256 systemHealthScore = componentCount > 0 ? totalScore / componentCount : 0;
        passed = systemHealthScore >= healthThreshold;
        
        // Resize failedComponents array
        assembly {
            mstore(failedComponents, failedCount)
        }
        
        // Record health check
        healthCheckHistory.push(HealthCheckResult({
            timestamp: block.timestamp,
            passed: passed,
            systemHealthScore: systemHealthScore,
            failedComponents: failedComponents
        }));
        
        emit HealthCheckPerformed(block.timestamp, passed, systemHealthScore);
        
        return passed;
    }

    /// @notice Trigger an alert for a component
    /// @param componentId The component ID
    /// @param severity The alert severity (1-5)
    /// @param message The alert message
    /// @return alertId The ID of the created alert
    function triggerAlert(
        bytes32 componentId,
        uint256 severity,
        string calldata message
    ) external onlyAuthorizedMonitor returns (bytes32 alertId) {
        if (!components[componentId].isActive) revert SystemHealthMonitor_ComponentNotRegistered(componentId);
        if (severity == 0 || severity > 5) revert SystemHealthMonitor_InvalidSeverity(severity);
        
        // Generate alert ID
        alertId = keccak256(abi.encodePacked(componentId, block.timestamp, msg.sender));
        
        // Create alert
        alerts[alertId] = AlertData({
            id: alertId,
            componentId: componentId,
            severity: severity,
            message: message,
            timestamp: block.timestamp,
            isActive: true
        });
        
        // Add to active alerts
        activeAlerts.push(alertId);
        
        // Add to component's active alerts
        components[componentId].activeAlerts.push(alertId);
        
        // Update component health based on severity
        uint256 healthImpact = severity * 20; // Severity 1-5 maps to 20-100 impact
        uint256 currentHealth = components[componentId].healthScore;
        uint256 newHealth = currentHealth > healthImpact ? currentHealth - healthImpact : 0;
        
        components[componentId].healthScore = newHealth;
        
        emit AlertTriggered(alertId, componentId, severity, message);
        emit ComponentHealthUpdated(componentId, currentHealth, newHealth, newHealth >= healthThreshold);
        
        return alertId;
    }

    /// @notice Resolve an alert
    /// @param alertId The alert ID
    function resolveAlert(bytes32 alertId) external onlyAuthorizedMonitor {
        _resolveAlert(alertId);
    }

    /// @notice Add an authorized monitor
    /// @param monitor The monitor address
    function addAuthorizedMonitor(address monitor) external onlyAdmin {
        if (monitor == address(0)) revert SystemHealthMonitor_InvalidAddress(monitor);
        if (isAuthorizedMonitor[monitor]) return; // Already authorized
        
        isAuthorizedMonitor[monitor] = true;
        authorizedMonitors.push(monitor);
    }

    /// @notice Remove an authorized monitor
    /// @param monitor The monitor address
    function removeAuthorizedMonitor(address monitor) external onlyAdmin {
        if (monitor == admin) return; // Can't remove admin
        if (!isAuthorizedMonitor[monitor]) return; // Not authorized
        
        isAuthorizedMonitor[monitor] = false;
        
        // Remove from array
        for (uint256 i = 0; i < authorizedMonitors.length; i++) {
            if (authorizedMonitors[i] == monitor) {
                authorizedMonitors[i] = authorizedMonitors[authorizedMonitors.length - 1];
                authorizedMonitors.pop();
                break;
            }
        }
    }

    /// @notice Set the health threshold
    /// @param newThreshold The new threshold (0-100)
    function setHealthThreshold(uint256 newThreshold) external onlyAdmin {
        if (newThreshold > 100) revert SystemHealthMonitor_InvalidHealthScore(newThreshold);
        
        uint256 oldThreshold = healthThreshold;
        healthThreshold = newThreshold;
        
        emit HealthThresholdUpdated(oldThreshold, newThreshold);
    }

    /// @notice Change the admin
    /// @param newAdmin The new admin address
    function changeAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert SystemHealthMonitor_InvalidAddress(newAdmin);
        
        address oldAdmin = admin;
        admin = newAdmin;
        
        // Add new admin as authorized monitor if not already
        if (!isAuthorizedMonitor[newAdmin]) {
            isAuthorizedMonitor[newAdmin] = true;
            authorizedMonitors.push(newAdmin);
        }
        
        emit MonitorAdminChanged(oldAdmin, newAdmin);
    }

    /// @notice Pause the system
    function pauseSystem() external onlyAdmin {
        systemPaused = true;
    }

    /// @notice Unpause the system
    function unpauseSystem() external onlyAdmin {
        systemPaused = false;
    }

    /// @notice Get the system health
    /// @return healthScore The system health score (0-100)
    /// @return isHealthy Whether the system is healthy
    function getSystemHealth() external view override returns (uint256 healthScore, bool isHealthy) {
        if (healthCheckHistory.length == 0) {
            return (0, false);
        }
        
        HealthCheckResult memory lastCheck = healthCheckHistory[healthCheckHistory.length - 1];
        return (lastCheck.systemHealthScore, lastCheck.passed);
    }

    /// @notice Get the health of a component
    /// @param componentId The component ID
    /// @return healthScore The component health score (0-100)
    /// @return isHealthy Whether the component is healthy
    function getComponentHealth(bytes32 componentId) external view override returns (uint256 healthScore, bool isHealthy) {
        if (!components[componentId].isActive) revert SystemHealthMonitor_ComponentNotRegistered(componentId);
        
        ComponentData storage component = components[componentId];
        return (component.healthScore, component.healthScore >= healthThreshold);
    }

    /// @notice Get all active alerts
    /// @return Array of alert IDs
    function getActiveAlerts() external view override returns (bytes32[] memory) {
        return activeAlerts;
    }

    /// @notice Get the last health check
    /// @return timestamp The timestamp of the last health check
    /// @return passed Whether the last health check passed
    function getLastHealthCheck() external view override returns (uint256 timestamp, bool passed) {
        if (healthCheckHistory.length == 0) {
            return (0, false);
        }
        
        HealthCheckResult memory lastCheck = healthCheckHistory[healthCheckHistory.length - 1];
        return (lastCheck.timestamp, lastCheck.passed);
    }

    /// @notice Get alert details
    /// @param alertId The alert ID
    /// @return id The alert ID
    /// @return componentId The component ID
    /// @return severity The alert severity
    /// @return message The alert message
    /// @return timestamp The alert timestamp
    /// @return isActive Whether the alert is active
    function getAlertDetails(bytes32 alertId) external view returns (
        bytes32 id,
        bytes32 componentId,
        uint256 severity,
        string memory message,
        uint256 timestamp,
        bool isActive
    ) {
        AlertData storage alert = alerts[alertId];
        return (
            alert.id,
            alert.componentId,
            alert.severity,
            alert.message,
            alert.timestamp,
            alert.isActive
        );
    }

    /// @notice Get component details
    /// @param componentId The component ID
    /// @return id The component ID
    /// @return name The component name
    /// @return componentAddress The component address
    /// @return healthScore The component health score
    /// @return isActive Whether the component is active
    /// @return lastChecked When the component was last checked
    /// @return activeAlerts The component's active alerts
    function getComponentDetails(bytes32 componentId) external view returns (
        bytes32 id,
        string memory name,
        address componentAddress,
        uint256 healthScore,
        bool isActive,
        uint256 lastChecked,
        bytes32[] memory activeAlerts
    ) {
        ComponentData storage component = components[componentId];
        return (
            component.id,
            component.name,
            component.componentAddress,
            component.healthScore,
            component.isActive,
            component.lastChecked,
            component.activeAlerts
        );
    }

    /// @notice Get all registered components
    /// @return Array of component IDs
    function getRegisteredComponents() external view returns (bytes32[] memory) {
        return registeredComponents;
    }

    /// @notice Get all authorized monitors
    /// @return Array of monitor addresses
    function getAuthorizedMonitors() external view returns (address[] memory) {
        return authorizedMonitors;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Internal function to resolve an alert
    /// @param alertId The alert ID
    function _resolveAlert(bytes32 alertId) internal {
        AlertData storage alert = alerts[alertId];
        if (!alert.isActive) revert SystemHealthMonitor_AlertNotActive(alertId);
        
        // Mark alert as resolved
        alert.isActive = false;
        
        // Remove from active alerts
        for (uint256 i = 0; i < activeAlerts.length; i++) {
            if (activeAlerts[i] == alertId) {
                activeAlerts[i] = activeAlerts[activeAlerts.length - 1];
                activeAlerts.pop();
                break;
            }
        }
        
        // Remove from component's active alerts
        bytes32 componentId = alert.componentId;
        bytes32[] storage componentAlerts = components[componentId].activeAlerts;
        
        for (uint256 i = 0; i < componentAlerts.length; i++) {
            if (componentAlerts[i] == alertId) {
                componentAlerts[i] = componentAlerts[componentAlerts.length - 1];
                componentAlerts.pop();
                break;
            }
        }
        
        emit AlertResolved(alertId);
    }
}