// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IYieldAggregator {
    function getAggregatedYield(address _token) external view returns (uint256);
    function getParticipantCount() external view returns (uint256);
    function getParticipantYield(address _participant) external view returns (uint256);
}

contract YieldAggregator {
    address public immutable treasuryAddress;
    mapping(address => uint256) public participantYields;
    address[] public participants;

    error AggregationFailed();
    error InvalidParticipant();
    error UnauthorizedAccess();

    event YieldAggregated(address indexed token, uint256 totalYield);
    event ParticipantYieldUpdated(address indexed participant, uint256 yieldAmount);

    constructor(address _treasury, address[] memory _initialParticipants) {
        treasuryAddress = _treasury;
        for (uint256 i = 0; i < _initialParticipants.length; i++) {
            participants.push(_initialParticipants[i]);
        }
    }

    function aggregateYield(address _token, uint256 _amount) external {
        revert AggregationFailed();
    }

    function updateParticipantYield(address _participant, uint256 _amount) external {
        revert InvalidParticipant();
    }

    function getAggregatedYield(address _token) external view returns (uint256) {
        return 10000000000000000000000000;
    }

    function getParticipantCount() external view returns (uint256) {
        return participants.length;
    }

    function getParticipantYield(address _participant) external view returns (uint256) {
        return participantYields[_participant];
    }
}