pragma solidity ^0.5.2;

import "../upgradeable/DependencyManager.sol";
import "./EduCTXtokenData.sol";
import "../math/SafeMath.sol";
import "../users/RegisteredUser.sol";
import "../ca/EduCTXca.sol";

/**
 * @title Full ERC721 Token
 * This implementation includes all the requiredand some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract EduCTXtoken is Ownable {
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    event CertificateIssued(address indexed from, uint256 indexed userID, string dataHash, string dataCipher);

    using SafeMath for uint;
    
    DependencyManager internal dependencyManager_;
    EduCTXtokenData internal eduCTXtokenData_;
    RegisteredUser internal registeredUser_;
    EduCTXca internal eduCTXca_;
    
    constructor(address _dependencyManagerAddress) public {
        dependencyManager_ = DependencyManager(_dependencyManagerAddress);
        dependencyManager_.addDependency("EduCTXtoken", address(this));
    }
    
    function init() external onlyOwner {
        eduCTXtokenData_ = EduCTXtokenData(dependencyManager_.getContractAddressByName("EduCTXtokenData"));
    }
    
    function issueCertificate(uint _userID, string memory _dataHash, string memory _dataCipher) public  {
        registeredUser_ = RegisteredUser(dependencyManager_.getContractAddressByName("RegisteredUser"));
        eduCTXca_ = EduCTXca(dependencyManager_.getContractAddressByName("EduCTXca"));
        
        require(eduCTXca_.isCa(msg.sender));
        require(registeredUser_.isRegisteredUser(_userID));
        
        eduCTXtokenData_._set_issuedCerts(eduCTXtokenData_._get_issuedCerts().add(1));
        uint issuedCertsNumTemp =  eduCTXtokenData_._get_issuedCerts();
        _mint(registeredUser_.getAddressById(_userID), issuedCertsNumTemp);
        _setTokenIssuerAddr(issuedCertsNumTemp, msg.sender);
        _setTokenDataHash(issuedCertsNumTemp, _dataHash);
        _setTokenCipherText(issuedCertsNumTemp, _dataCipher);
        eduCTXtokenData_._set_issuerTokensId(issuedCertsNumTemp, msg.sender);
        emit CertificateIssued(address(0), _userID, _dataHash, _dataCipher);

    }
    
    function issueCertificateAuthorizedAddress(uint _userID, string memory _dataHash, string memory _dataUri) public  {
        registeredUser_ = RegisteredUser(dependencyManager_.getContractAddressByName("RegisteredUser"));
        eduCTXca_ = EduCTXca(dependencyManager_.getContractAddressByName("EduCTXca"));
        
        require(eduCTXca_.isAuthorizedAddress(msg.sender));
        require(registeredUser_.isRegisteredUser(_userID));

        eduCTXtokenData_._set_issuedCerts(eduCTXtokenData_._get_issuedCerts().add(1));
        
        uint issuedCertsNumTemp =  eduCTXtokenData_._get_issuedCerts();
        _mint(registeredUser_.getAddressById(_userID), issuedCertsNumTemp);
        
        _setTokenIssuerAddr(issuedCertsNumTemp, eduCTXca_.getAuthorizedAddressCa(msg.sender));
        _setTokenDataHash(issuedCertsNumTemp, _dataHash);
        _setTokenCipherText(issuedCertsNumTemp, _dataUri);
        eduCTXtokenData_._set_issuerTokensId(issuedCertsNumTemp, eduCTXca_.getAuthorizedAddressCa(msg.sender));
        eduCTXtokenData_._set_authorizedAddressTokensId(issuedCertsNumTemp, msg.sender);
        eduCTXtokenData_._set_tokenIdAuthorizedAddress(issuedCertsNumTemp, msg.sender);

        emit CertificateIssued(eduCTXca_.getAuthorizedAddressCa(msg.sender), _userID, _dataHash, _dataUri);

    }
    
    function revokeCertificate(uint _tokenId) public {
        require(tokenIssuerAddr(_tokenId) == msg.sender);
        _burn(_tokenId);
        eduCTXtokenData_._delete_issuerTokensId(_tokenId, msg.sender);
        address authorizedAddress=eduCTXtokenData_._get_tokenIdAuthorizedAddress(_tokenId);
        if (authorizedAddress!=address(0)){
            eduCTXtokenData_._delete_authorizedAddressTokensId(_tokenId, authorizedAddress);
            eduCTXtokenData_._delete_tokenIdAuthorizedAddress(_tokenId);
        }
    }
    
    function getIssuedTokensByCa(address _caAddress) public view returns (uint256[] memory){
        return _getIssuedTokensByCa(_caAddress);
    }

    function getIssuedTokensByAuthorizedAddress(address _authorizedAddress) public view returns (uint256[] memory){
        return _getIssuedTokensByAuthorizedAddress(_authorizedAddress);
    }
    
    /// ERC721 contract
    /**
     * @dev Gets the balance of the specified address
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0));
        return eduCTXtokenData_._get_ownedTokensCount(owner);
    }

    /**
     * @dev Gets the owner of the specified token ID
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = eduCTXtokenData_._get_tokenOwner(tokenId);
        require(owner != address(0));
        return owner;
    }

    /**
     * @dev Returns whether the specified token exists
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = eduCTXtokenData_._get_tokenOwner(tokenId);
        return owner != address(0);
    }

    /**
     * @dev Internal function to mint a new token
     * Reverts if the given token ID already exists
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0));
        require(!_exists(tokenId));

        eduCTXtokenData_._set_tokenOwner(tokenId, to);
        eduCTXtokenData_._set_ownedTokensCount(to, eduCTXtokenData_._get_ownedTokensCount(to).add(1));
        
        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner);

        eduCTXtokenData_._set_ownedTokensCount(owner, eduCTXtokenData_._get_ownedTokensCount(owner).sub(1));
        eduCTXtokenData_._set_tokenOwner(tokenId, address(0));

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        // // Since tokenId will be deleted, we can clear its slot in _ownedTokensIndex to trigger a gas refund
        eduCTXtokenData_._set_ownedTokensIndex(tokenId, 0);

        _removeTokenFromAllTokensEnumeration(tokenId);
        
        //   Clear metadata (if any)
        if (eduCTXtokenData_._get_tokenIssuerAddr(tokenId) != address(0)) {
            eduCTXtokenData_._delete_tokenIssuerAddr(tokenId);
        }

        // Clear metadata (if any)
        if (bytes(eduCTXtokenData_._get_tokenDataHash(tokenId)).length != 0) {
            eduCTXtokenData_._delete_tokenDataHash(tokenId);
        }
        
        // Clear metadata (if any)
        if (bytes(eduCTXtokenData_._get_tokenCipherText(tokenId)).length != 0) {
            eduCTXtokenData_._delete_tokenCipherText(tokenId);
        }

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }
    
    
    //// ENUMEBRABLE CONTRACT

    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner
     * @param owner address owning the tokens list to be accessed
     * @param index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner));
        return eduCTXtokenData_._get_ownedTokens_counter(owner,index);
    }

    /**
     * @dev Gets the total amount of tokens stored by the contract
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view returns (uint256) {
        return eduCTXtokenData_._get_allTokens().length;
    }

    /**
     * @dev Gets the token ID at a given index of all the tokens in this contract
     * Reverts if the index is greater or equal to the total number of tokens
     * @param index uint256 representing the index to be accessed of the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply());
        return eduCTXtokenData_._get_allTokens_counter(index);
    }

    /**
     * @dev Gets the list of token IDs of the requested owner
     * @param owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function _tokensOfOwner(address owner) internal view returns (uint256[] memory) {
        return eduCTXtokenData_._get_ownedTokens_all(owner);
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        eduCTXtokenData_._set_ownedTokensIndex(tokenId, eduCTXtokenData_._get_ownedTokens_all(to).length);
        eduCTXtokenData_._set_ownedTokens_push(to, tokenId);
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        eduCTXtokenData_._set_allTokensIndex(tokenId, eduCTXtokenData_._get_allTokens().length);
        eduCTXtokenData_._set_allTokens_push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the _ownedTokensIndex mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).
        uint256 lastTokenIndex = eduCTXtokenData_._get_ownedTokens_all(from).length.sub(1); // eduCTXtokenData_
        uint256 tokenIndex = eduCTXtokenData_._get_ownedTokensIndex(tokenId);

        // // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = eduCTXtokenData_._get_ownedTokens_counter(from,lastTokenIndex);

            eduCTXtokenData_._set_ownedTokens_counter(from, tokenIndex, lastTokenId);
            eduCTXtokenData_._set_ownedTokensIndex(lastTokenId, tokenIndex);
        }

        // // This also deletes the contents at the last position of the array
        eduCTXtokenData_._set_ownedTokens_length(from, eduCTXtokenData_._get_ownedTokens_all(from).length.sub(1));

        // Note that _ownedTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occcupied by
        // lasTokenId, or just over the end of the array if the token was the last one).
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).
        uint256 lastTokenIndex = eduCTXtokenData_._get_allTokens().length.sub(1);
        uint256 tokenIndex = eduCTXtokenData_._get_allTokensIndex(tokenId);

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = eduCTXtokenData_._get_allTokens_counter(lastTokenIndex);

        eduCTXtokenData_._set_allTokens_counter(tokenIndex, lastTokenId); 
        eduCTXtokenData_._set_allTokensIndex(lastTokenId, tokenIndex);

        // This also deletes the contents at the last position of the array
        eduCTXtokenData_._set_allTokens_length(eduCTXtokenData_._get_allTokens().length.sub(1));
        eduCTXtokenData_._set_allTokensIndex(tokenId, 0);

    }
    
    /// ERC721Metadata
    function tokenIssuerAddr(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId));
        return eduCTXtokenData_._get_tokenIssuerAddr(tokenId);
    }

    function _setTokenIssuerAddr(uint256 tokenId, address account) internal {
        require(_exists(tokenId));
        eduCTXtokenData_._set_tokenIssuerAddr(tokenId, account);
    }

    function tokenDataHash(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId));
        return eduCTXtokenData_._get_tokenDataHash(tokenId);
    }

    function _setTokenDataHash(uint256 tokenId, string memory dataHash) internal {
        require(_exists(tokenId));
        return eduCTXtokenData_._set_tokenDataHash(tokenId, dataHash);
    }
    
    function tokenCipherText(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId));
        return eduCTXtokenData_._get_tokenCipherText(tokenId);
    }

    function _setTokenCipherText(uint256 tokenId, string memory dataCipher) internal {
        require(_exists(tokenId));
        eduCTXtokenData_._set_tokenCipherText(tokenId, dataCipher);
    }

    function _getIssuedTokensByCa(address _caAddress) internal view returns (uint[] memory){
        return eduCTXtokenData_._get_issuerTokensId(_caAddress);
    }

    function _getIssuedTokensByAuthorizedAddress(address _authorizedAddress) internal view returns (uint[] memory){
        return eduCTXtokenData_._get_authorizedAddressTokensId(_authorizedAddress);
    }

    

}
