// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PlayerInfo {
    
    struct Player {
        address wallet;
        string username;
        uint256 rating;
    }

    mapping(address => Player) public players;

    event PlayerInfoUpdated(address indexed wallet, string username, uint256 rating);

    function setPlayerInfo(string memory username, uint256 rating) public {
        players[msg.sender] = Player({
            wallet: msg.sender,
            username: username,
            rating: rating
        });

        emit PlayerInfoUpdated(msg.sender, username, rating);
    }

    function getPlayerInfo(address player) public view returns (string memory, uint256) {
        return (players[player].username, players[player].rating);
    }

    function updatePlayerRating(address player, uint256 newRating) public {
        players[player].rating = newRating;
        emit PlayerInfoUpdated(player, players[player].username, newRating);
    }
}
