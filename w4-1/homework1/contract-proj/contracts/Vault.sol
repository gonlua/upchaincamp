//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

contract MyERC20 is ERC20Permit {
    constructor() ERC20("gonlua", "gonlua") ERC20Permit("gonlua")  {
        _mint(msg.sender, 100000*10**18);
    }
}

contract Vault {

    address token;
    mapping(address => uint) deposits;

    constructor(address _token) {
        token = _token;
    }

    function deposit(uint amount) public {
        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

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