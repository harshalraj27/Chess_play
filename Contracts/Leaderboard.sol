// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LeaderBoard {
    struct Player{
        address wallet;
        uint256 rating;
    }
    Player[] public players;
    mapping(address => uint256) public playerRankings;
    mapping(address => bool) public isRegistered;

    event PlayerRegistered(address wallet, uint rating);
    event RatingUpdated(address wallet, uint newRating);

    function addorUpdatePlayer(address wallet, uint256 rating) external {
        if(!isRegistered[wallet]) {
            isRegistered[wallet] = true;
            players.push(Player(wallet, rating));
            playerRankings[wallet] = players.length-1;
            emit PlayerRegistered(wallet, rating);
        } else {
            uint256 index = playerRankings[wallet];
            players[index].rating = rating;
            emit RatingUpdated(wallet, rating);
        }
    }

    function getLeaderboard() public view returns (address[] memory, uint256[] memory) {
        uint256 playerCount = players.length;
        address[] memory playerAddresses = new address[](playerCount);
        uint256[] memory playerRatings = new uint256[](playerCount);

        for(uint256 i = 0; i < playerCount; i++) {
            playerAddresses[i] = players[i].wallet;
            playerRatings[i] = players[i].rating;
        }

        return (playerAddresses, playerRatings);
    }
}
