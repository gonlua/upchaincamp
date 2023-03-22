//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract MyERC20 is ERC20Permit {
    constructor() ERC20("gonlua", "gonlua") ERC20Permit("gonlua")  {
        _mint(msg.sender, 100000*10**18);
    }
}