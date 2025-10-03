// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface CommunityModeration {
    /**
     * @dev Emitted when a user is reported.
     * @param reporter The address of the reporter.
     * @param reportedUser The address of the user being reported.
     * @param reason The reason for the report.
     */
    event UserReported(address indexed reporter, address indexed reportedUser, string reason);

    /**
     * @dev Emitted when a user is warned.
     * @param warnedUser The address of the warned user.
     * @param moderator The address of the moderator who issued the warning.
     * @param reason The reason for the warning.
     */
    event UserWarned(address indexed warnedUser, address indexed moderator, string reason);

    /**
     * @dev Emitted when a user is suspended.
     * @param suspendedUser The address of the suspended user.
     * @param moderator The address of the moderator who issued the suspension.
     * @param duration The duration of the suspension in seconds.
     * @param reason The reason for the suspension.
     */
    event UserSuspended(address indexed suspendedUser, address indexed moderator, uint256 duration, string reason);

    /**
     * @dev Emitted when a user's suspension is lifted.
     * @param user The address of the user whose suspension was lifted.
     * @param moderator The address of the moderator who lifted the suspension.
     */
    event UserSuspensionLifted(address indexed user, address indexed moderator);

    /**
     * @dev Emitted when a user is banned.
     * @param bannedUser The address of the banned user.
     * @param moderator The address of the moderator who issued the ban.
     * @param reason The reason for the ban.
     */
    event UserBanned(address indexed bannedUser, address indexed moderator, string reason);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a user attempts to report themselves.
     */
    error CannotReportSelf();

    /**
     * @dev Thrown when a user is already suspended or banned.
     */
    error UserAlreadyModerated(address user);

    /**
     * @dev Thrown when attempting to lift a suspension for a user who is not suspended.
     */
    error UserNotSuspended(address user);

    /**
     * @dev Reports a user for violating community guidelines.
     * @param reportedUser The address of the user to report.
     * @param reason A description of the violation.
     */
    function reportUser(address reportedUser, string calldata reason) external;

    /**
     * @dev Issues a warning to a user.
     * Only callable by authorized moderators.
     * @param user The address of the user to warn.
     * @param reason The reason for the warning.
     */
    function warnUser(address user, string calldata reason) external;

    /**
     * @dev Suspends a user for a specified duration.
     * Only callable by authorized moderators.
     * @param user The address of the user to suspend.
     * @param duration The duration of the suspension in seconds.
     * @param reason The reason for the suspension.
     */
    function suspendUser(address user, uint256 duration, string calldata reason) external;

    /**
     * @dev Lifts a user's suspension.
     * Only callable by authorized moderators.
     * @param user The address of the user whose suspension is to be lifted.
     */
    function liftSuspension(address user) external;

    /**
     * @dev Bans a user permanently.
     * Only callable by authorized moderators.
     * @param user The address of the user to ban.
     * @param reason The reason for the ban.
     */
    function banUser(address user, string calldata reason) external;

    /**
     * @dev Checks if a user is currently suspended.
     * @param user The address of the user to check.
     * @return True if the user is suspended, false otherwise.
     * @return suspensionEndTime The timestamp when the suspension ends (0 if not suspended).
     */
    function isUserSuspended(address user) external view returns (bool, uint256 suspensionEndTime);

    /**
     * @dev Checks if a user is currently banned.
     * @param user The address of the user to check.
     * @return True if the user is banned, false otherwise.
     */
    function isUserBanned(address user) external view returns (bool);
}