pragma solidity ^0.5.2;

import "./DependencyManager.sol";

contract CommunicationManager is Ownable {

    event AllowCommunicaton(string _from, string _to);
    
    mapping(bytes32 => bytes32[]) public _verifiedCommunications;

    DependencyManager private _dependencyManager;
    
    constructor(address _dependencyManagerAddress) public{
        _dependencyManager = DependencyManager(_dependencyManagerAddress);
        _dependencyManager.addDependency("CommunicationManager", address(this)); // only owner in to je problem
    }
    
    function addCommunication (string calldata _from ,string calldata _to) external onlyOwner  {
        require(_checkIfAlreadyExists(_getHash(_from), _getHash(_to)) == false);
        _verifiedCommunications[_getHash(_from)].push(_getHash(_to));
        emit AllowCommunicaton(_from, _to);
    }
    
    function revokeCommunication (string calldata _from ,string calldata _to) external onlyOwner  {
        require(_checkIfAlreadyExists(_getHash(_from), _getHash(_to)));
        _deleteFromBytesArray(_getHash(_from), _getHash(_to));
    }
    
    function getAllowedCommunications(address _contract) view public returns(bytes32[] memory) {
        return _verifiedCommunications[_dependencyManager._addressToHash(_contract)];
    }

    function checkCommunication(address _from, address _to) external view returns(bool){
      bytes32[] memory inputTemp = new bytes32[](2);
      inputTemp[0] = _dependencyManager._addressToHash(_from); // ime from
      inputTemp[1] = _dependencyManager._addressToHash(_to); // ime to
      return _checkIfAlreadyExists(inputTemp[0], inputTemp[1]);
    }
    
    function _getHash(string memory _str) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(_str));
    }
    
    function _checkIfAlreadyExists(bytes32 _from ,bytes32 _to) public view returns(bool) {
        bytes32[] memory temp = new bytes32[](_verifiedCommunications[_from].length);
        temp = _verifiedCommunications[_from];
        for(uint i=0; i < temp.length ;i++) {
            if(temp[i] == _to) {
                return true;
            }
        }
        return false;
    }
    
    function _deleteFromBytesArray(bytes32 _from ,bytes32 _to) internal returns(bytes32) {
        
        bytes32[] storage _pointerArray = _verifiedCommunications[_from];
       
        uint index;
      
        for(uint i=0; i < _pointerArray.length ;i++) {
            if(_pointerArray[i] == _to) index = i;
        }
        
        for(uint i = index; i<_pointerArray.length-1; i++){
            _pointerArray[i] = _pointerArray[i+1];
        }
        _pointerArray.length--;
       
    }
    

}