// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ICardSeries.sol";
import "./ICardsFactory.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title This is a factory contract that clones the implementation contracts of membership cards.
 *
 * @dev Implementation of the {ICardsFactory} interface.
 */

contract CardsFactory is ICardsFactory, Ownable, ReentrancyGuard {
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
    mapping(address user => uint256 privateBalance) private userBalance;
    mapping(uint256 merchantId => uint256 earnedValue) private merchantBalance;
    mapping(address user => uint256 AVAXBalance) internal AVAXDeposited;
    mapping(address account => uint256 merchantId) internal latestMerchantId;
    // State Variable Deprecated: The function related to this variable has been banned because listing and delisting has been realized off-chain instead.
    // mapping(uint256 merchantId => mapping(uint256 _seriesId => mapping(uint256 _tokenId => uint256 cardPrice))) public price;

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
        address cardOwner = IERC721(contractAddr).ownerOf(tokenId);
        if (msg.sender != cardOwner) {
            revert notCardOwner(msg.sender, merchantId, seriesId, tokenId);
        }
        _;
    }

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
        ICardSeries(clonedImpleInstance).init(
            address(this), _merchantId, _seriesId, _seriesName, _seriesSymbol, _maxSupply
        );
        emit cardSeriesDeployed(_merchantId, _seriesId, clonedImpleInstance);
    }

    /**
     * @notice Users can list their card by calling {list} so that their card can be bought by other users.
     *
     * Emits a {cardListed} event.
     *
     * @dev Function Deprecated: The function for Listing cards is realized off-chain instead.
     */
    // function list(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId, uint256 _price) public onlyCardOwner(_merchantId, _seriesId, _tokenId) {
    //     _checkCardSeries(_merchantId, _seriesId);
    //     address contractAddress = getCardSeriesAddress(_merchantId, _seriesId);
    //     price[_merchantId][_seriesId][_tokenId] = _price;
    //     emit cardListed(_merchantId, _seriesId, _tokenId, _price);
    // }

    /**
     * @notice Users can delist their card from the status of selling by calling {delist}.
     *
     * Emits a {cardDelisted} event.
     *
     * @dev Function Deprecated: The function for Listing cards is realized off-chain instead.
     */
    // function delist(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) public onlyCardOwner(_merchantId, _seriesId, _tokenId) {
    //     _checkCardSeries(_merchantId, _seriesId);
    //     address contractAddress = getCardSeriesAddress(_merchantId, _seriesId);
    //     delete price[_merchantId][_seriesId][_tokenId];
    //     emit cardDelisted(_merchantId, _seriesId, _tokenId);
    // }

    /**
     * @dev when user deposits AVAX to this contract directly without calling any functions, {receive} will be called.
     *
     * Emit a {depositedAVAX} event.
     */
    receive() external payable {
        AVAXDeposited[msg.sender] += msg.value;
        emit depositedAVAX(msg.sender, msg.value);
    }

    /**
     * @notice User deposits AVAX to this contract.
     *
     * Emit a {depositedAVAX} event.
     */
    function depositAVAX() public payable {
        AVAXDeposited[msg.sender] += msg.value;
        emit depositedAVAX(msg.sender, msg.value);
    }

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
    function mintCard(
        uint256 _merchantId,
        uint256 _seriesId,
        address payable _to,
        string calldata _tokenURI,
        uint256 _price,
        uint256 _deadline,
        bytes memory _signature
    ) external onlyMerchant(_merchantId) nonReentrant payable {
        _checkCardSeries(_merchantId, _seriesId);
        address contractAddress = getCardSeriesAddress(_merchantId, _seriesId);
        bytes32 hash = ICardSeries(contractAddress).permitForMint_buildHash(_to, _merchantId, _seriesId, _price, _deadline);
        ICardSeries(contractAddress).permitForMint_validateSig(_to, hash, _signature);
        _handleAVAXTransfer_MintCard(_merchantId, _to, _price);
        uint256 tokenId = ICardSeries(contractAddress).mintCard(_to, _tokenURI);
        emit cardMinted(_merchantId, _seriesId, _to, tokenId);
    }

    /**
     * @notice Whitelist members claim their cards.
     *
     * Emits a {cardMinted} event.
     *
     * @param _merkleProof the proof offered by the merchant with a given account(address)
     * @param _MerkleRoot the root of a merkle tree established by a merchant corresponding to the given `_merchantId`
     * @param _tokenURI a custom string which is stored in the card minted
     */
    // function cardClaim(
    //     uint256 _merchantId,
    //     uint256 _seriesId,
    //     bytes32[] calldata _merkleProof,
    //     bytes32 _MerkleRoot,
    //     string calldata _tokenURI,
    //     uint256 _price
    // ) external {
    //     _checkCardSeries(_merchantId, _seriesId);
    //     address contractAddress = getCardSeriesAddress(_merchantId, _seriesId);
    //     ICardSeries(contractAddress).validateCardClaim(_merkleProof, _MerkleRoot, _tokenURI);
    //     uint256 tokenId = ICardSeries(contractAddress).mintCard(msg.sender, _tokenURI);
    //     IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), _price);
    //     merchantBalance[_merchantId] += _price;
    //     emit cardMinted(_merchantId, _seriesId, msg.sender, tokenId);   
    // }

    /**
     * @notice a user who has sold its card(s) in the secondary market can call {userWithdraw} to withdraw their token balance.
     *
     * Emits a {userWithdrawal} event.
     *
     * @param _amount the amount of tokens withdrawn from the private balance of `msg.sender`
     */
    function userWithdraw(uint256 _amount) public {
        if (_amount > getUserBalance()) {
            revert insufficientUserBalance(msg.sender, _amount, getUserBalance());
        }
        bool _success = IERC20(tokenAddress).transfer(msg.sender, _amount);
        require(_success, "private withdrawal failed");
        userBalance[msg.sender] -= _amount;
        emit userWithdrawal(msg.sender, _amount);
    }

    /**
     * @notice a merchant can call {merchantWithdraw} to withdraw their token balance.
     *
     * Emits a {merchantWithdrawal} event.
     *
     * @param _amount the amount of tokens withdrawn by the merchant members
     */
    function merchantWithdraw(uint256 _merchantId, uint256 _amount) public onlyMerchant(_merchantId) {
        if (_amount > getMerchantBalance(_merchantId)) {
            revert insufficientMerchantBalance(_merchantId, _amount, getMerchantBalance(_merchantId));
        }
        bool _success = IERC20(tokenAddress).transfer(msg.sender, _amount);
        require(_success, "merchant withdrawal failed");
        merchantBalance[_merchantId] -= _amount;
        emit merchantWithdrawal(_merchantId, msg.sender, _amount);
    }

    /**
     * @notice This function will create a new merchant on this platform with a unique merchant ID(i.e.`merchantId`).
     * And every call of {merchantRegistration} by the same address will generate two unique merchant IDs separately.
     *
     * Emits a {merchantRegistered} event.
     *
     * @dev The state variable `merchantNumber` starts from 1. And it also figures out how many merchants have registered on this platform.
     */
    function merchantRegistration() public {
        uint256 newMerchantId = ++merchantNumber;
        merchantMembership[msg.sender][newMerchantId] = true;
        latestMerchantId[msg.sender] = newMerchantId;
        emit merchantRegistered(msg.sender, merchantNumber);
    }

    /**
     * @notice This function is used to add a member to a merchant(identified by `merchantId`).
     * The caller must be the member of the merchantId, or the call will revert.
     *
     * Emits a {merchantMemberAdded} event.
     *
     * @param _account the address is assigned to the given `_merchantId`
     */
    function addMerchantMember(uint256 _merchantId, address _account) public onlyMerchant(_merchantId) {
        bool isMerchantMember = merchantMembership[_account][_merchantId];
        if (_account == address(0) || isMerchantMember) {
            revert inapplicableAddress(_account);
        }
        merchantMembership[_account][_merchantId] = true;
        emit merchantMemberAdded(_merchantId, _account);
    }

    /**
     * @notice This function is used to remove a member to a merchant(identified by `merchantId`).
     * The caller must be the member of the merchantId, or the call will revert.
     *
     * Emits a {merchantMemberRemoved} event.
     *
     * @param _member the address is removed from the given `_merchantId`
     */
    function removeMerchantMember(uint256 _merchantId, address _member) public onlyMerchant(_merchantId) {
        bool isMerchantMember = merchantMembership[_member][_merchantId];
        if (!isMerchantMember) {
            revert inapplicableAddress(_member);
        }
        merchantMembership[_member][_merchantId] = false;
        emit merchantMemberRemoved(_merchantId, _member);
    }
    
    function _handleAVAXTransfer_MintCard(uint256 _merchantId, address payable _to, uint256 _price) internal {
        require(AVAXDeposited[_to] >= _price, "Insufficient AVAX balance");
        (bool success, ) = msg.sender.call{value: _price}("");
        require(success, "Fail to transfer AVAX");
        AVAXDeposited[_to] -= _price;
        merchantBalance[_merchantId] += _price;
    }

    /**
     * @dev This function returns the series ID of the given `_merchantId` and increases by 1 after this function execution is completed.
     */
    function _useSeriesId(uint256 _merchantId) internal returns (uint256) {
        return seriesIdOfMerchantId[_merchantId]++;
    }

    /**
     * @dev This function is used to check the existence of the card series and the merchant based on the given parameters.
     */
    function _checkCardSeries(uint256 _merchantId, uint256 _seriesId) internal view {
        _checkMerchantExistence(_merchantId);
        address contractAddr = seriesInfo[_merchantId][_seriesId].contractAddr;
        if (contractAddr == address(0)) {
            revert nonexistentCardSeries(_merchantId, _seriesId);
        }
    }

    /**
     * @dev This function is used to check the existence of the merchant based on the given `_merchantId`.
     */
    function _checkMerchantExistence(uint256 _merchantId) internal view {
        if (_merchantId > merchantNumber) {
            revert nonexistentMerchant(_merchantId);
        }
    }

    /**
     * @dev Get the amount of tokens currently stored in the card according to the given parameters.
     */
    function getCardBalance(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) public view returns (uint256) {
        _checkCardSeries(_merchantId, _seriesId);
        address contractAddress = getCardSeriesAddress(_merchantId, _seriesId);
        return ICardSeries(contractAddress).getCardBalance(_tokenId);
    }

    /**
     * @dev Get the private balance of `msg.sender` in {CardFactory}.
     */
    function getUserBalance() public view returns (uint256) {
        return userBalance[msg.sender];
    }

    /**
     * @dev Get the amount of profit(count in tokens) of the given `merchantId` currently stored in its account.
     */
    function getMerchantBalance(uint256 _merchantId) public view onlyMerchant(_merchantId) returns (uint256) {
        _checkMerchantExistence(_merchantId);
        return merchantBalance[_merchantId];
    }

    function checkMembershipOfMerchantId(address _account, uint256 _merchantId) external view returns (bool) {
        _checkMerchantExistence(_merchantId);
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
        return ICardSeries(contractAddress).getCurrentSupply();
    }

    /**
     * @notice This function is used to get the total amount of the registered merchants on the platform.
     */
    function getAmountOfMerchants() public view returns (uint256) {
        return merchantNumber;
    }

    /**
     * @notice Get the contract address of the card series based on the given `_merchantId` and `_seriesId`.
     */
    function getCardSeriesAddress(uint256 _merchantId, uint256 _seriesId) public view returns (address) {
        address contractAddress = seriesInfo[_merchantId][_seriesId].contractAddr;
        return contractAddress;
    }

    /**
     * @notice Get the deposited amount of AVAX in this contract.
     */
    function getAVAXDeposited(address _user) public view returns (uint256) {
        return AVAXDeposited[_user];
    }

    /**
     * @notice Check if `_account` is a member of a merchant.
     */
    function checkIfRegisteredMerchant(address _account) public view returns (bool) {
        bool isAMerchant = latestMerchantId[_account] != 0 ? true : false;
        return isAMerchant;
    }

    /**
     * @dev Function Deprecated: This function is currently banned because listing and delisting will be realized off-chain.
     *
     * @notice Get the current price of the card listed for sale.
     */
    // function getCardPrice(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) public view returns (uint256) {
    //     _checkCardSeries(_merchantId, _seriesId);
    //     return price[_merchantId][_seriesId][_tokenId];
    // }

    /**
     * @dev Function Deprecated: This function is currently banned because listing and delisting will be realized off-chain.
     * 
     * @notice Query the status of the card according to the given parameters.
     */
    // function queryCardStatus(uint256 _merchantId, uint256 _seriesId, uint256 _tokenId) public view returns (bool) {
    //     _checkCardSeries(_merchantId, _seriesId);
    //     bool isListed = price[_merchantId][_seriesId][_tokenId] != 0 ? true : false;
    //     return isListed;
    // }
}
