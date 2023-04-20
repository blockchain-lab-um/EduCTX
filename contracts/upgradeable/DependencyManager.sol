pragma solidity ^0.5.2;

import "../ownership/Ownable.sol";

contract DependencyManager is Ownable {

    event AddDependency(address indexed _from, string contractName, address indexed contractAddr);
    
    /// hash contract name to contract address
    mapping (bytes32 => address) private _nameToAddress;
    
    /// contract address to hash of contract name
    mapping (address => bytes32) public _addressToHash;
    
    constructor() public{
        addDependency("EduCTXdependencyManager_contract", address(this));
    }
    
    /**
    * @dev Override!
    */
    modifier onlyOwner() {
        require(tx.origin == owner());
        _;
    }
    
    /* 
        Pametno pogodbo v sistem lahko dodaja samo "owner" vseh ostalih PP.
        V primeru, da se doda v sistem pametna pogodba z imenom, ki v sistemu že obstaja
        se temu imenu doda naslov NOVO dodane pametne pogodbe.
    */
    function addDependency(string memory _contractName, address _contractAddr) public onlyOwner { 
        bytes32 nameHash = keccak256(abi.encodePacked(_contractName));
        require(nameHash.length != 0 && _contractAddr != address(0));
        
        // PP že obstaja, zato je potrebno, stari naslov, ki kaže na ime PP izbrisati iz sistema
        if(_addressToHash[_nameToAddress[nameHash]].length != 0){
            delete _addressToHash[_nameToAddress[nameHash]];
        }
        _addressToHash[_contractAddr] = nameHash; // Novo dodanemu naslovu PP se doda ime
        _nameToAddress[nameHash] = _contractAddr; // Novo dodani PP se prepiše ali pa na novo doda njen naslov
        
        emit AddDependency(msg.sender, _contractName, _contractAddr);
    }
    
    function getContractAddressByName(string calldata _contractName) external view returns (address) {
        return _nameToAddress[keccak256(abi.encodePacked(_contractName))];
    }
    
    function removeDependency(string memory _contractName) public onlyOwner {
         bytes32 nameHash = keccak256(abi.encodePacked(_contractName));
          delete _addressToHash[_nameToAddress[nameHash]];
          delete _nameToAddress[nameHash];
    }
    
    
}