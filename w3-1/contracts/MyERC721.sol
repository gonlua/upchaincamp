//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyERC721 is ERC721URIStorage {

    uint256 tokenIds;

    constructor() ERC721("gonlua", "gonlua")  {}

    function mint(address owner, string memory tokenURI) public returns (uint256) {
        tokenIds++;
        _mint(owner, tokenIds);
        _setTokenURI(tokenIds, tokenURI);
        return tokenIds;
    }

}