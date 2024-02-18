// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {Nonces} from "lib/openzeppelin-contracts/contracts/utils/Nonces.sol";
import {console} from "forge-std/console.sol";

import {wUSDT} from "./erc20-usdt.sol";

import "./CardsFactory.sol";

/**
 * @title NFTMarket contract that allows atomic swaps of ERC20 and ERC721
 */
contract CardMarket is EIP712, Nonces,CardsFactory{
    using ECDSA for bytes32;
    bytes32 private constant EIP712DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 private constant STORAGE_TYPEHASH1 =
        keccak256("Storage(address owner,address cardAddr,uint256 price,uint256 id)");
    bytes32 private DOMAIN_SEPARATOR;

    address public erc20;

    event Deal(
        address indexed seller,
        address indexed buyer,
        uint256 id,
        uint256 price,
        address CardAddr
    );
    event verify(
        address indexed verifyer,
        address CardAddr,
        uint256 id,
        uint256 price,
        bytes signature
    );
    event transAware(
        address buyer,
        address seller,
        uint256 account,
        uint256 aware
    );
    event chargeEvent(address indexed shop, uint256 charge);

    constructor(address _erc20)CardsFactory(0x02a00a065d325F9f0eb7AE1D19e40fC129f96CE6,0x17f6eda70e4A7289e9CD57865a0DfC69313EcF58) EIP712("CardMarket", "1") {
        require(
            address(_erc20) != address(0),
            "Market: IERC20 contract address must be non-null"
        );
        erc20 = _erc20;
    }

    function buy(
        address payable seller,
        address payable shopAddr,
        address _CardAddr,
        uint256 _id,
        uint _price,
        uint256 TransNum
    ) public payable {
        address buyer = msg.sender;
        console.log("buyer:", buyer);
        require(msg.value == _price, "msg.value != _price");
        uint256 charge = getCharge(_price);
        (bool success, ) = seller.call{value: (_price - charge)}("");
        require(success, "erc20Transfer Fail");
        (bool success2, ) = shopAddr.call{value: charge}("");
        require(success2, "erc20Transfer_Charge Fail");
        console.log(
            "ERC20_transferFrom success:",
            _price - charge,
            "charge:",
            charge
        );
        IERC721(_CardAddr).safeTransferFrom(seller, buyer, _id);
        console.log("ERC721_safeTransferFrom success:", _id);
        // send Aware
        uint256 awareAmount = _TransAward(buyer, seller, TransNum, _price);
        console.log("TransAware:", awareAmount);
        emit chargeEvent(shopAddr, charge);
        emit Deal(seller, buyer, _id, _price, _CardAddr);
    }
    function permitStore(
        address owner,
        address cardAddr,
        uint256 NFTid,
        uint256 price,
        bytes memory _signature
    ) public {
        // 检查签名长度，65是标准r,s,v签名的长度
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        // 目前只能用assembly (内联汇编)来从签名中获得r,s,v的值
        assembly {
            /*
            前32 bytes存储签名的长度 (动态数组存储规则)
            add(sig, 32) = sig的指针 + 32
            等效为略过signature的前32 bytes
            mload(p) 载入从内存地址p起始的接下来32bytes数据
            */
            // 读取长度数据后的32 bytes
            r := mload(add(_signature, 0x20))
            // 读取之后的32 bytes
            s := mload(add(_signature, 0x40))
            // 读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }
        // 获取签名消息hash
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(STORAGE_TYPEHASH1, owner,cardAddr, price,NFTid))
            )
        );
        address signer = digest.recover(v, r, s); // 恢复签名者
        require(signer == owner, "EIP712Storage: Invalid signature"); // 检查签名

        emit verify(msg.sender,cardAddr,NFTid,price,_signature);
    }

    function permitListbuy(
        address payable seller,
        address payable shopAddr,
        uint256 _id,
        uint _price,
        address _CardAddr,
        uint256 TransNum,
        bytes memory _signature
    ) public payable {
        permitStore(seller,_CardAddr, _id, _price, _signature);
        console.log("permitStore success!");
        address buyer = msg.sender;
        console.log("buyer:", buyer);
        require(msg.value == _price, "msg.value != _price");
        uint256 charge = getCharge(_price);
        console.log("charge:", charge);
        (bool success, ) = seller.call{value: (_price - charge)}("");
        require(success, "erc20Transfer Fail");
        (bool success2, ) = shopAddr.call{value: charge}("");
        require(success2, "erc20Transfer_Charge Fail");
        console.log(
            "ERC20_transferFrom success:",
            _price - charge,
            "charge:",
            charge
        );
        IERC721(_CardAddr).safeTransferFrom(seller, buyer, _id);
        console.log("ERC721_safeTransferFrom success:", _id);
        // send Aware
        uint256 awareAmount = _TransAward(buyer, seller, TransNum, _price);
        console.log("TransAware:", awareAmount);
        emit chargeEvent(shopAddr, charge);
        emit Deal(seller, buyer, _id, _price, _CardAddr);
        
    }

    function _TransAward(
        address buyer,
        address seller,
        uint256 TransNum,
        uint256 amount
    ) internal returns (uint256) {
        // 交易激励：每张Card在第n次被交易时交易双方可获得(1/2^n)*交易金额数量的token。
        // 第一次mint算作第0次。
        uint256 award = (amount) / (2 ** TransNum);
        wUSDT(erc20).Aware(buyer, seller, award);
        emit transAware(buyer, seller, amount, award);
        return award;
    }

    //获取每笔交易的手续费
    function getCharge(uint256 amount) public view returns (uint256) {
        if (amount <= 999 ether) {
            uint256 charge = amount / 10;
            return charge;
        } else if (amount > 999 ether && amount <= 9999 ether) {
            uint256 charge = (amount * 5) / 100;
            return charge;
        } else if (amount > 9999 ether && amount <= 99999 ether) {
            uint256 charge = (amount ) / 1000;
            return charge;
        } else if (amount > 99999 ether && amount <= 999999 ether) {
            uint256 charge = (amount ) / 10000;
            return charge;
        }
    }
}
