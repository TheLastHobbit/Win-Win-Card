# 合约接口与方法说明（供前端参考）

## A. 合约代码与说明

- **会员套卡合约 `CardSeries`**：实现单套会员卡的特性与功能，实际为 ERC-721 token 合约的超集，该合约被优先部署上链，以作为新的合约实例提供“模板”（即只有通过这个合约的**最小代理**所部署的合约实例才是合约套卡合约，而通过**常规部署**的合约仅作为模板本身，或者称为“实现合约”），该合约视为“会员卡标准”（类似 ERC20 标准、ERC721 标准等等），非业务合约，需要由`CardsFactory`进行调用。



- **工厂合约 `CardsFactory`**：该工厂合约通过最小代理部署新的 token 合约作为新的“会员套卡”，同时也是商家和用户的“客户端”合约，通过此合约可直接调用**`CardSeries`**合约中的方法，是**<u>通过前端直接调用的合约</u>**，即业务合约。由于合约编写代码的工作分为两个人完成，因此`CardsFactory`合约应与`CardMarket`合约合并（即同一个上下文，考虑采用继承的方式，直接用`CardMarket`作为前端调用的合约）。

--------

## B. `ICardFactory`接口

### 1. 完整代码

##### 以下为接口的完整代码，单个方法的说明详见 [C 章节](#C. 单方法的接口说明——商家方法) 与 [D 章节](#D. 单方法的接口说明——通用方法)。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICardsFactory {
    /**
     * @dev Emitted when an account(address) registers a new merchant.
     */
    event merchantRegistered(address account, uint256 merchantId);

    /**
     * @dev Emitted when a new member is adds to a specific `merchantId`.
     *
     * Note that `memberAddr` should not be address(0) or a merchant member that already exists.
     */
    event merchantMemberAdded(uint256 merchantId, address memberAddr);

    /**
     * @dev Emitted when a new member is removed from a specific `merchantId`.
     *
     * Note that `memberAddr` should be a merchant member that already exists.
     */
    event merchantMemberRemoved(uint256 merchantId, address memberAddr);

    /**
     * @dev Emitted when a new contract instance is deployed by calling {deployNewCardSeries}.
     */
    event cardSeriesDeployed(uint256 merchantId, uint256 seriesId, address instanceAddress);

    /**
     * @dev Emitted when a card of a specific `seriesId` of a merchant is minted.
     */
    event cardMinted(
        uint256 merchantId,
        uint256 seriesId,
        address indexed recipient,
        uint256 indexed tokenId,
        uint256 indexed storedValue
    );

    /**
     * @dev Emitted when a card is listed for sale.
     *
     * Event Deprecated: The functions which can emit this event are banned because listing and delisting will be realized off-chain.
     */
    // event cardListed(uint256 indexed merchantId, uint256 indexed seriesId, uint256 indexed tokenId, uint256 price);

    /**
     * @dev Emitted when a card is delisted from the selling status.
     *
     * Event Deprecated: The functions which can emit this event are banned because listing and delisting will be realized off-chain.
     */
    // event cardDelisted(uint256 merchantId, uint256 seriesId, uint256 tokenId);

    /**
     * @dev Emitted when a user withdraw its balance by calling {userWithdraw}.
     */
    event userWithdrawal(address user, uint256 withdrawnValue);

    /**
     * @dev Emitted when a member of a specific merchant withdraw the balance of the merchant by calling {merchantWithdraw}.
     */
    event merchantWithdrawal(uint256 merchantId, address withdrawer, uint256 withdrawnValue);

    /**
     * @dev Indicates a failure with `merchantId` and the function `caller`. Used to check if `caller` is the member of the merchant of `merchantId`.
     */
    error notMerchantOfGivenId(uint256 merchantId, address caller);

    /**
     * @dev Indicates a failure with `user`, the amount of `withdrawal` and the current balance of the merchant `balance`. Used in withdrawing from `userBalance` by a user.
     */
    error insufficientUserBalance(address user, uint256 withdrawal, uint256 balance);

    /**
     * @dev Indicates a failure with `merchantId`, the amount of `withdrawal` and the current balance of the merchant `balance`. Used in withdrawal by a merchant member.
     */
    error insufficientMerchantBalance(uint256 merchantId, uint256 withdrawal, uint256 balance);

    /**
     * @dev Indicates a failure with `merchantId` and `inputCardSeries`. Used to check if the input `inputCardSeries` matches a `seriesId` that already exists.
     */
    error nonexistentCardSeries(uint256 merchantId, uint256 inputCardSeries);

    /**
     * @dev Indicates a failure with `inputMerchantId`. Used to check if the input `inputMerchantId` matches a `merchantId` that already exists.
     */
    error nonexistentMerchant(uint256 inputMerchantId);

    /**
     * @dev Indicates a failure with `caller`, `merchantId`, `seriesId` and `tokenId`. Used in checking the ownership of a specific card.
     */
    error notCardOwner(address caller, uint256 merchantId, uint256 seriesId, uint256 tokenId);

    /**
     * @dev Indicates a failure with `inputAddr`. Used to check if the operated address is valid to be applied.
     */
    error inapplicableAddress(address inputAddr);

    /**
     * @dev Using the implementation contract to deploy its contract instance. Every instance is a unique series of membership cards.
     *
     * Emits a {cardSeriesDeployed} event.
     *
     * @param _merchantId a unique ID number to identify the corresponding merchant
     * @param _seriesName the name of the series of membership cards
     * @param _seriesSymbol the symbol of the series of membership cards
     * @param _maxSupply the max supply of the series of membership cards(if this maximum is reached, card cannot been minted any more)
     */
    function deployNewCardSeries(uint256 _merchantId, string memory _seriesName, string memory _seriesSymbol, uint256 _maxSupply) external;

    /**
     * @notice Users can list their card by calling {list} so that their card can be bought by other users.
     *
     * Emits a {cardListed} event.
     *
     * @dev Function Deprecated: The function for Listing cards is realized off-chain instead.
     */
    // function list(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId, uint256 _price) external;

    /**
     * @notice Users can delist their card from the status of selling by calling {delist}.
     *
     * Emits a {cardDelisted} event.
     *
     * @dev Function Deprecated: The function for delisting cards is realized off-chain instead.
     */
    // function delist(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) external;

    /**
     * @notice Mint a new card by the corresponding merchant.
     *
     * Emits a {cardMinted} event.
     *
     * Interface Deprecated: The visibility of this function is modified to `internal`.
     *
     * @param _to the address of the recipient.
     * @param _tokenURI a custom string which is stored in the card
     * @param _cardData a custom byte32 variable which indicate the properties of the card series
     * @param _storedValue the amount of the ERC20 token stored in the minted card.
     */
    // function _mintCard(uint256 _merchantId, uint256 _seriesId, address _to, string calldata _tokenURI, bytes32 _cardData, uint256 _storedValue) internal;

    /**
     * @notice Whitelist members claim their cards.
     *
     * Emits a {cardMinted} event.
     *
     * Interface Deprecated: The visibility of this function is modified to `internal`.
     *
     * @param _merkleProof the proof offered by the merchant with a given account(address)
     * @param _MerkleRoot the root of a merkle tree established by a merchant corresponding to the given `_merchantId`
     * @param _tokenURI a custom string which is stored in the card minted
     * @param _cardData a custom bytes32 variable which indicate the properties of the card series
     * @param _storedValue the amount of token stored in the card minted
     */
    // function _cardClaim(uint256 _merchantId, uint256 _seriesId, bytes32[] calldata _merkleProof, bytes32 _MerkleRoot, string calldata _tokenURI, bytes32 _cardData, uint256 _storedValue) internal;

    /**
     * @notice a user who has sold its card(s) in the secondary market can call {userWithdraw} to withdraw their token balance.
     *
     * Emits a {userWithdrawal} event.
     *
     * @param _amount the amount of tokens withdrawn from the private balance of `msg.sender`
     */
    function userWithdraw(uint256 _amount) external;

    /**
     * @notice a merchant can call {merchantWithdraw} to withdraw their token balance.
     *
     * Emits a {merchantWithdrawal} event.
     *
     * @param _amount the amount of tokens withdrawn by the merchant members 
     */
    function merchantWithdraw(uint256 _merchantId, uint256 _amount) external;

    /**
     * @notice This function will create a new merchant on this platform with a unique merchant ID(i.e.`merchantId`).
     * And every call of {merchantRegistration} by the same address will generate two unique merchant IDs separately.
     *
     * Emits a {merchantRegistered} event.
     *
     * @dev The state variable `merchantNumber` starts from 1. And it also figures out how many merchants have registered on this platform.
     */
    function merchantRegistration() external;

    /**
     * @notice This function is used to add a member to a merchant(identified by `merchantId`).
     * The caller must be the member of the merchantId, or the call will revert.
     *
     * Emits a {merchantMemberAdded} event.
     *
     * @param _account the address is assigned to the given `_merchantId`
     */
    function addMerchantMember(uint256 _merchantId, address _account) external;

    /**
     * @notice This function is used to remove a member to a merchant(identified by `merchantId`).
     * The caller must be the member of the merchantId, or the call will revert.
     *
     * Emits a {merchantMemberRemoved} event.
     *
     * @param _member the address is removed from the given `_merchantId`
     */
    function removeMerchantMember(uint256 _merchantId, address _member) external;

    /**
     * @notice Get the amount of tokens currently stored in the card according to the given parameters.
     */
    function getCardBalance(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) external view returns (uint256);

    /**
     * @dev Get the private balance of `msg.sender` in {CardFactory}.
     */
    function getUserBalance() external view returns (uint256);

    /**
     * @notice Get the amount of profit(count in tokens) of the given `merchantId` currently stored in its account.
     */
    function getMerchantBalance(uint256 _merchantId) external view returns (uint256);

    /**
     * @notice Check if the given `_account` is the member of the merchant of the given `_merchantId`.
     */
    function checkMembershipOfMerchantId(address _account, uint256 _merchantId) external view returns (bool);

    /**
     * @notice This function is used to get the current total amount of minted cards based on the given input `_merchantId` and `_seriesId`.
     * It's for the convenience of knowing if the current total amount of the specific membership cards has reached the `maxSupply`.
     */
    function getCurrentSupply(uint256 _merchantId, uint256 _seriesId) external view returns (uint256);

    /**
     * @notice This function is used to get the total amount of the registered merchants on the platform.
     */
    function getAmountOfMerchants() external view returns (uint256);

    /**
     * @notice Get the contract address of the card series based on the given `_merchantId` and `_seriesId`.
     */
    function getCardSeriesAddress(uint256 _merchantId, uint256 _seriesId) external view returns (address);

    /**
     * @dev Function Deprecated: This function is currently banned because listing and delisting will be realized off-chain.
     *
     * @notice Get the current price of the card listed for sale.
     */
    // function getCardPrice(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) external view returns (uint256);

    /**
     * @dev Function Deprecated: This function is currently banned because listing and delisting will be realized off-chain.
     * 
     * @notice Query the status of the card according to the given parameters.
     */
    // function queryCardStatus(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) external view returns (bool);
}
```



## C. 单方法的接口说明——商家方法

### 1. 商家方法：通过最小代理部署合约实例（发行新的会员套卡）

```solidity
		/**
		 * @dev 商家基于`CardSeries`合约的逻辑通过最小代理部署合约实例（即发行新的会员套卡）
		 *
		 * @param _merchantId: 商家ID（商家唯一标识符）
		 * @param _seriesName: 会员套卡名称
		 * @param _seriesSymbol: 会员套卡标识
		 * @param _maxSupply：会员套卡的发行量上限
		 */
		function deployNewCardSeries(uint256 _merchantId, string memory _seriesName, string memory _seriesSymbol, uint256 _maxSupply) external;
