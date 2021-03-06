pragma solidity ^0.8.0;

import "./Owned.sol";

contract TOBJ is Owned{
    
    uint EthChipConvRate = 1000;
    uint ChipToWei = 1000000000000000;
    mapping(address => uint) public playerBalance;
    mapping(uint => Game) public Games;
    mapping (address => bool) charityAddresses;

    struct Game{
        uint gameID;
        uint pot;
        // mapping (address => uint) Bets;
        // uint playerTurn;
        address winner;
        bool payed;
        mapping (address => Hand) playersHands;
        //mapping(uint => Payment) receivedPayments;
    }
    
    struct Hand{
        uint8 numberOfCards;
        mapping (uint8=>Card) cards;
    }
    
    enum CardSuit { CLUBS, DIAMONDS, HEARTS, SPADES }
    struct Card{
        uint8 value;
        CardSuit suit;
    }
    
    
    function buyChips() public payable{
        assert(playerBalance[msg.sender] + msg.value >= playerBalance[msg.sender]);
        playerBalance[msg.sender]+= msg.value/ChipToWei;
    }
    
    
    function addCharityAddr(address charityAddr) public onlyOwnwer{
        charityAddresses[charityAddr] = true;
    }
    
    
    function donateChips(uint chipsToDonate, address payable charityAddr) public{
        require(charityAddresses[charityAddr] == true, "The given address is not an approved Charity");
        require(playerBalance[msg.sender] >= chipsToDonate, "insuficcient balance");
        assert(playerBalance[msg.sender] - chipsToDonate <= playerBalance[msg.sender]);
        
        playerBalance[msg.sender] -= chipsToDonate;
        charityAddr.transfer(chipsToDonate * ChipToWei);
    }
    

    function transferChips(address _to, uint _amount) public {
        require(playerBalance[msg.sender] >= _amount, "insuficcient balance");
        assert(playerBalance[msg.sender] - _amount <= playerBalance[msg.sender]);
        playerBalance[msg.sender]-= _amount;
        playerBalance[_to] += _amount;
    }
    

    event eNewCard(uint indexed gameID, address indexed player, uint8 cardValue, uint8 suit);
    function giveNewCard(uint gameID, address player, uint8 cardValue, CardSuit suit ) public onlyOwnwer{
        
        address playerAddr;
        if (player != Owned.owner){ playerAddr = player;}
        
        // Games[gameID].playersHands[player].cards[Games[gameID].playersHands[player].numberOfCards].value = cardValue;
        // Games[gameID].playersHands[player].cards[Games[gameID].playersHands[player].numberOfCards].suit = suit;
        // Games[gameID].playersHands[player].numberOfCards += 1;
        
        emit eNewCard(gameID, playerAddr, cardValue, uint8(suit));
    }
    
    
    function setBalance(address player, uint newBalance) public onlyOwnwer{
        playerBalance[player] = newBalance;
    }
    
    
    function markGamePayed(uint gameID) public onlyOwnwer{
        Games[gameID].payed = true;
    }
    
    
    function placeBet(uint gameID, address player, uint amount) public onlyOwnwer{
        require(playerBalance[player] >= amount, "insufficient balance");
        assert(playerBalance[player] - amount <= playerBalance[player]);
        assert(Games[gameID].Bets[player] + amount >= Games[gameID].Bets[player]);
        
        playerBalance[player]-= amount;
        Games[gameID].Bets[player] += amount;
    }
    
    
    //Getters
    function getPlayerHand (uint gameID, address player) public view returns(Card[] memory) {
       uint8 numCards = Games[gameID].playersHands[player].numberOfCards;
       Card[] memory cards = new Card[](numCards);
       for (uint8 i=0; i<numCards; i++) {
           cards[i] = Games[gameID].playersHands[player].cards[i];
       }
       return cards;
    }

    
    //Function to directly buy chips
    receive() external payable { 
        assert(playerBalance[msg.sender] + msg.value/ChipToWei >= playerBalance[msg.sender]);
        playerBalance[msg.sender]+= msg.value/ChipToWei;
    }
    
    // 
    // function getPlayerBets (uint gameID, address player) public returns(uint) {
    //   uint amountBetted = Game[gameID].Bets[player]; 
    //   return amountBetted;
    // }
    
    // function payWinner(uint gameID) public onlyOwnwer{
    //     require(Games[gameID].payed == false, "Payment already processes");
    //     require(Games[gameID].winner != address(0), "Winner hasn't been announced");
        
    //     Games[gameID].payed = true;
    //     playerBalance[Games[gameID].winner] += Games[gameID].pot;
    // }
    
    // function withdrawFunds(uint _amount) public payable{
    //     require(playerBalance[msg.sender] >= _amount, "insuficcient balance");
    //     assert(playerBalance[msg.sender] - _amount <= playerBalance[msg.sender]);
    //     playerBalance[msg.sender]-= _amount;
    //     msg.sender.transfer(_amount*ChipToWei);
    // }
}
