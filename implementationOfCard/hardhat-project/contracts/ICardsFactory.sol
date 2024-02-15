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
        uint256 storedValue,
        uint256 indexed price
    );

    /**
     * @dev Emitted when a card is listed for sale.
     */
    // event cardListed(uint256 indexed merchantId, uint256 indexed seriesId, uint256 indexed tokenId, uint256 price);

    /**
     * @dev Emitted when a card is delisted from the selling status.
     */
    // event cardDelisted(uint256 merchantId, uint256 seriesId, uint256 tokenId);

    /**
     * @dev Emitted when a member of a specific merchant withdraw the balance of the merchant by calling {merchantWithdraw}.
     */
    event merchantWithdrawal(uint256 merchantId, address withdrawer, uint256 withdrawnValue);

    /**
     * @dev Indicates a failure with `merchantId` and the function `caller`. Used to check if `caller` is the member of the merchant of `merchantId`.
     */
    error notMerchantOfGivenId(uint256 merchantId, address caller);

    /**
     * @dev Indicates a failure with `merchantId`, the amount of `withdrawal` and the current balance of the merchant `balance`. Used in withdrawal by a merchant member.
     */
    error insufficientBalance(uint256 merchantId, uint256 withdrawal, uint256 balance);

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

    // function list(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId, uint256 _price) external;

    // function delist(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) external;

    /**
     * @notice Mint a new card by the corresponding merchant.
     *
     * Emits a {cardMinted} event.
     *
     * @param _to the address of the recipient.
     * @param _tokenURI a custom string which is stored in the card
     * @param _storedValue the amount of the ERC20 token stored in the minted card.
     */
    function mintCard(uint256 _merchantId, uint256 _seriesId, address _to, string calldata _tokenURI, uint256 _storedValue, uint256 _price) external;

    /**
     * @notice Whitelist members can claim their cards by calling {cardClaim}.
     *
     * Emits a {cardMinted} event.
     *
     * @param _merkleProof the proof offered by the merchant with a given account(address)
     * @param _MerkleRoot the root of a merkle tree established by a merchant corresponding to the given `_merchantId`
     * @param _tokenURI a custom string which is stored in the card minted
     * @param _storedValue the amount of token stored in the card minted
     * @param _price the amount of token in exchange for the card minted
     */
    function cardClaim(uint256 _merchantId, uint256 _seriesId, bytes32[] calldata _merkleProof, bytes32 _MerkleRoot, string calldata _tokenURI, uint256 _storedValue, uint256 _price) external;

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
    function getCardBalance(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) external;

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
     * @notice Get the current price of the card listed for sale.
     */
    function getCardPrice(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) external view returns (uint256);

    /**
     * @notice Query the status of the card according to the given parameters.
     */
    function queryCardStatus(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) external view returns (bool);

}