```



### 2. [ *废弃方法：改为内部函数，转由`cardMarket`合约实现该功能* ] 商家方法：铸造新的单张会员卡

```solidity
		/**
		 * @dev 商家铸造新的单张会员卡
		 *
		 * @param _merchantId: 商家ID（商家唯一标识符）
		 * @param _seriesId：会员套卡ID（会员套卡唯一标识符）
		 * @param _to：接收会员卡的用户（即铸造给谁）
		 * @param _tokenURI：会员卡存储的自定义字符串（即 NFT的 IPFS 链接，作为会员卡的卡面）
		 * @param _storedValue：铸造时存储的金额（由商家根据业务需要自行确定）
		 * @param _price: 用户为新铸造的会员卡所需的付款（由商家根据业务需要自行确定）
		 */
		// function _mintCard(uint256 _merchantId, uint256 _seriesId, address _to, string calldata _tokenURI, bytes32 _cardData, uint256 _storedValue) internal;
```



### 3. 商家方法：商家从 Dapp 中提取商家账户的金额（ERC20 token）

```solidity
		/**
		 * @dev 商家提取在 Dapp 中的金额。
		 *
		 * @param _merchantId: 商家ID（商家唯一标识符）
		 * @param _amount: 商家成员从 Dapp 商家账户中提取的金额
		 */
		function merchantWithdraw(uint256 _merchantId, uint256 _amount) external;
