// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
 * @title NFTMarket contract that allows atomic swaps of ERC20 and ERC721
 */
contract CardMarket{
    IERC20 public erc20;
    // IERC721 public erc721;

// 当 ERC721 代币被转移到一个合约时，该合约的 onERC721Received 函数需要返回这个特定的魔术值，以表明合约成功接收了代币。
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    struct Order {
        address seller;
        string busiName;
        uint256 tokenId;
        uint256 price;
    }

    mapping(address account => address Card) accToCard; // account to card

    mapping(address CardAddr=>mapping(uint256 id=>Order)) accToCardToId; // account to card to id

    // mapping(mapping(address=>uint256) => Order) public busiToIdToOrder; // token id to order
    Order[] public orders;
    mapping(uint256 => uint256) public idToOrderIndex;

    event Deal(address buyer, address seller, string busName,uint256 tokenId, uint256 price);
    event NewOrder(address seller,string busName,uint256 tokenId, uint256 price);
    event CancelOrder(address seller,string busName,uint256 tokenId);
    event ChangePrice(
        address seller,
        string busName,
        uint256 tokenId,
        uint256 previousPrice,
        uint256 price
    );

    constructor(IERC20 _erc20) {
        require(
            address(_erc20) != address(0),
            "Market: IERC20 contract address must be non-null"
        );
        erc20 = _erc20;
    }

// 上架
     function placeOrder(
        address _CardAddr,
        address _seller,
        uint256 _tokenId,
        string memory _busiName,
        uint256 _price
    ) public {
        require(_price > 0, "Market: Price must be greater than zero");

        accToCardToId[_CardAddr][_tokenId].seller = _seller;
        accToCardToId[_CardAddr][_tokenId].busiName = _busiName;
        accToCardToId[_CardAddr][_tokenId].price = _price;
        accToCardToId[_CardAddr][_tokenId].tokenId = _tokenId;

        orders.push(accToCardToId[_CardAddr][_tokenId]);
        // idToOrderIndex[_tokenId] = orders.length - 1;

        emit NewOrder(_seller, _busiName,_tokenId, _price);
    }

    function getOrderSeller(address _CardAddr,uint256 _tokenId) public view returns (address) {
        return accToCardToId[_CardAddr][_tokenId].seller;
    }

    function getOrderPrice(address _CardAddr,uint256 _tokenId) public view returns (uint256) {
        return accToCardToId[_CardAddr][_tokenId].price;
    }

    function buy(address _CardAddr,uint256 _tokenId) external {
        require(isListed(_CardAddr,_tokenId), "Market: Token ID is not listed");

        address seller =accToCardToId[_CardAddr][_tokenId].seller;
        address buyer = msg.sender;
        string memory busiName = accToCardToId[_CardAddr][_tokenId].busiName;
        // uint256 _tokenId = accToCardToId[_CardAddr][_tokenId].tokenId;
        uint256 price = accToCardToId[_CardAddr][_tokenId].price;
        require(
            erc20.transferFrom(buyer, seller, price),
            "Market: ERC20 transfer not successful"
        );
        IERC721(_CardAddr).safeTransferFrom(seller, buyer, _tokenId);
        removeListing(_CardAddr,_tokenId);
        emit Deal( buyer,seller, busiName,_tokenId,price);
    }

     function removeListing(address busiAddr,uint256 _tokenId) internal {
        delete accToCardToId[busiAddr][_tokenId];
        orders.pop();
    }

    function cancelOrder(address _CardAddr,uint256 _tokenId) external {
        require(isListed(_CardAddr,_tokenId), "Market: Token ID is not listed");

        address seller = accToCardToId[_CardAddr][_tokenId].seller;
        string memory busiName =  accToCardToId[_CardAddr][_tokenId].busiName;
        require(seller == msg.sender, "Market: Sender is not seller");

        // erc721.safeTransferFrom(address(this), seller, _tokenId);
        removeListing(_CardAddr,_tokenId);

        emit CancelOrder(seller,busiName,_tokenId);
    }

    // function changePrice(uint256 _tokenId, uint256 _price) external {
    //     require(isListed(_tokenId), "Market: Token ID is not listed");
    //     address seller = orderOfId[_tokenId].seller;
    //     require(seller == msg.sender, "Market: Sender is not seller");

    //     uint256 previousPrice = orderOfId[_tokenId].price;
    //     orderOfId[_tokenId].price = _price;
    //     Order storage order = orders[idToOrderIndex[_tokenId]];
    //     order.price = _price;

    //     emit ChangePrice(seller, _tokenId, previousPrice, _price);
    // }

    function getAllNFTs() public view returns (Order[] memory) {
        return orders;
    }
    function getMyOrders() public view returns (Order[] memory) {
        Order[] memory myOrders = new Order[](orders.length);
        uint256 myOrdersCount = 0;

        for (uint256 i = 0; i < orders.length; i++) {
            if (orders[i].seller == msg.sender) {
                myOrders[myOrdersCount] = orders[i];
                myOrdersCount++;
            }
        }

        Order[] memory myOrdersTrimmed = new Order[](myOrdersCount);
        for (uint256 i = 0; i < myOrdersCount; i++) {
            myOrdersTrimmed[i] = myOrders[i];
        }
        return myOrdersTrimmed;
    }

    function isListed(address _CardAddr,uint256 _tokenId) public view returns (bool) {
        return accToCardToId[_CardAddr][_tokenId].seller != address(0);
    }

    function getOrderLength() public view returns (uint256) {
        return orders.length;
    }
    // https://stackoverflow.com/questions/63252057/how-to-use-bytestouint-function-in-solidity-the-one-with-assembly
    function toUint256(
        bytes memory _bytes,
        uint256 _start
    ) public pure returns (uint256) {
        require(_start + 32 >= _start, "Market: toUint256_overflow");
        require(_bytes.length >= _start + 32, "Market: toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }
   
}
