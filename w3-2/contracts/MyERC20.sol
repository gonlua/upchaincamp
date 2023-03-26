//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "@openzeppelin/contracts/utils/Address.sol";

using Address for address;

contract MyERC20 is ERC20 {
    constructor() ERC20("gonlua", "gonlua") {}
}

interface TokenRecipient {
    function tokensReceived(address sender, uint amount) external returns (bool);
}

contract MyERC20v2 is ERC20 {
    constructor() ERC20("gonlua", "gonlua") {}

    function transferWithCallback(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        if (to.isContract()) {
            bool rv = TokenRecipient(to).tokensReceived(msg.sender, amount);
            require(rv, "No tokens received!");
        }
        return true;
    }
}

contract Bank {
    mapping(address => uint) deposits;

    function getDeposit() public view returns(uint) {
        return deposits[msg.sender];
    }

    function tokensReceived(address owner, uint amount) external returns (bool) {
        deposits[owner] = amount;
        return true;
    }
}

// 代理合约
contract MyERC20Proxy is ERC20 {

    constructor() ERC20("gonlua", "gonlua") {
        _mint(msg.sender, 100000*10**18);
    }

    function _delegate(address _implementation) internal virtual {
        assembly {

            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                // revert(p, s) - end execution, revert state changes, return data mem[p…(p+s))
                revert(0, returndatasize())
            }
            default {
                // return(p, s) - end execution, return data mem[p…(p+s))
                return(0, returndatasize())
            }
        }
    }

    function _fallback() private {
        _delegate(_getImplementation());
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {}

    bytes32 private constant IMPLEMETATION_SLOT = bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);

    function _getImplementation() private view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMETATION_SLOT).value;
    }

    function _setImplementation(address _implementation) private {
        require(_implementation.code.length > 0, "implementation is not a contract!");
        StorageSlot.getAddressSlot(IMPLEMETATION_SLOT).value = _implementation;
    }

    function upgradeTo(address _implementation) external {
        _setImplementation(_implementation);
    }
 
    // 获取callData, 测试用
    function getCallData(address to, uint256 amount) external pure returns (bytes memory) {
        return abi.encodeWithSignature("transferWithCallback(address,uint256)", to, amount);
    }

}