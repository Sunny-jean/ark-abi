// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TrainingSessionManager {
    /**
     * @dev Emitted when a new training session is created.
     * @param sessionId The unique ID of the session.
     * @param courseId The ID of the associated course.
     * @param instructor The address of the instructor.
     */
    event TrainingSessionCreated(bytes32 indexed sessionId, bytes32 indexed courseId, address indexed instructor);

    /**
     * @dev Emitted when a user enrolls in a training session.
     * @param sessionId The unique ID of the session.
     * @param user The address of the enrolled user.
     */
    event UserEnrolled(bytes32 indexed sessionId, address indexed user);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a required parameter is missing or invalid.
     */
    error InvalidParameter(string parameterName, string description);

    /**
     * @dev Thrown when the specified session is not found.
     */
    error SessionNotFound(bytes32 sessionId);

    /**
     * @dev Thrown when a user is already enrolled or cannot enroll.
     */
    error EnrollmentFailed(address user, bytes32 sessionId, string reason);

    /**
     * @dev Creates a new training session.
     * @param courseId The unique ID of the course this session belongs to.
     * @param instructor The address of the instructor for this session.
     * @param startTime The start timestamp of the session.
     * @param endTime The end timestamp of the session.
     * @param maxAttendees The maximum number of attendees allowed.
     * @return sessionId The unique ID generated for the new session.
     */
    function createTrainingSession(bytes32 courseId, address instructor, uint256 startTime, uint256 endTime, uint256 maxAttendees) external returns (bytes32 sessionId);

    /**
     * @dev Allows a user to enroll in an existing training session.
     * @param sessionId The unique ID of the session to enroll in.
     */
    function enrollInSession(bytes32 sessionId) external;

    /**
     * @dev Retrieves details about a specific training session.
     * @param sessionId The unique ID of the session.
     * @return courseId The ID of the associated course.
     * @return instructor The address of the instructor.
     * @return startTime The start timestamp.
     * @return endTime The end timestamp.
     * @return currentAttendees The current number of attendees.
     * @return maxAttendees The maximum number of attendees.
     */
    function getSessionDetails(bytes32 sessionId) external view returns (bytes32 courseId, address instructor, uint256 startTime, uint256 endTime, uint256 currentAttendees, uint256 maxAttendees);

    /**
     * @dev Checks if a user is enrolled in a specific session.
     * @param sessionId The unique ID of the session.
     * @param user The address of the user.
     * @return isEnrolled True if the user is enrolled, false otherwise.
     */
    function isUserEnrolled(bytes32 sessionId, address user) external view returns (bool isEnrolled);
}