# “会员卡”相关技术实现与说明（简要版）

## A. 概念解释与说明

为帮助理解“会员卡”的实现，现将相关的名词概念与实现简述如下：

- **会员卡（card）**：
  - **一套会员卡（card series）**：例如，某一个商家可能发行多套会员卡，同一套会员卡的特性是一致的。为了满足同一个商家发行多套会员卡，<u>一套会员卡为独立的一个 ERC-721 token 合约，并以`seriesId`作为**会员套卡**的**唯一标识符**</u>。由合约`CardSeries`提供实现逻辑，每一套会员卡都是通过最小代理部署的`CardSeries`合约实例。
  - **一张会员卡（token）**：某套会员卡中的单张会员卡，这是会员卡的基本单位，由**商家**铸造生成或由用户 *claim* 获得（需**商家**提前构建白名单）。可用于消费、充值、上架、转售等。<u>每一张卡都对应于 ERC-721 token 合约（`CardSeries`合约实例）中独立的`tokenId`</u>。
- **商家（merchant）**：发行“会员卡”的“项目方”，每个商家入驻本平台均需要 *注册* 自己的`merchantId`，<u>每一个商家对应于独立的一个 `merchantId`</u>。同一个`merchantId`可拥有多个成员（即地址），以`merchantId`作为**商家**的**唯一标识符**。由合约`CardsFactory`管理。

以下流程图可示意以上说明内容：

![IMG1_cardImplementation](./images/IMG1_cardImplementation.png)

## B. 合约代码与说明

使用两个合约来实现会员卡的功能以及相关方法：

- **会员套卡合约 `CardSeries`**：实现单套会员卡的特性与功能，为克隆新的合约实例提供“模板”。

- **工厂合约 `CardsFactory`**：通过最小代理部署新的 token 合约作为新的“会员套卡”，同时也是商家和用户的“客户端”合约，通过此合约可直接调用**`CardSeries`**合约中的方法。

--------

### 1. `CardSeries`合约

#### 1-1. 完整代码

