//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICardSeries {
    /**
     * @dev Emitted when a Merkle proof is validated successfully.
     */
    event validatedForCardClaimed(uint256 storedValue, string tokenURI, uint256 price, address user);

    /**
     * @dev Indicates a failure with `caller`. Used in checking if the caller equals `factory`.
     */
    error notFactory(address caller);

    /**
     * @dev Indicates a failure with `derivedSigner` and `validSigner`. Used in checking if the signer of a signed message equals the expected address.
     */
    error invalidSignature(address derivedSigner, address validSigner);

    /**
     * @dev Indicates a failure with `currendTimestamp` and `deadline`. Used in checking if a signature of a signed message out is expired.
     */
    error expiredSignature(uint256 currendTimestamp, uint256 deadline);

    /**
     * @dev Indicates a failure. Used in checking if the current supply of the cards has reached `maxSupply`.
     */
    error reachMaxSupply();

    /**
     * @dev Indicates a failure. Used in checking if `msg.sender` equals the owner of the card.
     */
    error notCardOwner();

    /**
     * @dev Indicates a failure when {init} is not called after the deployment of the current contract. Used in checking if `factory` is initialized with a value of a non-address(0) address.
     */
    error uninitialized();

    /**
     * @dev Indicates a failure when any account(address) calls {approve}.
     */
    error externalApproveBanned();

    /**
     * @dev Indicates a failure with `inputAddr`. Used in checking if the input address is applicable to the function called.
     */
    error invalidAddress(address inputAddr);

    /**
     * @dev Because the constructor does not work when this contract is deployed via minimal proxy, this function will initialize 
     * the state variables of itself and its parent contract(s).
     *
     * Note that {init} should only be called once at the moment of the deployment of this contract.
     */
    function init(address _factoryAddr, uint256 _merchantId, uint256 _seriesId, string calldata _seriesName, string calldata _seriesSymbol, uint256 _maxSupply) external;

    /**
     * @notice Merchant mints a new card to `_to` with an originally stored value(count in token).
     *
     * @return tokenId a unique ID of the card minted directly returned by internal function {_mintCard}.
     *
     * Note `tokenId` starts from 0 and ends at `maxSupply`.
     */
    function mintCard(address _to, string memory _tokenURI, uint256 _value) external returns (uint256);

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
    function validateCardClaim(bytes32[] calldata _MerkleProof, bytes32 _MerkleRoot, string calldata _tokenURI, uint256 _storedValue, uint256 _price) external;

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
    function cardPermit(address _operator, uint256 _tokenId, bytes[] calldata _data, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) external returns (bool);

    /**
     * @dev Conduct the action of card transfer. The card will be transferred from the owner of the card to `_to`.
     *
     * Emits a {Transfer} event.
     */
    function executeCardTransfer(address _to, uint256 _tokenId) external;

    /**
     * @notice Get the `merchantId` of the current card series.
     */
    function getMerchantId() external view returns (uint256);

    /**
     * @notice Get the `seriesId` of the current card series.
     */
    function getSeriesId() external view returns (uint256);

    /**
     * @notice Get the `currentSupply` of the current card series.
     */
    function getCurrentSupply() external view returns (uint256);

    /**
     * @notice Get the `cardBalance` of the current card series.
     */
    function getCardBalance(uint256 _tokenId) external view returns (uint256);

    /**
     * @notice Get the `transNum` of the card corresponding to the input `_tokenId`.
     */
    function getTransNum(uint256 _tokenId) external view returns (uint256);
}
