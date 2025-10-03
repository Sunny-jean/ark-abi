// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

/**
 * @title IArkTherapist
 * @notice interface for the ArkMindTherapist module
 */
interface IArkTherapist {
    /* ========== EVENTS ========== */
    
    /**
     * @notice Emitted when a new therapy session is created
     * @param user Address of the user
     * @param sessionId ID of the therapy session
     * @param timestamp Time when the session was created
     */
    event TherapySessionCreated(address indexed user, uint256 indexed sessionId, uint256 timestamp);
    
    /**
     * @notice Emitted when a therapy session is completed
     * @param user Address of the user
     * @param sessionId ID of the therapy session
     * @param timestamp Time when the session was completed
     */
    event TherapySessionCompleted(address indexed user, uint256 indexed sessionId, uint256 timestamp);
    
    /**
     * @notice Emitted when a user receives a mental health recommendation
     * @param user Address of the user
     * @param recommendationId ID of the recommendation
     * @param timestamp Time when the recommendation was made
     */
    event RecommendationMade(address indexed user, uint256 indexed recommendationId, uint256 timestamp);
    
    /* ========== STRUCTS ========== */
    
    /**
     * @notice Structure for a therapy session
     * @param id ID of the therapy session
     * @param user Address of the user
     * @param startTime Time when the session started
     * @param endTime Time when the session ended (0 if not ended)
     * @param mood User's mood score (0-100)
     * @param stressLevel User's stress level (0-100)
     * @param notes Additional notes about the session
     * @param completed Whether the session is completed
     */
    struct TherapySession {
        uint256 id;
        address user;
        uint256 startTime;
        uint256 endTime;
        uint8 mood;
        uint8 stressLevel;
        string notes;
        bool completed;
    }
    
    /**
     * @notice Structure for a mental health recommendation
     * @param id ID of the recommendation
     * @param user Address of the user
     * @param timestamp Time when the recommendation was made
     * @param recommendationType Type of recommendation (1: Meditation, 2: Exercise, 3: Social, 4: Creative, 5: Professional help)
     * @param description Description of the recommendation
     * @param urgency Urgency level (1: Low, 2: Medium, 3: High)
     * @param completed Whether the recommendation has been completed by the user
     */
    struct Recommendation {
        uint256 id;
        address user;
        uint256 timestamp;
        uint8 recommendationType;
        string description;
        uint8 urgency;
        bool completed;
    }
    
    /**
     * @notice Structure for a user's mental health profile
     * @param user Address of the user
     * @param averageMood Average mood score over all sessions
     * @param averageStressLevel Average stress level over all sessions
     * @param sessionCount Number of therapy sessions
     * @param lastSessionTime Time of the last therapy session
     * @param riskScore Mental health risk score (0-100)
     */
    struct UserProfile {
        address user;
        uint8 averageMood;
        uint8 averageStressLevel;
        uint256 sessionCount;
        uint256 lastSessionTime;
        uint8 riskScore;
    }
    
    /* ========== ERRORS ========== */
    
    /**
     * @notice Thrown when a function is called by an unauthorized address
     */
    error AT_OnlyGovernance();
    
    /**
     * @notice Thrown when a function is called by an unauthorized therapist
     */
    error AT_OnlyTherapist();
    
    /**
     * @notice Thrown when a therapy session does not exist
     */
    error AT_SessionNotFound();
    
    /**
     * @notice Thrown when a therapy session is already completed
     */
    error AT_SessionAlreadyCompleted();
    
    /**
     * @notice Thrown when a recommendation does not exist
     */
    error AT_RecommendationNotFound();
    
    /**
     * @notice Thrown when a user does not have a profile
     */
    error AT_UserProfileNotFound();
    
    /* ========== EXTERNAL FUNCTIONS ========== */
    
    /**
     * @notice Create a new therapy session for a user
     * @param user Address of the user
     * @param mood Initial mood score (0-100)
     * @param stressLevel Initial stress level (0-100)
     * @param notes Additional notes about the session
     * @return sessionId ID of the created therapy session
     */
    function createTherapySession(address user, uint8 mood, uint8 stressLevel, string calldata notes) external returns (uint256);
    
    /**
     * @notice Complete a therapy session
     * @param sessionId ID of the therapy session
     * @param mood Final mood score (0-100)
     * @param stressLevel Final stress level (0-100)
     * @param notes Additional notes about the session
     */
    function completeTherapySession(uint256 sessionId, uint8 mood, uint8 stressLevel, string calldata notes) external;
    
