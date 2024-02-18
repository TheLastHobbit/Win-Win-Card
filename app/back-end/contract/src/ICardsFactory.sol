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
        uint256 indexed merchantId,
        uint256 seriesId,
        address indexed recipient,
        uint256 indexed tokenId
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
     * @dev Emited when a user deposits AVAX.
     */
    event AVAXDeposited(address user, uint256 value);

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
     * @param _to the address of the recipient which should pay AVAX for the minted card
     * @param _tokenURI a custom string which is stored in the card
     * @param _price the value of AVAX in exchange for the minted card
     * @param _deadline the timestamp of the expiration of the off-chain signed message
     * @param _signature the signed message containing merchantId, seriesId and price
     */
    function mintCard(uint256 _merchantId, uint256 _seriesId, address payable _to, string calldata _tokenURI, uint256 _price, uint256 _deadline, bytes memory _signature) external payable;

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
     * @notice Get the deposited amount of AVAX in this contract.
     */
    function getAVAXDeposited(address _user) external view returns (uint256);

    /**
     * @notice Check if `_account` is a member of a merchant.
     */
    function checkIfRegisteredMerchant(address _account) external view returns (bool);

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
