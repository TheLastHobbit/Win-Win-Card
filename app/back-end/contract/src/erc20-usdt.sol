// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract wUSDT is ERC20 {
    address Market;
    address admin;   
    constructor() ERC20("Win-Win USDT", "wUSDT") {
        _mint(msg.sender, 1 * 10 ** 8 * 10 ** decimals());
       admin = msg.sender;
    }

    function setMarket(address _Market) external {
        require(msg.sender==admin, "Only admin can call this function");
        Market = _Market;
    }

    modifier onlyMarket {
        require(msg.sender==Market, "Only market can call this function");
        _;
    }

    function Aware(address buyer,address seller,uint256 amount) external onlyMarket returns(uint256){
        _mint(buyer,amount);
        _mint(seller,amount);
        return amount;
    }
}
