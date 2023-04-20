pragma solidity ^0.5.2;

import "../upgradeable/DependencyManager.sol";
import "../upgradeable/CommunicationManager.sol";
import '../ownership/Ownable.sol';

contract EduCTXcaData is Ownable {
    
    /// KEY = CA address : VALUE = CA Logo URI
    mapping(address => string) private _caMetaLogoURI;
    
    /// KEY = CA address : VALUE = CA Name
    mapping(address => string) private _caMetaName;
    
    /// KEY = Authorized address : VALUE = CA address
    mapping(address => address) private _authorizedAddressCa;

    /// KEY = CA : VALUE = Authorized addresses
    mapping(address => address[]) private _caAuthorizedAddresses;

    /// Array of all CAs
    address[] private caArray;
    
    DependencyManager private dependencyManager_;
    CommunicationManager private communicationManager_;
    
    
    modifier _onlyAllowedContract {
       require(communicationManager_.checkCommunication(address(this), msg.sender));
       _;
    }

    constructor(address _dependencyManagerAddress) public {
        dependencyManager_ = DependencyManager(_dependencyManagerAddress);
        dependencyManager_.addDependency("EduCTXcaData", address(this));
    }
    
    function init() external onlyOwner {
       communicationManager_ = CommunicationManager(dependencyManager_.getContractAddressByName("CommunicationManager"));
    }
    
    function _set_caArray(address _a) external _onlyAllowedContract {
        caArray.push(_a);
    }

    function _set_caMetaName(address _a, string calldata _b) external _onlyAllowedContract {
        _caMetaName[_a] = _b;
    }
    
    function _set_caMetaLogoURI(address _a, string calldata _b) external _onlyAllowedContract {
        _caMetaLogoURI[_a] = _b;
    }
    
    function _set_authorizedAddressCa(address _a, address _b) external _onlyAllowedContract {
        _authorizedAddressCa[_a] = _b;
    }

    function _set_caAuthorizedAddresses(address _a, address _b) external _onlyAllowedContract {
        _caAuthorizedAddresses[_b].push(_a);
    }
    
    function _get_caMetaLogoURI(address _a) external view _onlyAllowedContract returns(string memory) {
        return _caMetaLogoURI[_a];
    }
    
    function _get_caMetaName(address _a) external view _onlyAllowedContract returns(string memory) {
        return _caMetaName[_a];
    }

    function _get_caArray() external view _onlyAllowedContract returns(address[] memory) {
        return caArray;
    }
    
    function _get_authorizedAddressCa(address _a) external view _onlyAllowedContract returns(address) {
        return _authorizedAddressCa[_a];
    }

    function _get_caAuthorizedAddresses(address _a) external view _onlyAllowedContract returns(address[] memory) {
        return _caAuthorizedAddresses[_a];
    }
    
    function _delete_caMetaName(address _a) external _onlyAllowedContract {
        delete _caMetaName[_a];
    }
    
    function _delete_caMetaLogoURI(address _a) external _onlyAllowedContract {
        delete _caMetaLogoURI[_a];
    }

    function _delete_caArray(address _a) external _onlyAllowedContract {
        bool found=false;
        uint index=0;
        for (uint i=0; i<caArray.length; i++){
            if (caArray[i]==_a){
                found=true;
                index=i;
            }
        }
        require(found);
        for (uint i = index; i < caArray.length - 1; i++) {
          caArray[i] = caArray[i + 1];
        }
        delete caArray[caArray.length - 1];
        caArray.length--;
    }
    
    function _delete_authorizedAddressCa(address _a) external _onlyAllowedContract {
        delete _authorizedAddressCa[_a];
    }

    function _delete_caAuthorizedAddresses(address _a, address _from) external _onlyAllowedContract {
        address[] memory tempArray=new address[](_caAuthorizedAddresses[_from].length-1);
        uint indexFound=0;
        bool found=false;
        for(uint256 i = 0; i < _caAuthorizedAddresses[_from].length; i++) {
            if(_a == _caAuthorizedAddresses[_from][i]) {
                found=true;
                indexFound=i;
            }
        }
        require(found);
        uint j=0;
        for (uint i=0; i<_caAuthorizedAddresses[_from].length; i++){
            if (i!=indexFound){
                tempArray[j]=_caAuthorizedAddresses[_from][i];
                j++;
            }
        }
        _caAuthorizedAddresses[_from]=tempArray;
    }
    
}