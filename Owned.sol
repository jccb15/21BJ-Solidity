pragma solidity ^0.8.0;

contract Owned{
    address owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwnwer(){
        require(msg.sender == owner, "you are not the owner");
        _;
    }
    
}
