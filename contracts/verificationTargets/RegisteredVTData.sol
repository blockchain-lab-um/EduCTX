pragma solidity ^0.5.2;

import "../upgradeable/DependencyManager.sol";
import "../upgradeable/CommunicationManager.sol";

contract RegisteredVTData is Ownable {
    
    /// KEY = verification target id : VALUE = verification target public key
    mapping(address => bytes) private _addressToPubKey;
    
    uint256 private totalOfVT = 0;
    
    DependencyManager internal dependencyManager_;
    CommunicationManager internal communicationManager_;
    
    
    modifier _onlyAllowedContract {
       require(communicationManager_.checkCommunication(address(this), msg.sender));
       _;
    }

    constructor(address _dependencyManagerAddress) public {
        dependencyManager_ = DependencyManager(_dependencyManagerAddress);
        dependencyManager_.addDependency("RegisteredVTData", address(this));
    }
    
    function init() external onlyOwner {
       communicationManager_ = CommunicationManager(dependencyManager_.getContractAddressByName("CommunicationManager"));
    }
    
    function set_addressToPubKey(address _a, bytes calldata _b) external _onlyAllowedContract {
        _addressToPubKey[_a] = _b;
    }
    
    function set_totalOfVT(uint256 _a) external _onlyAllowedContract {
        totalOfVT = _a;
    }
    
    function get_addressToPubKey(address _a) external view _onlyAllowedContract returns(bytes memory) {
        return _addressToPubKey[_a];
    }
    
    function get_totalOfVT() external view _onlyAllowedContract returns(uint256) {
        return totalOfVT;
    }
    
    function delete_addressToPubKey(address _a) external _onlyAllowedContract {
        delete _addressToPubKey[_a];
    }
    
}
