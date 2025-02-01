// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PlayerInfo.sol";
import "./Leaderboard.sol";
import "./NFTAchievements.sol";

contract MatchCreation {
    mapping (bytes32 => uint256) public playerratings;
    mapping (uint256 => Match) public matches;
    uint256 public matchID;
    uint256 public maxAllowedDifference = 100;
    uint256 public minimumStake = 0.001 ether;
    uint256 public maxStake = 1 ether;

    struct Match{
        address player1;
        address player2;
        uint256 stakeAmount;
        bool completed;
    }

    mapping (uint256 => mapping(address => bool)) public matchAccepted;

    PlayerInfo public playerInfo;
    LeaderBoard public leaderboard;
    NFTAchievements public nftAchievements;

    constructor(address _playerInfo, address _leaderboard, address _nftAchievements) {
        playerInfo = PlayerInfo(_playerInfo);
        leaderboard = LeaderBoard(_leaderboard);
        nftAchievements = NFTAchievements(_nftAchievements);
    }

    function setPlayerrating(address player, uint256 rating) public {
        bytes32 playerHash = keccak256(abi.encodePacked(player));
        playerratings[playerHash] = rating;
    }

    function calculateStake(uint rating1, uint rating2) public view returns (uint256){
        uint ratingDifference = rating1 > rating2 ? rating1 - rating2 : rating2 - rating1;
        uint stakeAmount = ratingDifference * 0.001 ether;
        if(stakeAmount < minimumStake){
            stakeAmount = 0.001 ether;
        }
        if(stakeAmount > maxStake){
            stakeAmount = maxStake;
        }
        return stakeAmount;
    }

    function createMatch(address opponent) external payable {
        bytes32 playerhash = keccak256(abi.encodePacked(msg.sender));
        bytes32 opponentHash = keccak256(abi.encodePacked(opponent));
        uint playerRating = playerratings[playerhash];
        uint opponentRating = playerratings[opponentHash];

        uint ratingdifference = playerRating > opponentRating ? playerRating - opponentRating : opponentRating - playerRating;
        require(ratingdifference <= maxAllowedDifference, "Connection failed.");
        
        uint stakeAmount = calculateStake(playerRating, opponentRating);
        require(stakeAmount >= minimumStake, "Stake is below the minimum required.");
        require(stakeAmount <= maxStake, "Stake exceeds the maximum allowed.");
        require(msg.value == stakeAmount, "Incorrect stake amount.");

        matchID++;
        matches[matchID] = Match(msg.sender, opponent, stakeAmount, false);

        matchAccepted[matchID][msg.sender] = false;
        matchAccepted[matchID][opponent] = false;
    }

    function acceptMatch(uint matchId) external {
        require(msg.sender == matches[matchId].player1 || msg.sender == matches[matchId].player2, "You are not part of this match.");
        
        matchAccepted[matchId][msg.sender] = true;

        if (matchAccepted[matchId][matches[matchId].player1] && matchAccepted[matchId][matches[matchId].player2]) {
            address winner = msg.sender;
            payable(winner).transfer(matches[matchId].stakeAmount);
            matches[matchId].completed = true;

            updatePlayerRating(matchId, winner);
        }
    }

    function updatePlayerRating(uint matchId, address winner) internal {
        require(matches[matchId].completed == true, "Match not completed yet.");
        
        address loser = winner == matches[matchId].player1 ? matches[matchId].player2 : matches[matchId].player1;
        
        bytes32 winnerHash = keccak256(abi.encodePacked(winner));
        bytes32 loserHash = keccak256(abi.encodePacked(loser));
        
        uint winnerRating = playerratings[winnerHash];
        uint loserRating = playerratings[loserHash];
        
        uint ratingdifference = calculateRatingDifference(winnerRating, loserRating);
        
        uint newWinnerRating = winnerRating + (ratingdifference / 2);
        uint newLoserRating = loserRating - (ratingdifference / 2);
        
        playerInfo.updatePlayerRating(winner, newWinnerRating);
        playerInfo.updatePlayerRating(loser, newLoserRating);

        leaderboard.addorUpdatePlayer(winner, newWinnerRating);
        leaderboard.addorUpdatePlayer(loser, newLoserRating);

        nftAchievements.setPlayerRating(winner, newWinnerRating);
        nftAchievements.setPlayerRating(loser, newLoserRating);

        playerratings[winnerHash] = newWinnerRating;
        playerratings[loserHash] = newLoserRating;
    }

    function calculateRatingDifference(uint rating1, uint rating2) internal pure returns (uint){
        uint ratingDifference = rating1 > rating2 ? rating1 - rating2 : rating2 - rating1;
        return ratingDifference;
    }
}
