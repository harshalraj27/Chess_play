// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTAchievements is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(address => uint256) public playerRatings;  
    mapping(address => uint256) public playerNFTs;  

    uint256 public milestone1 = 1000;
    uint256 public milestone2 = 1500;
    uint256 public milestone3 = 2000;
    uint256 public milestone4 = 2500;
    uint256 public milestone5 = 3000;

    constructor() ERC721("ChessAchievementNFT", "CANFT") {}

    function setPlayerRating(address player, uint256 rating) external {
        playerRatings[player] = rating;
        checkAndMintNFT(player);
    }

    function checkAndMintNFT(address player) internal {
        uint256 playerRating = playerRatings[player];
        
        if (playerRating >= milestone5 && playerNFTs[player] == 0) {
            mintNFT(player);
        } else if (playerRating >= milestone4 && playerNFTs[player] == 0) {
            mintNFT(player);
        } else if (playerRating >= milestone3 && playerNFTs[player] == 0) {
            mintNFT(player);
        } else if (playerRating >= milestone2 && playerNFTs[player] == 0) {
            mintNFT(player);
        } else if (playerRating >= milestone1 && playerNFTs[player] == 0) {
            mintNFT(player);
        }
    }

    function mintNFT(address player) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(player, tokenId);
        _tokenIdCounter.increment();

        playerNFTs[player] = tokenId;  
    }

    function getPlayerRating(address player) external view returns (uint256) {
        return playerRatings[player];
    }
}