```solidity
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title The implementation contract which realizes the basic logic of membership cards.
 */
contract CardSeries is ERC721URIStorage, EIP712Upgradeable, Nonces {
    address public factory;
    uint256 public merchantId;
    string private cardName;
    string private cardSymbol;
    uint256 private currentSupply;
    uint256 public maxSupply;
    mapping(uint256 tokenId => uint256 tokenValue) public cardBalance;

    event validatedForCardClaimed(uint256 storedValue, string tokenURI, uint256 price, address user);

    error notFactory(address caller);
    error invalidSignature(address derivedSigner, address validSigner);
    error expiredSignature(uint256 currendTimestamp, uint256 deadline);
    error reachMaxSupply();
    error notCardOwner();
    error uninitialized();
    error externalApproveBanned();

    constructor() ERC721("XiJianChui", "XJC") {}

    function init(
        address _factoryAddr,
        uint256 _merchantId,
        string calldata _seriesName,
        string calldata _seriesSymbol,
        uint256 _maxSupply
    ) external initializer {
        factory = _factoryAddr;
        merchantId = _merchantId;
        cardName = _seriesName;
        cardSymbol = _seriesSymbol;
        maxSupply = _maxSupply;
        __EIP712_init(_seriesName, "1");
    }

    modifier onlyFactory() {
        if (factory == address(0)) {
            revert uninitialized();
        }
        if (msg.sender != factory) {
            revert notMerchantOrFactory(msg.sender);
        }
        _;
    }

    function mintCard(address _to, string memory _tokenURI, uint256 _value) external onlyFactory returns (uint256) {
        return _mintCard(_to, _tokenURI, _value);
    }

    // function removeApproval(uint256 _tokenId) public {
    //     address cardOwner = ownerOf(_tokenId);
    //     _checkAuthorized(cardOwner, msg.sender, _tokenId);
    //     _approve(address(0), _tokenId, address(0), false);
    // }

    /**
     * @notice To meet the demand of distributing cards to multiple users, the merchant can make a whitelist containing the member addresses and stored values inside the card.
     * Users who are in the whitelist can call {validateCardClaim} to get their cards.
     * The membership of the whitelist should be in the form of a Merkle tree.
     *
     * @param _merkleProof a dynamic array which contains Merkle proof is used for validating the membership of the caller. This should be offered by the project party
     * @param _MerkleRoot the root of the Merkle tree of the whitelist
     * @param _tokenURI a custom string which is stored in the card
     * @param _storedValue the stored value inside the card which is claimed by its user
     * @param _price the price of the card(use ERC20 tokens for pricing)
     */
    function validateCardClaim(
        bytes32[] calldata _merkleProof,
        bytes32 _MerkleRoot,
        string calldata _tokenURI,
        uint256 _storedValue,
        uint256 _price
    ) external {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _storedValue, _tokenURI, _price));
        _verifyMerkleProof(_merkleProof, _MerkleRoot, leaf);
        emit validatedForCardClaimed(_storedValue, _tokenURI, _price, msg.sender);
    }

    /**
     * @notice When a specific card(specified by input '_tokenId') is assigned to be operated by calling this function with a signed message,
     * this function will check if the signer of the signed message equals the owner of the card.
     * Once the signature is successfully validated, the card will be approved to `_operator`.
     * The splitted parts('_v', "_r", "_s") of the signed message, are checked for the validity of the signature.
     *
     * @param _operator the address which is able to control the signer's card
     * @param _tokenId the specific tokenId of the card series which is assigned to be listed
     * @param _deadline the expire timestamp of the input signed message
     * @param _v ECDSA signature parameter v
     * @param _r ECDSA signature parameter r
     * @param _s ECDSA signature parameter s
     */
    function cardPermit(address _operator, uint256 _tokenId, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s)
        external
        onlyFactory
        returns (bool)
    {
        address cardOwner = ownerOf(_tokenId);
        bytes32 PERMIT_TYPEHASH =
            keccak256("cardPermit(address operator,uint256 tokenId,uint256 signerNonce,uint256 deadline)");
        if (block.timestamp > _deadline) {
            revert expiredSignature(block.timestamp, _deadline);
        }

        bytes32 structHash =
            keccak256(abi.encode(PERMIT_TYPEHASH, _operator, _tokenId, _useNonce(cardOwner), _deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, _v, _r, _s);
        if (signer != cardOwner) {
            revert invalidSignature(signer, cardOwner);
        }
        return true;
    }

    function approve(address to, uint256 tokenId) public override {
        revert externalApproveBanned();
    }

    function _mintCard(address _to, string memory _tokenURI, uint256 _value) internal returns (uint256) {
        if (currentSupply >= maxSupply) {
            revert reachMaxSupply();
        }
        uint256 tokenId = _useNonce(address(this));
        _mint(_to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        currentSupply++;
        cardBalance[tokenId] = _value;
        _approve(factory, tokenId, _to);
        return tokenId;
    }

    function _verifyMerkleProof(bytes32[] memory _proof, bytes32 _root, bytes32 _leaf) internal pure {
        require(MerkleProof.verify(_proof, _root, _leaf), "Invalid Merkle proof");
    }

    function getCardName() public view returns (string memory) {
        return cardName;
    }

    function getCardSymbol() public view returns (string memory) {
        return cardSymbol;
    }

    function getCurrentSupply() public view returns (uint256) {
        return currentSupply;
    }

    function getCardBalance(uint256 _tokenId) public view returns (uint256) {
        address cardOwner = ownerOf(_tokenId);
        if (msg.sender != cardOwner) {
            revert notCardOwner();
        }
        return cardBalance[_tokenId];
    }

}
```



#### 1-2. 合约继承与状态变量

```solidity
// 实现 ERC721 标准（ERC721URIStorage合约）
// 为了保证 EIP712 的初始化，继承了 EIP712 合约的可升级版本（EIP712Upgradeable）
contract CardSeries is ERC721URIStorage, EIP712Upgradeable, Nonces {
 		address public factory;					// 工厂合约地址
    uint256 public merchantId;			// 当前会员套卡对应的商家ID（商家唯一标识符）
    string private cardName;      	// 会员套卡的名称
    string private cardSymbol;    	// 会员套卡的标识
    uint256 private currentSupply;	// 会员套卡的当前总量
    uint256 public maxSupply;				// 会员套卡的最大发行量
    mapping(uint256 tokenId => uint256 tokenValue) public cardBalance;		// 单张会员卡的卡内余额
    
    // 其他逻辑...
}
```



#### 1-3. 事件与错误

