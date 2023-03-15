//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
contract Bank {

    mapping(address => uint) deposits; // 记录每个地址的转账金额

    function getDeposit() public view returns(uint) {
        return deposits[msg.sender];
    }

    // 合约接受转账时会执行receive方法
    receive() external payable {
        deposits[msg.sender] += msg.value;
    }

    function withdraw() public payable {
        require(deposits[msg.sender] > 0, "No deposit to withdraw!");
        address payable _payableAddr = payable(msg.sender);
        _payableAddr.transfer(deposits[msg.sender]);
        deposits[msg.sender] = 0;
    }
}