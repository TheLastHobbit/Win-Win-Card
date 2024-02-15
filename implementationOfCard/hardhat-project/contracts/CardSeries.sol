//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./ICardSeries.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title The implementation contract which realizes the basic logic of membership cards.
 *
 * @dev Implementation of the {ICardSeries} interface.
 */
contract CardSeries is ICardSeries, ERC721URIStorage, EIP712Upgradeable, Nonces {
    address public factory;
    uint256 private merchantId;
    uint256 private seriesId;
    string private cardName;
    string private cardSymbol;
    uint256 private currentSupply;
    uint256 public maxSupply;
    mapping(uint256 tokenId => uint256 tokenValue) public cardBalance;

    constructor() ERC721("XiJianChui", "XJC") {}

    /**
     * @dev Because the constructor does not work when this contract is deployed via minimal proxy, this function will initialize 
     * the state variables of itself and its parent contract(s).
     *
     * Note that {init} should only be called once at the moment of the deployment of this contract.
     */
    function init(
        address _factoryAddr,
        uint256 _merchantId,
        uint256 _seriesId,
        string calldata _seriesName,
        string calldata _seriesSymbol,
        uint256 _maxSupply
    ) external initializer {
        factory = _factoryAddr;
        merchantId = _merchantId;
        seriesId = _seriesId;
        cardName = _seriesName;
        cardSymbol = _seriesSymbol;
        maxSupply = _maxSupply;
        __EIP712_init(_seriesName, "1");
    }

    /**
     * @dev Check if the existence of the non-address(0) value of `factory` and if the caller equals `factory`.
     */
    modifier onlyFactory() {
        if (factory == address(0)) {
            revert uninitialized();
        }
        if (msg.sender != factory) {
            revert notFactory(msg.sender);
        }
        _;
    }

    /**
     * @notice Merchant mints a new card to `_to` with an originally stored value(count in token).
     *
     * @return tokenId a unique ID of the card minted directly returned by internal function {_mintCard}.
     *
     * Note `tokenId` starts from 0 and ends at `maxSupply`.
     */
    function mintCard(address _to, string memory _tokenURI, uint256 _value) external onlyFactory returns (uint256) {
        return _mintCard(_to, _tokenURI, _value);
    }

    /**
     * @notice To meet the demand of distributing cards to multiple users, the merchant can make a whitelist containing the member addresses and stored values inside the card.
     * Users who are in the whitelist can call {validateCardClaim} to get their cards.
     * The membership of the whitelist should be in the form of a Merkle tree.
     *
     * @param _MerkleProof a dynamic array which contains Merkle proof is used for validating the membership of the caller. This should be offered by the project party
     * @param _MerkleRoot the root of the Merkle tree of the whitelist
     * @param _tokenURI a custom string which is stored in the card
     * @param _storedValue the stored value inside the card which is claimed by its user
     * @param _price the price of the card(use ERC20 tokens for pricing)
     */
    function validateCardClaim(
        bytes32[] calldata _MerkleProof,
        bytes32 _MerkleRoot,
        string calldata _tokenURI,
        uint256 _storedValue,
        uint256 _price
    ) external {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _storedValue, _tokenURI, _price));
        _verifyMerkleProof(_MerkleProof, _MerkleRoot, leaf);
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
     * @param _data the array of bytes which includes the necessary information to be signed
     * @param _deadline the expire timestamp of the input signed message
     * @param _v ECDSA signature parameter v
     * @param _r ECDSA signature parameter r
     * @param _s ECDSA signature parameter s
     */
    function cardPermit(address _operator, uint256 _tokenId, bytes[] calldata _data, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s)
        external
        onlyFactory
        returns (bool)
    {
        address cardOwner = ownerOf(_tokenId);
        bytes32 PERMIT_TYPEHASH =
            keccak256("cardPermit(address operator,uint256 tokenId,bytes[] _data,uint256 signerNonce,uint256 deadline)");
        if (block.timestamp > _deadline) {
            revert expiredSignature(block.timestamp, _deadline);
        }

        bytes32 structHash =
            keccak256(abi.encode(PERMIT_TYPEHASH, _operator, _tokenId, _data, _useNonce(cardOwner), _deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, _v, _r, _s);
        if (signer != cardOwner) {
            revert invalidSignature(signer, cardOwner);
        }
        return true;
    }

    /**
     * @notice The external function {approve} of the contract {ERC721} is banned in this contract.
     *
     * Note that any cards should keep their approval to `factory` at any time.
     */
    function approve(address to, uint256 tokenId) public override {
        revert externalApproveBanned();
    }

    /**
     * @dev The internal function {_mintCard} realizes the basic logics of minting a new card.
     */
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

    /**
     * @dev The internal function {_verifyMerkleProof} realizes the basic logics of verifying a Merkle proof.
     *
     * Note that `_proof` should be derived in advance.
     */
    function _verifyMerkleProof(bytes32[] memory _proof, bytes32 _root, bytes32 _leaf) internal pure {
        require(MerkleProof.verify(_proof, _root, _leaf), "Invalid Merkle proof");
    }

    /**
     * @notice Get the `merchantId` of the current card series.
     */
    function getMerchantId() public view returns (uint256) {
        return merchantId;
    }

    /**
     * @notice Get the `seriesId` of the current card series.
     */
    function getSeriesId() public view returns (uint256) {
        return seriesId;
    }

    /**
     * @notice Get the `name` of the current card series.
     */
    function getCardName() public view returns (string memory) {
        return cardName;
    }

    /**
     * @notice Get the `symbol` of the current card series.
     */
    function getCardSymbol() public view returns (string memory) {
        return cardSymbol;
    }

    /**
     * @notice Get the `currentSupply` of the current card series.
     */
    function getCurrentSupply() public view returns (uint256) {
        return currentSupply;
    }

    /**
     * @notice Get the `cardBalance` of the current card series.
     */
    function getCardBalance(uint256 _tokenId) public view returns (uint256) {
        address cardOwner = ownerOf(_tokenId);
        if (msg.sender != cardOwner) {
            revert notCardOwner();
        }
        return cardBalance[_tokenId];
    }
}
