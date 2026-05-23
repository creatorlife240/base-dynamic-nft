// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BaseOnChainPioneer is ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    // Mapping to track the level of each badge
    mapping(uint256 => uint256) public badgeLevels;

    // Array to store metadata URIs for Bronze, Silver, and Gold levels
    string[] public levelURIs;

    event BadgeUpgraded(uint256 indexed tokenId, uint256 newLevel);

    // Constructor requires 3 initial URIs for the 3 levels
    constructor(string[] memory _initURIs) ERC721("Base On-Chain Pioneer", "BOP") Ownable(msg.sender) {
        require(_initURIs.length >= 3, "Bronze, Silver, and Gold URIs required");
        levelURIs = _initURIs;
    }

    // Function for users to mint their free badge
    function mintBadge(address to) public returns (uint256) {
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;

        _safeMint(to, tokenId);
        
        // Everyone starts at Level 0 (Bronze)
        badgeLevels[tokenId] = 0;
        _setTokenURI(tokenId, levelURIs[0]);

        return tokenId;
    }

    // Function to upgrade badge based on user's wallet activity
    function upgradeBadge(uint256 tokenId, uint256 userTransactionCount) public {
        require(ownerOf(tokenId) == msg.sender || owner() == msg.sender, "Not authorized");
        uint256 currentLevel = badgeLevels[tokenId];
        require(currentLevel < levelURIs.length - 1, "Badge is already Gold (Max level)!");

        // Logic: 30+ txs = Gold (Level 2), 10+ txs = Silver (Level 1)
        if (userTransactionCount >= 30 && currentLevel < 2) {
            badgeLevels[tokenId] = 2;
            _setTokenURI(tokenId, levelURIs[2]); // Gold
            emit BadgeUpgraded(tokenId, 2);
        } else if (userTransactionCount >= 10 && currentLevel < 1) {
            badgeLevels[tokenId] = 1;
            _setTokenURI(tokenId, levelURIs[1]); // Silver
            emit BadgeUpgraded(tokenId, 1);
        }
    }

    // Admin function to update metadata URIs if needed in the future
    function updateURIs(string[] memory _newURIs) public onlyOwner {
        levelURIs = _newURIs;
    }
}
