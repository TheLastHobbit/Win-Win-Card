// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import "../src/Card_market.sol";
import { MyNFT } from "../src/erc721-nft.sol";
import {wUSDT} from "../src/erc20-usdt.sol";

contract CardMarketTest is Test {
    CardMarket public cardMarket;
    MyNFT public nft;
    wUSDT public token;

    address admin = makeAddr("admin");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address shoper = makeAddr("shoper");
    

    function setUp() public {
        vm.startPrank(admin);
        {
            token = new wUSDT();
            cardMarket = new CardMarket(address(token));
            nft = new MyNFT();
            // Market负责发送token奖励
            token.transfer(address(cardMarket), 100000000000000);
            // alice有三张卡
            nft.safeMint(alice,"1");
            nft.safeMint(alice,"2");
            nft.safeMint(alice,"3");

        }
        vm.stopPrank();
        
    }

    function test_buy()public{
        deal(bob, 10000000 ether);
        // 设置token的Market地址
        vm.startPrank(admin);
        {
            token.setMarket(address(cardMarket));
        }
        console.log("Market:",address(cardMarket));
        vm.startPrank(alice);
        {
            nft.approve(address(cardMarket),1);
        }
        vm.stopPrank();   
        vm.startPrank(bob);
        {
            cardMarket.buy{value: 100 ether}(payable(address(alice)),payable(address(shoper)),address(nft),1,100 ether,1);
        }
        vm.stopPrank();
        assertEq(shoper.balance,10 ether);
        assertEq(alice.balance,90 ether);
        assertEq(nft.ownerOf(1),address(bob));
        assertEq(token.balanceOf(address(bob)),50 ether);
        assertEq(token.balanceOf(address(alice)),50 ether);
    }
}