```



### 4. 商家方法：商家新增成员

```solidity
		/**
		 * @dev 商家新增成员。
		 * 
		 * @param _merchantId: 商家ID（商家唯一标识符）
		 * @param _account: 要加入商家的账户地址
		 */
		function addMerchantMember(uint256 _merchantId, address _account) external;
```



### 5. 商家方法：商家移除成员

```solidity
		/**
		 * @dev 商家移除成员。
		 *
		 * @param _merchantId: 商家ID（商家唯一标识符）
		 * @param _member: 要移除的商家成员的地址
		 */
		function removeMerchantMember(uint256 _merchantId, address _member) external;
```



### 6. 商家方法（只读）：获取商家在 Dapp 中的余额（ERC20 token）

```solidity
		/**
		 * @dev 商家获取自己在 Dapp 中商家账户的余额。
		 *
		 * @param _merchantId: 商家ID（商家唯一标识符）
		 *
		 * @return 商家账户的余额
		 */
		function getMerchantBalance(uint256 _merchantId) external view returns (uint256);
```



## D. 单方法的接口说明——通用方法

**通用方法**是**用户**可用的方法，这里的“**用户**”不仅包含了普通用户（非任何商家成员），也包含了商家成员地址作为会员卡使用者时的身份（就是商家也可以使用会员卡的功能）。

### 1. 通用方法：用户注册新商家（并成为商家成员）

```solidity
		/**
		 * @dev 用户注册新商家（并成为商家成员）。
		 */
		function merchantRegistration() external;
