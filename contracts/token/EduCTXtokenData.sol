pragma solidity ^0.5.2;

// import "../ca/EduCTXca.sol";
// import "../users/RegisteredUser.sol";
// import "../math/SafeMath.sol";
// import "../drafts/Counters.sol";
import "../upgradeable/DependencyManager.sol";
import "../upgradeable/CommunicationManager.sol";
import '../ownership/Ownable.sol';

/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract EduCTXtokenData is Ownable {
    
     
    // using SafeMath for uint256;
    // using Counters for Counters.Counter;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /// ERC721 DATA
    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from owner to number of owned token
    mapping (address => uint) private _ownedTokensCount;
    
    //// ENUMEBRABLE CONTRACT DATA
    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    // Optional mapping for token URIs
    mapping(uint256 => address) private _tokenIssuerAddr;
    
    mapping(uint256 => string) private _tokenDataHash;
    
    mapping(uint256 => string) private _tokenCipherText;

    //Mapping from issuer to array of token IDs
    mapping (address => uint256[]) private _issuerTokensId;

    //Mapping from authorized address to array of token IDs
    mapping (address => uint256[]) private _authorizedAddressTokensId;

    //Mapping from token ID to authorized address
    mapping (uint => address) private _tokenIdAuthorizedAddress;

    uint private _issuedCerts;
    
    DependencyManager internal dependencyManager_;
    CommunicationManager internal communicationManager_;
    
    modifier _onlyAllowedContract {
       require(communicationManager_.checkCommunication(address(this), msg.sender));
       _;
    }

    constructor(address _dependencyManagerAddress) public {
        dependencyManager_ = DependencyManager(_dependencyManagerAddress);
        dependencyManager_.addDependency("EduCTXtokenData", address(this));
    }
    
    function init() external onlyOwner {
       communicationManager_ = CommunicationManager(dependencyManager_.getContractAddressByName("CommunicationManager"));
    }
    
    /// GET, SET, DELETE - mapping _tokenOwner
    function _set_tokenOwner(uint _a, address _b) external _onlyAllowedContract {
	    _tokenOwner[_a] = _b;
    }
    
    function _get_tokenOwner(uint _a) external view _onlyAllowedContract returns(address) {
    	return _tokenOwner[_a];
    }
    
    function _delete_tokenOwner(uint _a) external _onlyAllowedContract {
    	delete _tokenOwner[_a];
    }

    //// GET - mapping _tokenIdAuthorizedAddress
    function _get_tokenIdAuthorizedAddress(uint _tokenId) external view _onlyAllowedContract returns(address) {
    	return _tokenIdAuthorizedAddress[_tokenId];
    }

    function _delete_tokenIdAuthorizedAddress(uint _tokenId) external _onlyAllowedContract {
    	delete _tokenIdAuthorizedAddress[_tokenId];
    }

    function _set_tokenIdAuthorizedAddress(uint _a, address _b) external _onlyAllowedContract {
        _tokenIdAuthorizedAddress[_a]=_b;
    }

    /// GET, SET, DELETE - mapping _issuerTokensId
    function _set_authorizedAddressTokensId(uint _a, address _b) external _onlyAllowedContract {
	    _authorizedAddressTokensId[_b].push(_a);
    }
    
    function _get_authorizedAddressTokensId(address _a) external view _onlyAllowedContract returns(uint256[] memory) {
    	return _authorizedAddressTokensId[_a];
    }
    
    function _delete_authorizedAddressTokensId(uint _tokenId, address _authorizedAddress) external _onlyAllowedContract {
    	uint256[] memory tempArray=new uint256[](_authorizedAddressTokensId[_authorizedAddress].length-1);
        uint indexFound=0;
        bool found=false;
        for(uint256 i = 0; i < _authorizedAddressTokensId[_authorizedAddress].length; i++) {
            if(_tokenId == _authorizedAddressTokensId[_authorizedAddress][i]) {
                found=true;
                indexFound=i;
            }
        }
        require(found);
        uint j=0;
        for (uint i=0; i<_authorizedAddressTokensId[_authorizedAddress].length; i++){
            if (i!=indexFound){
                tempArray[j]=_authorizedAddressTokensId[_authorizedAddress][i];
                j++;
            }
        }
        _authorizedAddressTokensId[_authorizedAddress]=tempArray;
    }

    /// GET, SET, DELETE - mapping _issuerTokensId
    function _set_issuerTokensId(uint _a, address _b) external _onlyAllowedContract {
	    _issuerTokensId[_b].push(_a);
    }
    
    function _get_issuerTokensId(address _a) external view _onlyAllowedContract returns(uint256[] memory) {
    	return _issuerTokensId[_a];
    }
    
    function _delete_issuerTokensId(uint _tokenId, address _issuer) external _onlyAllowedContract {
    	uint256[] memory tempArray=new uint256[](_issuerTokensId[_issuer].length-1);
        uint indexFound=0;
        bool found=false;
        for(uint256 i = 0; i < _issuerTokensId[_issuer].length; i++) {
            if(_tokenId == _issuerTokensId[_issuer][i]) {
                found=true;
                indexFound=i;
            }
        }
        require(found);
        uint j=0;
        for (uint i=0; i<_issuerTokensId[_issuer].length; i++){
            if (i!=indexFound){
                tempArray[j]=_issuerTokensId[_issuer][i];
                j++;
            }
        }
        _issuerTokensId[_issuer]=tempArray;
    }
    
    
    /// GET, SET, DELETE - mapping _ownedTokensCount
    function _set_ownedTokensCount(address _a, uint _b) external _onlyAllowedContract {
	    _ownedTokensCount[_a] = _b;
    }

    function _get_ownedTokensCount(address _a) external view _onlyAllowedContract returns(uint)  {
    	return  _ownedTokensCount[_a];
    }
    
    function _delete_ownedTokensCount(address _a) external _onlyAllowedContract {
    	delete _ownedTokensCount[_a];
    }
    
    /// GET, SET, DELETE, LENGTH - mapping _ownedTokens
    function _set_ownedTokens_push(address _a, uint _b) external _onlyAllowedContract {
    	_ownedTokens[_a].push(_b);
    }
    
    function _set_ownedTokens_counter(address _a, uint _b, uint _c) external _onlyAllowedContract {
    	_ownedTokens[_a][_b] = _c;
    }
    
    function _get_ownedTokens_all(address _a) external view _onlyAllowedContract returns(uint[] memory) {
    	return _ownedTokens[_a];
    }
    
    function _get_ownedTokens_counter(address _a, uint _b) external view _onlyAllowedContract returns(uint) {
    	return _ownedTokens[_a][_b];
    }
    
    function _delete_ownedTokens_index(address _a) external _onlyAllowedContract  {
    	delete _ownedTokens[_a];
    }
    
    function _delete_ownedTokens_index(address _a, uint _b) external _onlyAllowedContract  {
    	delete _ownedTokens[_a][_b];
    }
    
    function _set_ownedTokens_length(address _a, uint _b) external _onlyAllowedContract {
        _ownedTokens[_a].length = _b;
    }
    
    /// GET, SET, DELETE - mapping _ownedTokensIndex
    function _set_ownedTokensIndex(uint _a, uint _b) external _onlyAllowedContract {
	    _ownedTokensIndex[_a] = _b;
    }
    
    function _get_ownedTokensIndex(uint _a) external view _onlyAllowedContract returns(uint) {
    	return _ownedTokensIndex[_a];
    }
    
    function _delete_ownedTokensIndex(uint _a) external _onlyAllowedContract {
    	delete _ownedTokensIndex[_a];
    }
    
    /// GET, SET, DELETE, SET LENGTH - mapping _allToken
    function _set_allTokens_push(uint _a) external _onlyAllowedContract {
	    _allTokens.push(_a);
    }
    
    function _set_allTokens_counter(uint _a, uint _b) external _onlyAllowedContract {
    	_allTokens[_a] = _b;
    }
    
    function _get_allTokens() external view _onlyAllowedContract returns(uint[] memory) {
    	return _allTokens;
    }
    
    function _get_allTokens_counter(uint _a) external view _onlyAllowedContract returns(uint) {
    	return _allTokens[_a];
    }
    
    function _delete_allTokens_counter(uint _a) external _onlyAllowedContract {
    	delete _allTokens[_a];
    }
    
    function _set_allTokens_length(uint _b) external _onlyAllowedContract {
    	_allTokens.length = _b;
    }
    
    /// GET, SET, DELETE - mapping _allTokens
    function _set_allTokensIndex(uint _a, uint _b) external _onlyAllowedContract {
	    _allTokensIndex[_a] = _b;
    }
    
    function _get_allTokensIndex(uint _a) external view _onlyAllowedContract returns(uint) {
    	return _allTokensIndex[_a];
    }
    
    function _delete_allTokensIndex(uint _a) external _onlyAllowedContract {
    	delete _tokenOwner[_a];
    }
    
    /// GET, SET, DELETE - mapping _tokenIssuerAddr
    
    function _set_tokenIssuerAddr(uint _a, address _b) external _onlyAllowedContract {
    	_tokenIssuerAddr[_a] = _b;
    }
    
    function _get_tokenIssuerAddr(uint _a) external view _onlyAllowedContract returns(address) {
    	return _tokenIssuerAddr[_a];
    }
    
    function _delete_tokenIssuerAddr(uint _a) external _onlyAllowedContract {
    	delete _tokenIssuerAddr[_a];
    }
    
    /// GET, SET, DELETE - mapping _tokenDataHash
    function _set_tokenDataHash(uint _a, string calldata _b) external _onlyAllowedContract {
    	_tokenDataHash[_a] = _b;
    }
    
    function _get_tokenDataHash(uint _a) external view _onlyAllowedContract returns(string memory) {
    	return _tokenDataHash[_a];
    }
    
    function _delete_tokenDataHash(uint _a) external _onlyAllowedContract {
    	delete _tokenDataHash[_a];
    }
    
    /// GET, SET, DELETE - mapping _set_token CIPHERTEXT
    function _set_tokenCipherText(uint _a, string calldata _b) external _onlyAllowedContract {
    	_tokenCipherText[_a] = _b;
    }
    
    function _get_tokenCipherText(uint _a) external view _onlyAllowedContract returns(string memory) {
    	return _tokenCipherText[_a];
    }
    
    function _delete_tokenCipherText(uint _a) external _onlyAllowedContract {
    	delete _tokenCipherText[_a];
    }
    
    
    /// GET, SET - uint - _issuedCerts
     function _set_issuedCerts(uint _a) external _onlyAllowedContract {
    	_issuedCerts = _a;
    }
    
    function _get_issuedCerts() external view _onlyAllowedContract returns(uint) {
    	return _issuedCerts;
    }
    
}
