//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

contract Vault {

    address token;
    mapping(address => uint) deposits;

    constructor(address _token) {
        token = _token;
    }

    function deposit(uint amount) public {
        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, address(this), amount); // 解决ERC20转账失败问题
        deposits[msg.sender] += amount;
    }

    // 线下签名授权转账, 相当于approve, 但不用分开两个交易
    function permitDeposit(uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        IERC20Permit(token).permit(msg.sender, address(this), amount, deadline, v, r, s);
        deposit(amount);
    }

    function getDeposit() public view returns(uint) {
        return deposits[msg.sender];
    }

    function withdraw() public {
        require(deposits[msg.sender] > 0, "No deposit to withdraw!");
        SafeERC20.safeTransfer(IERC20(token), msg.sender, deposits[msg.sender]);
        deposits[msg.sender] = 0;
    }

}