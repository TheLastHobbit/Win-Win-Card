// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import "../src/nft-market.sol";
import { MyNFT } from "../src/erc721-nft.sol";
import {cUSDT} from "../src/erc20-usdt.sol";

contract CardMarketTest is Test {
    CardMarket public cardMarket;
    MyNFT public nft;
   cUSDT public token;

    address admin = makeAddr("admin");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    

    function setUp() public {
        vm.startPrank(admin);
        {
             token = new cUSDT();
            cardMarket = new CardMarket(token);
            nft = new MyNFT();
            token.transfer(alice, 100000000000000);
            token.transfer(bob, 100000000000000);
            nft.safeMint(alice,"1");
            nft.safeMint(alice,"2");
            nft.safeMint(alice,"3");

        }
        vm.stopPrank();
    }

    function test_placeOrder()public{
        vm.startPrank(alice);
        {
        cardMarket.placeOrder(address(nft),alice,1,"zz",10000);
        assertEq(cardMarket.getOrderSeller(address(nft),1),alice);
        }
    }
}