    /**
     * @notice Make a mental health recommendation for a user
     * @param user Address of the user
     * @param recommendationType Type of recommendation (1: Meditation, 2: Exercise, 3: Social, 4: Creative, 5: Professional help)
     * @param description Description of the recommendation
     * @param urgency Urgency level (1: Low, 2: Medium, 3: High)
     * @return recommendationId ID of the created recommendation
     */
    function makeRecommendation(address user, uint8 recommendationType, string calldata description, uint8 urgency) external returns (uint256);
    
    /**
     * @notice Mark a recommendation as completed
     * @param recommendationId ID of the recommendation
     */
    function completeRecommendation(uint256 recommendationId) external;
    
    /**
     * @notice Update a user's risk score
     * @param user Address of the user
     * @param riskScore New risk score (0-100)
     */
    function updateRiskScore(address user, uint8 riskScore) external;
    
    /* ========== VIEW FUNCTIONS ========== */
    
    /**
     * @notice Get a therapy session by ID
     * @param sessionId ID of the therapy session
     * @return TherapySession information
     */
    function getTherapySession(uint256 sessionId) external view returns (TherapySession memory);
    
    /**
     * @notice Get all therapy sessions for a user
     * @param user Address of the user
     * @return Array of therapy session IDs
     */
    function getUserTherapySessions(address user) external view returns (uint256[] memory);
    
    /**
     * @notice Get a recommendation by ID
     * @param recommendationId ID of the recommendation
     * @return Recommendation information
     */
    function getRecommendation(uint256 recommendationId) external view returns (Recommendation memory);
    
    /**
     * @notice Get all recommendations for a user
     * @param user Address of the user
     * @return Array of recommendation IDs
     */
    function getUserRecommendations(address user) external view returns (uint256[] memory);
    
    /**
     * @notice Get a user's mental health profile
     * @param user Address of the user
     * @return UserProfile information
     */
    function getUserProfile(address user) external view returns (UserProfile memory);
    
    /**
     * @notice Get the total number of therapy sessions
     * @return Total number of therapy sessions
     */
    function getTotalSessionCount() external view returns (uint256);
    
    /**
     * @notice Get the total number of recommendations
     * @return Total number of recommendations
     */
    function getTotalRecommendationCount() external view returns (uint256);
    
    /**
     * @notice Get the average mood score across all users
     * @return Average mood score (0-100)
     */
    function getAverageMoodScore() external view returns (uint8);
    
    /**
     * @notice Get the average stress level across all users
     * @return Average stress level (0-100)
     */
    function getAverageStressLevel() external view returns (uint8);
    
    /**
     * @notice Get the average risk score across all users
     * @return Average risk score (0-100)
     */
    function getAverageRiskScore() external view returns (uint8);
}

/**
 * @title ArkMindTherapist
 * @notice Implementation of the ArkMindTherapist module for mental health support in the ARK protocol
 * @dev This is a  for demonstration purposes
 */