```



### 2. [ *废弃方法：改为内部函数，转由`cardMarket`合约实现该功能* ]  通用方法：白名单用户领取会员卡

```solidity
		/**
		 * @dev 若商家采用 Merkle Tree 构建用户白名单并开放用户领取会员卡，则用户可以调用该方法获取对应的会员卡
		 *
		 * @param _merchantId: 商家ID（商家唯一标识符）
		 * @param _seriesId: 会员套卡ID（会员套卡唯一标识符）
		 * @param _merkleProof: 调用者对应的 Merkle Proof（通过商家的后端返回）
		 * @param _MerkleRoot: Merkle Root（由商家提供该值）
		 * @param _tokenURI: 会员卡存储的自定义字符串（即 NFT的 IPFS 链接，作为会员卡的卡面，是 merkle tree 该用户节点的信息之一）
		 * @param _storedValue: 铸造时存储的金额（是 merkle tree 该用户节点的信息之一）
		 * @param _price: 领取会员卡相应支付的价格（买卡所需付给卖家的 token 数额，是 merkle tree 该用户节点的信息之一）
		 */
		    // function _cardClaim(uint256 _merchantId, uint256 _seriesId, bytes32[] calldata _merkleProof, bytes32 _MerkleRoot, string calldata _tokenURI, bytes32 _cardData, uint256 _storedValue) internal;
```



### 3. 通用方法：用户从 Dapp 中提取个人账户的金额（ERC20 token）

```solidity
		/**
		 * @dev 商家提取在 Dapp 中的金额。
		 *
		 * @param _amount: 用户从 Dapp 个人账户中提取的金额
		 */
		function userWithdraw(uint256 _amount) external;
```



### 4. 通用方法（只读）：获取单张会员卡内的余额

```solidity
		/**
		 * @dev 获取单张会员卡内的余额。
		 *
		 * @param _merchantId: 商家ID（商家唯一标识符）
		 * @param _seriesId: 会员套卡ID（会员套卡唯一标识符）
		 * @param _tokenId: 单张会员卡的 tokenId
		 *
		 * @return 单张会员卡内的余额
		 */
		function getCardBalance(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) external view returns (uint256);
```



### 5. 通用方法（只读）：获取用户在 Dapp 中个人账户的余额（ERC20 token）

```solidity
		/**
		 * @dev 获取调用者在 Dapp 中个人账户的余额（通常为二手市场转手会员卡所获得的回报）。
		 *
		 * @return 调用者个人账户的余额
		 */
    function getUserBalance() external view returns (uint256);
```



### 6. 通用方法（只读）：检查某地址是否为某一商家的成员

```solidity
		/**
		 * @dev 检查某地址是否为某一商家的成员。
		 *
		 * @param _account: 待被检查的账户地址
		 * @param _merchantId: 商家ID（商家唯一标识符）
		 *
		 * @return 检查结果（若账户是商家的成员则返回 true；否则 false）
		 */
		function checkMembershipOfMerchantId(address _account, uint256 _merchantId) external view returns (bool);
```



### 7. 通用方法（只读）：获取某一合约套卡的当前总量

```solidity
		/**
		 * @dev 获取某一合约套卡的当前总量。
		 *
		 * @param _merchantId: 商家ID（商家唯一标识符）
		 * @param _seriesId: 会员套卡ID（会员套卡唯一标识符）
		 *
		 * @return 会员套卡的当前总量
		 */
		function getCurrentSupply(uint256 _merchantId, uint256 _seriesId) external view returns (uint256);
```



### 8. 通用方法（只读）：获取商家总数（即商家ID当前最大值）

```solidity
		/**
		 * @dev 获取商家总数（即商家ID当前最大值）
		 *
		 * @return 商家总数（即商家ID当前最大值）
		 */
		function getAmountOfMerchants() external view returns (uint256);
```



### 9. 通用方法（只读）：获取会员套卡的合约地址

```solidity
		/**
		 * @dev 获取会员套卡的合约地址
		 *
		 * @return 会员套卡的合约地址
		 */
		function getCardSeriesAddress(uint256 _merchantId, uint256 _seriesId) external view returns (address);
```
