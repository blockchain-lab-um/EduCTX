pragma solidity ^0.5.2;

import "../upgradeable/DependencyManager.sol";
import "./EduCTXcaData.sol";
import '../ownership/Ownable.sol';

contract EduCTXca is Ownable {
    
    DependencyManager private dependencyManager_;
    EduCTXcaData private eduCTXcaData_;
    
    event AddCA(address indexed _from, address indexed _caAddress, string _metaName, string _metaLogoURI);
    event RemoveCA(address indexed _from, address indexed _caAddress);
    event ChangeCaMeta(string _type, address indexed _from, address indexed _caAddress, string _newMetaData);
    event AddAuthorizedAddress(address indexed _caAddress, address indexed _authorizedAddress);
    event RemoveAuthorizedAddress(address indexed _caAddress, address indexed _authorizedAddress);
    
    constructor(address _dependencyManagerAddress) public {
        dependencyManager_ = DependencyManager(_dependencyManagerAddress);
        dependencyManager_.addDependency("EduCTXca", address(this));
    }
    
    function init() external onlyOwner {
        eduCTXcaData_ = EduCTXcaData(dependencyManager_.getContractAddressByName("EduCTXcaData"));
    }
    
    /// sender must be authorized address
    modifier onlyAuthorizedAddress {
        require(isAuthorizedAddress(msg.sender));
        _;
    }
    
    /// sender must be already added as ca
    modifier onlyCa {
        require(isCa(msg.sender));
        _;
    }
    
    /// Function that returns if address is on CA list or not
    function isCa(address _address) public view returns(bool) {
        if(bytes(eduCTXcaData_._get_caMetaName(_address)).length != 0) return true;
    }
    
    /// Function that returns if address is on authorized address list
    function isAuthorizedAddress(address _address) public view returns(bool) {
        if(bytes(eduCTXcaData_._get_caMetaName(eduCTXcaData_._get_authorizedAddressCa(_address))).length != 0) return true;
    }
    
    /// Function that add new address on CA address list - can be performed only by system owner
    function addCa(address _caAddress, string calldata _metaName, string calldata _metaLogoURI) external onlyOwner {
        _addCa(_caAddress, _metaName, _metaLogoURI);
    }
    
    /// Function that add new address on CA address list - can be performed only by system owner
    function removeCa(address _caAddress) external onlyOwner { 
        _removeCa(_caAddress);
    }
    
    /// Function that add authorized address - can be performed only by ca
    function addAuthorizedAddress(address _authorizedAddress) external onlyCa {
        _addAuthorizedAddress(msg.sender, _authorizedAddress);
    }
    
    /// Function that remove authorized address - can be performed only by ca
    function removeAuthorizedAddress(address _authorizedAddress) external onlyCa {
        _removeAuthorizedAddress(msg.sender, _authorizedAddress);
    }
    
    function changeMeta(string calldata _newMetaName, string calldata _newMetaLogoURI) external onlyCa {
        _changeCaMetaName(msg.sender, _newMetaName);
        _changeCaMetaLogoURI(msg.sender, _newMetaLogoURI);

    }
    
    /// Function that return CA Logo URI and NAME
    function getCaMetaData(address _caAddress) public view returns(string memory, string memory) {
        return (eduCTXcaData_._get_caMetaLogoURI(_caAddress), eduCTXcaData_._get_caMetaName(_caAddress));
    }

    /// Function that return all CA in the system
    function getAllCa() public view returns(address[] memory) {
        return eduCTXcaData_._get_caArray();
    }

    /// Function that return array of CA authorized addresses
    function getAuthorizedAddressesByCa(address _ca) public view returns(address[] memory) {
        return eduCTXcaData_._get_caAuthorizedAddresses(_ca);
    }
    
    /// Function that return ca address which authorized address
    function getAuthorizedAddressCa(address _authorizedAddress) public view returns(address) {
        return eduCTXcaData_._get_authorizedAddressCa(_authorizedAddress);
    }
    
    /// TO-DO avtomatsko ga dodaj v certPacketsveritifcation
    function _addCa(address _caAddress, string memory _metaName, string memory _metaLogoURI) internal {
        require(_caAddress != address(0) && bytes(_metaName).length != 0 && bytes(_metaLogoURI).length != 0);
        require(bytes(eduCTXcaData_._get_caMetaName(_caAddress)).length == 0, "CA already exists");
        require(bytes(eduCTXcaData_._get_caMetaLogoURI(_caAddress)).length == 0, "CA already exists");
        eduCTXcaData_._set_caMetaName(_caAddress, _metaName);
        eduCTXcaData_._set_caMetaLogoURI(_caAddress, _metaLogoURI);
        eduCTXcaData_._set_caArray(_caAddress);
        emit AddCA(msg.sender, _caAddress, _metaName, _metaLogoURI);
    }
    
    function _removeCa(address _caAddress) internal {
        require(_caAddress != address(0));
        require(bytes(eduCTXcaData_._get_caMetaName(_caAddress)).length != 0, "CA does not exists");
        eduCTXcaData_._delete_caMetaName(_caAddress);
        eduCTXcaData_._delete_caMetaLogoURI(_caAddress);
        eduCTXcaData_._delete_caArray(_caAddress);
        emit RemoveCA(msg.sender, _caAddress);
    }
    
    function _changeCaMetaName(address _caAddress, string memory _metaName) internal {
        require(_caAddress != address(0) && bytes(_metaName).length != 0);
        require(bytes(eduCTXcaData_._get_caMetaName(_caAddress)).length != 0, "Ca does not exists");
        eduCTXcaData_._set_caMetaName(_caAddress, _metaName);
        emit ChangeCaMeta("name", msg.sender, _caAddress, _metaName);
    }
    
   function _changeCaMetaLogoURI(address _caAddress, string memory _metaLogoURI) internal {
        require(_caAddress != address(0) && bytes(_metaLogoURI).length != 0);
        require(bytes(eduCTXcaData_._get_caMetaLogoURI(_caAddress)).length != 0, "Ca does not exists");
        eduCTXcaData_._set_caMetaLogoURI(_caAddress, _metaLogoURI);
        emit ChangeCaMeta("logoURI", msg.sender, _caAddress, _metaLogoURI);
    }
    
    function _addAuthorizedAddress(address _caAddress, address _authorizedAddress) internal {
        require(_authorizedAddress != address(0));
        require(eduCTXcaData_._get_authorizedAddressCa(_authorizedAddress) == address(0), "Authorized address already exists");
        eduCTXcaData_._set_authorizedAddressCa(_authorizedAddress, _caAddress);
        eduCTXcaData_._set_caAuthorizedAddresses(_authorizedAddress, _caAddress);
        emit AddAuthorizedAddress(msg.sender, _authorizedAddress);
    }
    
    function _removeAuthorizedAddress(address _caAddress, address _authorizedAddress) internal {
        require(_authorizedAddress != address(0));
        require(eduCTXcaData_._get_authorizedAddressCa(_authorizedAddress) == _caAddress);
        require(eduCTXcaData_._get_authorizedAddressCa(_authorizedAddress) != address(0), "Authorized address does not exists");
        eduCTXcaData_._delete_authorizedAddressCa(_authorizedAddress);
        eduCTXcaData_._delete_caAuthorizedAddresses(_authorizedAddress, _caAddress);
        emit RemoveAuthorizedAddress(msg.sender, _authorizedAddress);
    }
    
}