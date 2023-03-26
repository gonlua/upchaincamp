//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";

using SafeERC20 for IERC20;

// NFT交易所
contract Exchange {

    struct NFTInfo {
        address owner;
        uint price;
    }
    mapping(address => mapping(uint => NFTInfo)) stock; // NFT库存: NFT合约地址 => NFT ID => NFT拥有者和价格
    address token; // ERC20代币合约地址

    constructor(address _token) {
        token = _token;
    }

    /**
     * NFT持有者上架NFT，设置价格 多少个TOKEN购买NFT
     * nftAddr: NFT合约地址
     * nftId: NFT的ID
     * price: NFT价格
     */
    function putOnSale(address _nftAddr, uint _nftId, uint _price) public {
        require(IERC721(_nftAddr).ownerOf(_nftId) == msg.sender, "You are not the NFT owner!");
        stock[_nftAddr][_nftId] = NFTInfo({ owner: msg.sender, price: _price });
    }

    // NFT购买, 转入对应的TOKEN, 获取对应的NFT
    function buy(address _nftAddr, uint _nftId) public {
        NFTInfo memory nftInfo = stock[_nftAddr][_nftId];
        require(IERC20(token).balanceOf(msg.sender) >= nftInfo.price, "You have no enough token to buy!");
        // Transfer ERC20 Token
        IERC20(token).safeTransferFrom(msg.sender, nftInfo.owner, nftInfo.price);
        // Transfer NFT
        IERC721(_nftAddr).safeTransferFrom(nftInfo.owner, msg.sender, _nftId);
    }
}