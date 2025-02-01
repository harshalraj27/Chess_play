// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTAchievements is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(address => uint256) public playerRatings;  
    mapping(address => uint256[]) public playerNFTs;  

    uint256[] public milestones = [1000, 1500, 2000, 2500, 3000];

    constructor() ERC721("ChessAchievementNFT", "CANFT") Ownable(msg.sender) {}

    function setPlayerRating(address player, uint256 rating) external onlyOwner {
        playerRatings[player] = rating;
        checkAndMintNFT(player);
    }

    function checkAndMintNFT(address player) internal {
        uint256 playerRating = playerRatings[player];

        for (uint256 i = 0; i < milestones.length; i++) {
            if (playerRating >= milestones[i] && !hasAchievedMilestone(player, milestones[i])) {
                mintNFT(player);
            }
        }
    }

    function hasAchievedMilestone(address player, uint256 milestone) internal view returns (bool) {
        for (uint256 i = 0; i < playerNFTs[player].length; i++) {
            if (playerNFTs[player][i] == milestone) {
                return true;
            }
        }
        return false;
    }

    function mintNFT(address player) internal {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(player, tokenId);

        playerNFTs[player].push(tokenId);  
    }

    function getPlayerRating(address player) external view returns (uint256) {
        return playerRatings[player];
    }

    function getPlayerNFTs(address player) external view returns (uint256[] memory) {
        return playerNFTs[player];
    }
}
