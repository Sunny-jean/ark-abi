pragma solidity ^0.8.15;

import "./interface/IAIOracle.sol";

/**
 * @title ArkAIOracle
 * @notice Implementation of AI-powered oracle that provides price and risk predictions
 * @dev This oracle uses AI models to provide predictions for various protocol metrics
 */
contract ArkAIOracle is IAIOracle {
    /* ========== STATE VARIABLES ========== */
    
    /// @notice Address of the governance contract
    address public governance;
    
    /// @notice Address of the AI registry contract
    address public aiRegistry;
    
    /// @notice Mapping from prediction request ID to request information
    mapping(bytes32 => PredictionRequest) public predictionRequests;

    struct PredictionRequest {
        bytes32 id;
        string dataSource;
        address requester;
        uint256 timestamp;
        bool fulfilled;
        bytes32 dataHash;
        uint256 dataTimestamp;
    }



    
    /* ========== MODIFIERS ========== */
    
    /**
     * @notice Modifier to restrict function access to governance
     */
    modifier onlyGovernance() {
        require(msg.sender == governance, "ArkAIOracle: caller is not governance");
        _;
    }
    

    
    /* ========== CONSTRUCTOR ========== */
    
    /**
     * @notice Constructor
     * @param _governance Address of the governance contract
     * @param _aiRegistry Address of the AI registry contract
     */
    constructor(address _governance, address _aiRegistry) {
        require(_governance != address(0), "ArkAIOracle: governance cannot be zero address");
        require(_aiRegistry != address(0), "ArkAIOracle: AI registry cannot be zero address");
        
        governance = _governance;
        aiRegistry = _aiRegistry;
    }
    
    /* ========== ADMIN FUNCTIONS ========== */
    
    /**
     * @notice Set the governance address
     * @param _governance New governance address
     */
    function setGovernance(address _governance) external onlyGovernance {
        require(_governance != address(0), "ArkAIOracle: governance cannot be zero address");
        governance = _governance;
    }
    
    /**
     * @notice Set the AI registry address
     * @param _aiRegistry New AI registry address
     */
    function setAIRegistry(address _aiRegistry) external onlyGovernance {
        require(_aiRegistry != address(0), "ArkAIOracle: AI registry cannot be zero address");
        aiRegistry = _aiRegistry;
    }
    
    /* ========== EXTERNAL FUNCTIONS ========== */
    
    /**
     * @notice Request a prediction from the oracle
     * @param dataSource Type of data being requested
     * @param queryParameters Additional parameters for the prediction
     * @return requestId Unique identifier for the prediction request
     */
    function requestData(string calldata dataSource, bytes calldata queryParameters) external override returns (bytes32 requestId) {
        bytes32 requestId = keccak256(abi.encodePacked(dataSource, queryParameters, block.timestamp, msg.sender));
        
        predictionRequests[requestId] = PredictionRequest({
            id: requestId,
            dataSource: dataSource,
            requester: msg.sender,
            timestamp: block.timestamp,
            fulfilled: false,
            dataHash: bytes32(0),
            dataTimestamp: 0
        });
        
        emit DataRequested(requestId, dataSource, keccak256(queryParameters));
        
        return requestId;
    }
    
    /**
     * @notice Fulfill a prediction request
     * @param requestId Unique identifier for the prediction request
     * @param data Result of the prediction
     */
    function fulfillRequest(bytes32 requestId, bytes calldata data) external override {
        PredictionRequest storage request = predictionRequests[requestId];
        
        require(request.id == requestId, "ArkAIOracle: request does not exist");
        require(!request.fulfilled, "ArkAIOracle: request already fulfilled");
        
        // we would check that the caller is authorized to fulfill this request
        // For example, it could be an oracle node or an AI model adapter
        
        request.fulfilled = true;
        request.dataHash = keccak256(data);
        request.dataTimestamp = block.timestamp;
        
        emit DataProvided(requestId, keccak256(data), block.timestamp);
    }
    
    /**
     * @notice Add a new data source
     * @param sources Array of data source names to authorize

     */
    function setAuthorizedDataSources(string[] calldata sources) external override onlyGovernance {
        // This function would typically update an internal mapping or array of authorized data sources.
        // For simplicity, we'll just iterate through the provided sources.
        for (uint256 i = 0; i < sources.length; i++) {
            // In a real implementation, you would add logic to store and manage these sources.
            // For example: authorizedDataSources[sources[i]] = true;
        }
    }
    

    

    
    /* ========== VIEW FUNCTIONS ========== */
    

    
    /**
     * @notice Get information about a prediction request
     * @param requestId Unique identifier for the prediction request
     * @return Prediction request information
     */
    function getPredictionRequest(bytes32 requestId) external view returns (PredictionRequest memory) {
        return predictionRequests[requestId];
    }
    


    /**
     * @notice Retrieves the data associated with a specific request ID.
     * @param requestId The ID of the data request.

     */
    function retrieveData(bytes32 requestId) external view override returns (string memory status, bytes32 dataHash, uint256 timestamp) {
        PredictionRequest storage request = predictionRequests[requestId];
        if (!request.fulfilled) {
            return ("Pending", bytes32(0), 0);
        }
        return ("Fulfilled", request.dataHash, request.dataTimestamp);
    }

    

    


}