pragma solidity ^0.5.2;

import "../upgradeable/DependencyManager.sol";
import "./RegisteredUserData.sol";
import "../math/SafeMath.sol";
import "../ca/EduCTXca.sol";


contract RegisteredUser is Ownable {
    
    using SafeMath for uint256;
    
    DependencyManager internal dependencyManager_;
    RegisteredUserData internal registeredUserData_;
    EduCTXca internal eduCTXca_;


    constructor(address _dependencyManagerAddress) public {
        dependencyManager_ = DependencyManager(_dependencyManagerAddress);
        dependencyManager_.addDependency("RegisteredUser", address(this));
    }
    
    function init() external onlyOwner {
        registeredUserData_ = RegisteredUserData(dependencyManager_.getContractAddressByName("RegisteredUserData"));
    }
    
    /// Check if user exists
    modifier onlyRegisteredUser(uint _id) {
        require(registeredUserData_._get_userIDtoAddress(_id) != address(0));
        _;
    }
    
    function isRegisteredUser(uint _id) external view returns(bool) {
        if(registeredUserData_._get_userIDtoAddress(_id) != address(0)) return true;
    }
    
    /// Register user with address and public key // CHECK!! EID
    function registerUser(address _userAddress, bytes memory _userPubKey, uint256 _id) public {
        // eduCTXca_ = EduCTXca(dependencyManager_.getContractAddressByName("EduCTXca"));
        // require(eduCTXca_.isCa(msg.sender) || eduCTXca_.isAuthorizedAddress(msg.sender));
        require(bytes(_userPubKey).length != 0);
        address userAddress = _getAddressFromPublicKey(_userPubKey);
        require(userAddress == _userAddress);
        require(registeredUserData_._get_addressToUserID(userAddress) == 0);
        registeredUserData_._set_totalUsers(registeredUserData_._get_totalUsers().add(1));
        registeredUserData_._set_userIDtoAddress(_id, userAddress);
        registeredUserData_._set_addressToUserID(userAddress,_id);
        registeredUserData_._set_userIDtoPubKey(_id,_userPubKey);
    }
    
    /// get user ID by user address
    function getIDbyAddress(address _userAddress) public view returns (uint256) {
        return registeredUserData_._get_addressToUserID(_userAddress);
    }
    
    /// get user public key with user ID
    function getUserPubKeyById(uint256 _id) public view returns (bytes memory) {
         return registeredUserData_._get_userIDtoPubKey(_id);
    }
    
    /// get user address with user ID
    function getAddressById(uint256 _id) public view returns (address) {
         return registeredUserData_._get_userIDtoAddress(_id);
    }
      
    function _getAddressFromPublicKey(bytes memory pub) internal pure returns(address addr) {
      bytes32 hash = keccak256(pub);
        assembly {
            mstore(0, hash)
            addr := mload(0)
        }    
    }

      
}