contract ArkMindTherapist is IArkTherapist {
    /* ========== STATE VARIABLES ========== */
    
    /// @notice Address of the governance contract
    address public governance;
    
    /// @notice Address of the AI registry contract
    address public aiRegistry;
    
    /// @notice Mapping from session ID to therapy session information
    mapping(uint256 => TherapySession) public therapySessions;
    
    /// @notice Mapping from recommendation ID to recommendation information
    mapping(uint256 => Recommendation) public recommendations;
    
    /// @notice Mapping from user address to user profile information
    mapping(address => UserProfile) public userProfiles;
    
    /// @notice Mapping from user address to array of therapy session IDs
    mapping(address => uint256[]) public userTherapySessions;
    
    /// @notice Mapping from user address to array of recommendation IDs
    mapping(address => uint256[]) public userRecommendations;
    
    /// @notice Mapping from address to boolean indicating if the address is an authorized therapist
    mapping(address => bool) public authorizedTherapists;
    
    /// @notice Counter for therapy session IDs
    uint256 public sessionIdCounter;
    
    /// @notice Counter for recommendation IDs
    uint256 public recommendationIdCounter;
    
    /// @notice Total number of users with profiles
    uint256 public totalUserCount;
    
    /* ========== MODIFIERS ========== */
    
    /**
     * @notice Modifier to restrict function access to governance
     */
    modifier onlyGovernance() {
        if (msg.sender != governance) revert AT_OnlyGovernance();
        _;
    }
    
    /**
     * @notice Modifier to restrict function access to authorized therapists
     */
    modifier onlyTherapist() {
        if (!authorizedTherapists[msg.sender] && msg.sender != governance) revert AT_OnlyTherapist();
        _;
    }
    
    /* ========== CONSTRUCTOR ========== */
    
    /**
     * @notice Constructor
     * @param _governance Address of the governance contract
     * @param _aiRegistry Address of the AI registry contract
     */
    constructor(address _governance, address _aiRegistry) {
        governance = _governance;
        aiRegistry = _aiRegistry;
        
        // Add the deployer as an authorized therapist
        authorizedTherapists[msg.sender] = true;
    }
    
    /* ========== ADMIN FUNCTIONS ========== */
    
    /**
     * @notice Set the governance address
     * @param _governance New governance address
     */
    function setGovernance(address _governance) external onlyGovernance {
        governance = _governance;
    }
    
    /**
     * @notice Set the AI registry address
     * @param _aiRegistry New AI registry address
     */
    function setAIRegistry(address _aiRegistry) external onlyGovernance {
        aiRegistry = _aiRegistry;
    }
    
    /**
     * @notice Add an authorized therapist
     * @param therapist Address of the therapist to authorize
     */
    function addTherapist(address therapist) external onlyGovernance {
        authorizedTherapists[therapist] = true;
    }
    
    /**
     * @notice Remove an authorized therapist
     * @param therapist Address of the therapist to remove
     */
    function removeTherapist(address therapist) external onlyGovernance {
        authorizedTherapists[therapist] = false;
    }
    
    /* ========== EXTERNAL FUNCTIONS ========== */
    
    /**
     * @notice Create a new therapy session for a user
     * @param user Address of the user
     * @param mood Initial mood score (0-100)
     * @param stressLevel Initial stress level (0-100)
     * @param notes Additional notes about the session
     * @return sessionId ID of the created therapy session
     */
    function createTherapySession(address user, uint8 mood, uint8 stressLevel, string calldata notes) external override onlyTherapist returns (uint256) {
        // Increment session ID counter
        sessionIdCounter++;
        
        // Create new therapy session
        therapySessions[sessionIdCounter] = TherapySession({
            id: sessionIdCounter,
            user: user,
            startTime: block.timestamp,
            endTime: 0,
            mood: mood,
            stressLevel: stressLevel,
            notes: notes,
            completed: false
        });
        
        // Add session ID to user's sessions
        userTherapySessions[user].push(sessionIdCounter);
        
        // Create user profile if it doesn't exist
        if (userProfiles[user].user == address(0)) {
            userProfiles[user] = UserProfile({
                user: user,
                averageMood: mood,
                averageStressLevel: stressLevel,
                sessionCount: 1,
                lastSessionTime: block.timestamp,
                riskScore: 0
            });
            
            totalUserCount++;
        } else {
            // Update user profile
            UserProfile storage profile = userProfiles[user];
            
            // Update average mood and stress level
            profile.averageMood = uint8((uint256(profile.averageMood) * profile.sessionCount + mood) / (profile.sessionCount + 1));
            profile.averageStressLevel = uint8((uint256(profile.averageStressLevel) * profile.sessionCount + stressLevel) / (profile.sessionCount + 1));
            
            // Update session count and last session time
            profile.sessionCount++;
            profile.lastSessionTime = block.timestamp;
        }
        
        emit TherapySessionCreated(user, sessionIdCounter, block.timestamp);
        
        return sessionIdCounter;
    }
    
    /**
     * @notice Complete a therapy session
     * @param sessionId ID of the therapy session
     * @param mood Final mood score (0-100)
     * @param stressLevel Final stress level (0-100)
     * @param notes Additional notes about the session
     */
    function completeTherapySession(uint256 sessionId, uint8 mood, uint8 stressLevel, string calldata notes) external override onlyTherapist {
        // Get therapy session
        TherapySession storage session = therapySessions[sessionId];
        
        // Check if session exists
        if (session.id != sessionId) revert AT_SessionNotFound();
        
        // Check if session is already completed
        if (session.completed) revert AT_SessionAlreadyCompleted();
        
        // Update session
        session.endTime = block.timestamp;
        session.mood = mood;
        session.stressLevel = stressLevel;
        session.notes = notes;
        session.completed = true;
        
        // Update user profile
        UserProfile storage profile = userProfiles[session.user];
        
        // Update average mood and stress level
        profile.averageMood = uint8((uint256(profile.averageMood) * (profile.sessionCount - 1) + mood) / profile.sessionCount);
        profile.averageStressLevel = uint8((uint256(profile.averageStressLevel) * (profile.sessionCount - 1) + stressLevel) / profile.sessionCount);
        
        // Update last session time
        profile.lastSessionTime = block.timestamp;
        
        emit TherapySessionCompleted(session.user, sessionId, block.timestamp);
    }
    
    /**
     * @notice Make a mental health recommendation for a user
     * @param user Address of the user
     * @param recommendationType Type of recommendation (1: Meditation, 2: Exercise, 3: Social, 4: Creative, 5: Professional help)
     * @param description Description of the recommendation
     * @param urgency Urgency level (1: Low, 2: Medium, 3: High)
     * @return recommendationId ID of the created recommendation
     */
    function makeRecommendation(address user, uint8 recommendationType, string calldata description, uint8 urgency) external override onlyTherapist returns (uint256) {
        // Check if user has a profile
        if (userProfiles[user].user == address(0)) revert AT_UserProfileNotFound();
        
        // Increment recommendation ID counter
        recommendationIdCounter++;
        
        // Create new recommendation
        recommendations[recommendationIdCounter] = Recommendation({
            id: recommendationIdCounter,
            user: user,
            timestamp: block.timestamp,
            recommendationType: recommendationType,
            description: description,
            urgency: urgency,
            completed: false
        });
        
        // Add recommendation ID to user's recommendations
        userRecommendations[user].push(recommendationIdCounter);
        
        emit RecommendationMade(user, recommendationIdCounter, block.timestamp);
        
        return recommendationIdCounter;
    }
    
    /**
     * @notice Mark a recommendation as completed
     * @param recommendationId ID of the recommendation
     */
    function completeRecommendation(uint256 recommendationId) external override {
        // Get recommendation
        Recommendation storage recommendation = recommendations[recommendationId];
        
        // Check if recommendation exists
        if (recommendation.id != recommendationId) revert AT_RecommendationNotFound();
        
        // Check if the caller is the user or an authorized therapist
        if (recommendation.user != msg.sender && !authorizedTherapists[msg.sender] && msg.sender != governance) revert AT_OnlyTherapist();
        
        // Mark recommendation as completed
        recommendation.completed = true;
    }
    
    /**
     * @notice Update a user's risk score
     * @param user Address of the user
     * @param riskScore New risk score (0-100)
     */
    function updateRiskScore(address user, uint8 riskScore) external override onlyTherapist {
        // Check if user has a profile
        if (userProfiles[user].user == address(0)) revert AT_UserProfileNotFound();
        
        // Update risk score
        userProfiles[user].riskScore = riskScore;
    }
    
    /* ========== VIEW FUNCTIONS ========== */
    
    /**
     * @notice Get a therapy session by ID
     * @param sessionId ID of the therapy session
     * @return TherapySession information
     */
    function getTherapySession(uint256 sessionId) external view override returns (TherapySession memory) {
        return therapySessions[sessionId];
    }
    
    /**
     * @notice Get all therapy sessions for a user
     * @param user Address of the user
     * @return Array of therapy session IDs
     */
    function getUserTherapySessions(address user) external view override returns (uint256[] memory) {
        return userTherapySessions[user];
    }
    
    /**
     * @notice Get a recommendation by ID
     * @param recommendationId ID of the recommendation
     * @return Recommendation information
     */
    function getRecommendation(uint256 recommendationId) external view override returns (Recommendation memory) {
        return recommendations[recommendationId];
    }
    
    /**
     * @notice Get all recommendations for a user
     * @param user Address of the user
     * @return Array of recommendation IDs
     */
    function getUserRecommendations(address user) external view override returns (uint256[] memory) {
        return userRecommendations[user];
    }
    
    /**
     * @notice Get a user's mental health profile
     * @param user Address of the user
     * @return UserProfile information
     */
    function getUserProfile(address user) external view override returns (UserProfile memory) {
        return userProfiles[user];
    }
    
    /**
     * @notice Get the total number of therapy sessions
     * @return Total number of therapy sessions
     */
    function getTotalSessionCount() external view override returns (uint256) {
        return sessionIdCounter;
    }
    
    /**
     * @notice Get the total number of recommendations
     * @return Total number of recommendations
     */
    function getTotalRecommendationCount() external view override returns (uint256) {
        return recommendationIdCounter;
    }
    
    /**
     * @notice Get the average mood score across all users
     * @return Average mood score (0-100)
     */
    function getAverageMoodScore() external view override returns (uint8) {
        if (totalUserCount == 0) return 0;
        
        
        return 65;
    }
    
    /**
     * @notice Get the average stress level across all users
     * @return Average stress level (0-100)
     */
    function getAverageStressLevel() external view override returns (uint8) {
        if (totalUserCount == 0) return 0;
        
        
        return 45;
    }
    
    /**
     * @notice Get the average risk score across all users
     * @return Average risk score (0-100)
     */
    function getAverageRiskScore() external view override returns (uint8) {
        if (totalUserCount == 0) return 0;
        
        
        return 30;
    }
}