```solidity
contract CardSeries is ERC721URIStorage, EIP712Upgradeable, Nonces {
		// 其他逻辑...
		
		// 若用户位于商家的白名单（以 Merkle tree 的形式构建）中，用户被成功验证位于白名单中则会触发此事件
		event validatedForCardClaimed(uint256 storedValue, string tokenURI, uint256 price, address user);
		
    error notFactory(address caller);		// 错误：调用者非工厂合约地址
    error invalidSignature(address derivedSigner, address validSigner);		// 错误：链下签名验证失败
    error expiredSignature(uint256 currendTimestamp, uint256 deadline);		// 错误：链下签名已过期
    error reachMaxSupply();							// 错误：会员套卡的当前总量已达到最大发行量
    error notCardOwner();								// 错误：调用者非会员卡的持有者
    error uninitialized();							// 错误：合约未被初始化（即克隆的合约实例未执行`init`函数）
    error externalApproveBanned();			// 错误：ERC721 合约的 approve 函数被禁用（即不可调用此函数）
    
    // 其他逻辑...
}
```



#### 1-4. 构造函数与初始化函数

```solidity
contract CardSeries is ERC721URIStorage, EIP712Upgradeable, Nonces {
		// 其他逻辑...
		
		// 仅实现合约（即逻辑合约或模板合约）在部署时可执行此函数，基于此合约克隆出来的实例均无法执行构造函数
		constructor() ERC721("XiJianChui", "XJC") {}
		
		// 通过最小代理部署的合约实例需在部署后立即执行此函数已完成合约的初始化
    function init(
        address _factoryAddr,
        uint256 _merchantId,
        string calldata _seriesName,
        string calldata _seriesSymbol,
        uint256 _maxSupply
    ) external initializer {
        factory = _factoryAddr;							// 初始化：工厂合约的地址
        merchantId = _merchantId;						// 初始化：当前会员套卡对应的商家ID（商家唯一标识符）
        cardName = _seriesName;							// 初始化：会员套卡的名称
        cardSymbol = _seriesSymbol;					// 初始化：会员套卡的标识
        maxSupply = _maxSupply;							// 初始化：会员套卡的最大发行量
        __EIP712_init(_seriesName, "1");		// 初始化：模拟父合约`EIP712Upgradeable`中的构造函数
    }
    
		// 其他逻辑...
}
```



#### 1-5. 函数修饰符

```solidity
contract CardSeries is ERC721URIStorage, EIP712Upgradeable, Nonces {
		// 其他逻辑...
		
		// 函数修饰符：仅工厂合约可调用
    modifier onlyFactory() {
        if (factory == address(0)) {					// 检查工厂合约的地址是否被初始化
            revert uninitialized();
        }
        if (msg.sender != factory) {					// 检查调用者是否为工厂合约
            revert notFactory(msg.sender);
        }
        _;
    }
        
		// 其他逻辑...
}
```



#### 1-6. 方法：铸造新会员卡（单张卡）

```solidity
contract CardSeries is ERC721URIStorage, EIP712Upgradeable, Nonces {
		// 其他逻辑...
		
	function mintCard(address _to, string memory _tokenURI, uint256 _value) external onlyFactory returns (uint256) {
        return _mintCard(_to, _tokenURI, _value);
    }
    
	function _mintCard(address _to, string memory _tokenURI, uint256 _value) internal returns (uint256) {
        if (currentSupply >= maxSupply) {							// 检查：会员套卡的当前总量是否达到最大发行量
            revert reachMaxSupply();
        }
        uint256 tokenId = _useNonce(address(this));		// 获取当前合约地址的 nonce 作为即将发行的会员卡的 tokenId
        _mint(_to, tokenId);													// 调用父合约 ERC721 中的内部函数执行会员卡的铸造
        _setTokenURI(tokenId, _tokenURI);							// 设定会员卡的存储信息（字符串）
        currentSupply++;															// 会员套卡的当前总量 + 1
        cardBalance[tokenId] = _value;								// 设定会员卡的储值
        _approve(factory, tokenId, _to);							// 为工厂合约授权（应一直保证会员卡对工厂合约的授权）
        return tokenId;
    }
        
		// 其他逻辑...
}
```



#### 1-7. 方法：基于 Merkle Root 对用户的 Merkle Proof 验证

```solidity
contract CardSeries is ERC721URIStorage, EIP712Upgradeable, Nonces {
		// 其他逻辑...
		
	function validateCardClaim(
        bytes32[] calldata _merkleProof,
        bytes32 _MerkleRoot,
        string calldata _tokenURI,
        uint256 _storedValue,
        uint256 _price
    ) external {
    		// 打包用户所输入的证明信息
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _storedValue, _tokenURI, _price));
        // 执行验证
        _verifyMerkleProof(_merkleProof, _MerkleRoot, leaf);
        emit validatedForCardClaimed(_storedValue, _tokenURI, _price, msg.sender);
    }
        
		// 其他逻辑...
}
```



（未完待续...）
