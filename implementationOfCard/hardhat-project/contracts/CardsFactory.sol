// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./CardSeries.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title This is a factory contract that clones the implementation contracts of membership cards.
 */
contract CardsFactory is Ownable {
    using Clones for address;
    using SafeERC20 for IERC20;

    // This is the address of the implementation contract of the membership cards.
    address public immutable implementationAddress;
    // The address of ERC20 token which is used for buying cards.
    address public immutable tokenAddress;

    struct SeriesStruct {
        uint256 merchantId;
        uint256 seriesId;
        string name;
        string symbol;
        uint256 maxSupply;
        address contractAddr;
    }

    uint256 internal merchantNumber;
    mapping(uint256 merchantId => uint256 nonce) internal seriesIdOfMerchantId;
    mapping(address account => mapping(uint256 merchantId => bool isMerchant)) public merchantMembership;
    mapping(uint256 merchantId => mapping(uint256 seriesId => SeriesStruct)) public seriesInfo;
    mapping(uint256 merchantId => mapping(uint256 _seriesId => mapping(uint256 _tokenId => uint256 cardPrice))) public
        price;
    mapping(uint256 merchantId => uint256 earnedValue) merchantBalance;

    event merchantRegistered(address account, uint256 merchantId);
    event merchantMemberAdded(uint256 merchantId, address memberAddr);
    event merchantMemberRemoved(uint256 merchantId, address memberAddr);
    event cardSeriesDeployed(uint256 merchantId, uint256 seriesId, address instanceAddress);
    event cardMinted(
        uint256 merchantId,
        uint256 seriesId,
        address indexed recipient,
        uint256 indexed tokenId,
        uint256 storedValue,
        uint256 indexed price
    );
    event cardListed(uint256 indexed merchantId, uint256 indexed seriesId, uint256 indexed tokenId, uint256 price);
    event cardDelisted(uint256 merchantId, uint256 seriesId, uint256 tokenId);
    event merchantWithdrawal(uint256 merchantId, address withdrawer, uint256 withdrawnValue);

    error notMerchantOfGivenId(uint256 merchantId, address caller);
    error insufficientBalance(uint256 merchantId, uint256 withdrawal, uint256 balance);
    error nonexistentCardSeries(uint256 merchantId, uint256 inputCardSeries);
    error notCardOwner(address caller, uint256 merchantId, uint256 seriesId, uint256 tokenId);

    constructor(address _imple, address _tokenAddr) Ownable(msg.sender) {
        implementationAddress = _imple;
        tokenAddress = _tokenAddr;
    }

    modifier onlyMerchant(uint256 merchantId) {
        bool isMerchantIdmatched = merchantMembership[msg.sender][merchantId];
        if (!isMerchantIdmatched) {
            revert notMerchantOfGivenId(merchantId, msg.sender);
        }
        _;
    }

    modifier onlyCardOwner(uint256 merchantId, uint256 seriesId, uint256 tokenId) {
        address contractAddr = getCardSeriesAddress(merchantId, seriesId);
        address cardOwner = CardSeries(contractAddr).ownerOf(tokenId);
        if (msg.sender != cardOwner) {
            revert notCardOwner(msg.sender, merchantId, seriesId, tokenId);
        }
        _;
    }

    /**
     * @dev Using the implementation contract to deploy its contract instance. Every instance is a unique series of membership cards.
     *
     * @param _seriesName the name of the series of membership cards
     * @param _seriesSymbol the symbol of the series of membership cards
     * @param _maxSupply the max supply of the series of membership cards(if this maximum is reached, card cannot been minted any more)
     */
    function deployNewCardSeries(
        uint256 _merchantId,
        string memory _seriesName,
        string memory _seriesSymbol,
        uint256 _maxSupply
    ) public onlyMerchant(_merchantId) {
        uint256 _seriesId = _useSeriesId(_merchantId);
        address clonedImpleInstance = implementationAddress.clone();
        SeriesStruct memory deployedSeriesInfo = SeriesStruct({
            merchantId: _merchantId,
            seriesId: _seriesId,
            name: _seriesName,
            symbol: _seriesSymbol,
            maxSupply: _maxSupply,
            contractAddr: clonedImpleInstance
        });
        seriesInfo[_merchantId][_seriesId] = deployedSeriesInfo;
        CardSeries(clonedImpleInstance).init(address(this), _merchantId, _seriesName, _seriesSymbol, _maxSupply);
        emit cardSeriesDeployed(_merchantId, _seriesId, clonedImpleInstance);
    }

    /**
     * @notice The owner of a specific card(specified by `_merchantId`, `_seriesId` and `_tokenId`) can call {list} to make the card available for sale.
     */
    function list(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId, uint256 _price) public onlyCardOwner(_merchantId, _seriesId, _tokenId) {
        _checkCardSeries(_merchantId, _seriesId);
        address contractAddress = getCardSeriesAddress(_merchantId, _seriesId);
        price[_merchantId][_seriesId][_tokenId] = _price;
        emit cardListed(_merchantId, _seriesId, _tokenId, _price);
    }

    /**
     * @notice When a card is on sale, the authorized address of the card can call {delist} to stop selling.
     */
    function delist(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) public onlyCardOwner(_merchantId, _seriesId, _tokenId) {
        _checkCardSeries(_merchantId, _seriesId);
        address contractAddress = getCardSeriesAddress(_merchantId, _seriesId);
        delete price[_merchantId][_seriesId][_tokenId];
        emit cardDelisted(_merchantId, _seriesId, _tokenId);
    }

    /**
     * @notice Mint a new card by the corresponding merchant.
     *
     * @param _to the address of the recipient.
     * @param _tokenURI a custom string which is stored in the card
     * @param _storedValue the amount of the ERC20 token stored in the minted card.
     */
    function mintCard(
        uint256 _merchantId,
        uint256 _seriesId,
        address _to,
        string memory _tokenURI,
        uint256 _storedValue,
        uint256 _price
    ) public onlyMerchant(_merchantId) {
        _checkCardSeries(_merchantId, _seriesId);
        address contractAddress = getCardSeriesAddress(_merchantId, _seriesId);
        uint256 tokenId = CardSeries(contractAddress).mintCard(_to, _tokenURI, _storedValue);
        IERC20(tokenAddress).safeTransferFrom(_to, address(this), _price);
        merchantBalance[_merchantId] += _price;
        emit cardMinted(_merchantId, _seriesId, _to, tokenId, _storedValue, _price);
    }

    function cardClaim(
        uint256 _merchantId,
        uint256 _seriesId,
        bytes32[] calldata _merkleProof,
        bytes32 _MerkleRoot,
        string memory _tokenURI,
        uint256 _storedValue,
        uint256 _price
    ) external {
        _checkCardSeries(_merchantId, _seriesId);
        address contractAddress = getCardSeriesAddress(_merchantId, _seriesId);
        CardSeries(contractAddress).validateCardClaim(_merkleProof, _MerkleRoot, _tokenURI, _storedValue, _price);
        uint256 tokenId = CardSeries(contractAddress).mintCard(msg.sender, _tokenURI, _storedValue);
        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), _price);
        merchantBalance[_merchantId] += _price;
        emit cardMinted(_merchantId, _seriesId, msg.sender, tokenId, _storedValue, _price);
    }

    function merchantWithdraw(uint256 _merchantId, uint256 _amount) public onlyMerchant(_merchantId) {
        if (_amount > getMerchantBalance(_merchantId)) {
            revert insufficientBalance(_merchantId, _amount, getMerchantBalance(_merchantId));
        }
        bool _success = IERC20(tokenAddress).transfer(msg.sender, _amount);
        require(_success, "withdrawal failed");
        merchantBalance[_merchantId] -= _amount;
        emit merchantWithdrawal(_merchantId, msg.sender, _amount);
    }

    /**
     * @notice This function will create a new merchant on this platform with a unique merchant ID(i.e.`merchantId`).
     * And every call of {merchantRegistration} by the same address will generate two unique merchant IDs separately.
     *
     * @dev The state variable `merchantNumber` starts from 1. And it also figures out how many merchants have registered on this platform.
     */
    function merchantRegistration() public {
        uint256 newMerchantId = ++merchantNumber;
        merchantMembership[msg.sender][newMerchantId] = true;
        emit merchantRegistered(msg.sender, merchantNumber);
    }

    /**
     * @notice This function is used to add a member to a merchant(identified by `merchantId`).
     * The caller must be the member of the merchantId, or the call will revert.
     */
    function addMerchantMember(uint256 _merchantId, address _member) public onlyMerchant(_merchantId) {
        merchantMembership[_member][_merchantId] = true;
        emit merchantMemberAdded(_merchantId, _member);
    }

    /**
     * @notice This function is used to remove a member to a merchant(identified by `merchantId`).
     * The caller must be the member of the merchantId, or the call will revert.
     */
    function removeMerchantMember(uint256 _merchantId, address _member) public onlyMerchant(_merchantId) {
        merchantMembership[_member][_merchantId] = false;
        emit merchantMemberRemoved(_merchantId, _member);
    }

    /**
     * @dev This function returns the series ID of the given `_merchantId` and increases by 1 after this function execution is completed.
     */
    function _useSeriesId(uint256 _merchantId) internal returns (uint256) {
        return seriesIdOfMerchantId[_merchantId]++;
    }

    function _checkCardSeries(uint256 _merchantId, uint256 _seriesId) internal view {
        address contractAddr = seriesInfo[_merchantId][_seriesId].contractAddr;
        if (contractAddr == address(0)) {
            revert nonexistentCardSeries(_merchantId, _seriesId);
        }
    }

    function getCardBalance(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) public view returns (uint256) {
        _checkCardSeries(_merchantId, _seriesId);
        address contractAddress = getCardSeriesAddress(_merchantId, _seriesId);
        return CardSeries(contractAddress).getCardBalance(_tokenId);
    }

    function getMerchantBalance(uint256 _merchantId) public view onlyMerchant(_merchantId) returns (uint256) {
        return merchantBalance[_merchantId];
    }

    function checkMembershipOfMerchantId(address _account, uint256 _merchantId) external view returns (bool) {
        bool isMerchantMember = merchantMembership[_account][_merchantId];
        return (isMerchantMember);
    }

    /**
     * @notice This function is used to get the current total amount of minted cards based on the given input `_merchantId` and `_seriesId`.
     * It's for the convenience of knowing if the current total amount of the specific membership cards has reached the `maxSupply`.
     */
    function getCurrentSupply(uint256 _merchantId, uint256 _seriesId) public view returns (uint256) {
        _checkCardSeries(_merchantId, _seriesId);
        address contractAddress = getCardSeriesAddress(_merchantId, _seriesId);
        return CardSeries(contractAddress).getCurrentSupply();
    }

    /**
     * @notice This function is used to get the total amount of the registered merchants on the platform.
     */
    function getAmountOfMerchants() public view returns (uint256) {
        return merchantNumber;
    }

    function getCardSeriesAddress(uint256 _merchantId, uint256 _seriesId) public view returns (address) {
        _checkCardSeries(_merchantId, _seriesId);
        address contractAddress = seriesInfo[_merchantId][_seriesId].contractAddr;
        return contractAddress;
    }

    function getCardPrice(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) public view returns (uint256) {
        _checkCardSeries(_merchantId, _seriesId);
        return price[_merchantId][_seriesId][_tokenId];
    }

    function queryCardStatus(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) public view returns (bool) {
        _checkCardSeries(_merchantId, _seriesId);
        bool isListed = price[_merchantId][_seriesId][_tokenId] != 0 ? true : false;
        return isListed;
    }
}
