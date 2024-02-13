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
            revert notFactory(msg.sender);
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
