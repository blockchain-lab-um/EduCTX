pragma solidity ^0.5.2;

import "../math/SafeMath.sol";
import "../upgradeable/DependencyManager.sol";
import "../upgradeable/CommunicationManager.sol";

contract RegisteredUserData is Ownable {
    
    using SafeMath for uint256;
    
    /// KEY = address : VALUE = userid
    mapping(address => uint256) private _addressToUserID;
    
    /// KEY = userid : VALUE = address
    mapping(uint256 => address) private _userIDtoAddress;
    
    /// KEY = userid : VALUE = user public key
    mapping(uint256 => bytes) private _userIDtoPubKey;
    
    uint256 private totalUsers = 0;
    
    DependencyManager internal dependencyManager_;
    CommunicationManager internal communicationManager_;
    
    modifier _onlyAllowedContract {
       require(communicationManager_.checkCommunication(address(this), msg.sender));
       _;
    }
    
    modifier _onlyIfIdNotExists (uint _id) {
       require(_userIDtoAddress[_id] == address(0));
       _;
    }
    
    constructor(address _dependencyManagerAddress) public {
        dependencyManager_ = DependencyManager(_dependencyManagerAddress);
        dependencyManager_.addDependency("RegisteredUserData", address(this));
    }
    
    function init() external onlyOwner {
       communicationManager_ = CommunicationManager(dependencyManager_.getContractAddressByName("CommunicationManager"));
    }
    
    function _set_addressToUserID(address _a, uint256 _b) external _onlyAllowedContract {
        _addressToUserID[_a] = _b;
    }
    
    function _set_userIDtoAddress(uint256 _a, address _b) external _onlyAllowedContract _onlyIfIdNotExists(_a) {
        _userIDtoAddress[_a] = _b;
    }
    
    function _set_userIDtoPubKey(uint256 _a, bytes calldata _b) external _onlyAllowedContract {
        _userIDtoPubKey[_a] = _b;
    }
    
    function _set_totalUsers(uint256 _a) external _onlyAllowedContract {
        totalUsers = _a;
    }
    
    function _get_addressToUserID(address _a) external view _onlyAllowedContract returns(uint256) {
        return _addressToUserID[_a];
    }
    
    function _get_userIDtoAddress(uint256 _a) external view _onlyAllowedContract returns(address) {
        return _userIDtoAddress[_a];
    }
    
    function _get_userIDtoPubKey(uint256 _a) external view _onlyAllowedContract returns(bytes memory) {
        return _userIDtoPubKey[_a];
    }
    
    function _get_totalUsers() external view _onlyAllowedContract returns(uint256) {
        return totalUsers;
    }
    
    function _delete_addressToUserID(address _a) external _onlyAllowedContract {
        delete _addressToUserID[_a];
    }
    
    function _delete_userIDtoAddress(uint256 _a) external _onlyAllowedContract {
        delete _userIDtoAddress[_a];
    }
    
    function _delete_userIDtoPubKey(uint256 _a) external _onlyAllowedContract {
        delete _userIDtoPubKey[_a];
    }
    
}
