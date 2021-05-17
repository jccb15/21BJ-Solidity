pragma solidity ^0.6.0;

import "./Owned.sol";

contract TOBJ is Owned{
    
    uint EthChipConvRate = 1000;
    mapping(address => uint) public playerBalance;
    mapping(uint => Game) public Games;

    struct Game{
        uint gameID;
        uint pot;
        mapping (address => uint) Bets;
        uint playerTurn;
        address winner;
        bool payed;
        mapping (address => Hand) playersHands;
        //mapping(uint => Payment) receivedPayments;
    }
    
    struct Hand{
        uint8 numberOfCards;
        mapping (uint8=>uint8) cards;
        
    }
    
    
    function depositFunds() public payable{
        assert(playerBalance[msg.sender] + msg.value >= playerBalance[msg.sender]);
        playerBalance[msg.sender]+= msg.value;
    }
    
    function withdrawFunds(uint _amount) public payable{
        require(playerBalance[msg.sender] >= _amount, "insuficcient balance");
        assert(playerBalance[msg.sender] - _amount <= playerBalance[msg.sender]);
        playerBalance[msg.sender]-= _amount;
        msg.sender.transfer(_amount);
    }
    
    function transferChips(address _to, uint _amount) public {
        require(playerBalance[msg.sender] >= _amount, "insuficcient balance");
        assert(playerBalance[msg.sender] - _amount <= playerBalance[msg.sender]);
        playerBalance[msg.sender]-= _amount;
        playerBalance[_to] += _amount;
    }
    
    
    function getNewCard() public{
        //emit an event
    }
    
    function giveNewCard(uint gameID, address player, uint8 cardValue) public onlyOwnwer{
    
        Games[gameID].playersHands[player].cards[Games[gameID].playersHands[player].numberOfCards] = cardValue;
        Games[gameID].playersHands[player].numberOfCards += 1;
        
    }
    
    function payWinner(uint gameID) public onlyOwnwer{
        require(Games[gameID].payed == false, "Payment already processes");
        require(Games[gameID].winner != address(0), "Winner hasn't been announced");
        
        Games[gameID].payed = true;
        playerBalance[Games[gameID].winner] += Games[gameID].pot;
    }
    
    function placeBet(uint gameID, address player, uint amount) public onlyOwnwer{
        require(amount <= playerBalance[player]);
        assert(playerBalance[player] - amount <= playerBalance[player]);
        assert(Games[gameID].Bets[player] + amount >= Games[gameID].Bets[player]);
        
        playerBalance[player]-= amount;
        Games[gameID].Bets[player] += amount;
    }
    
    function ethToChips(uint _ethAmount) public view returns(uint){
        return (_ethAmount * EthChipConvRate);
    }
    
    function chipsToEth(uint _chipAmount) public view returns(uint){
        return _chipAmount / EthChipConvRate;
    }
    
    
    //Getters
    function getPlayerHand (uint gameID, address player) public returns(uint8[] memory) {
       uint8 numCards = Games[gameID].playersHands[player].numberOfCards;
       uint8[] memory cards = new uint8[](numCards);
       for (uint8 i=0; i<numCards; i++) {
           cards[i] = Games[gameID].playersHands[player].cards[i];
       }
       return cards;
    }

    
}
