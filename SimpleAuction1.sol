// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract SimpleAuction{
    // parameters of the simple auction
    address payable public receiver;
    uint public auctionEndTime;

    //current state of the autionEndTime
    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) public pendingReturns;

    bool ended = false;
    
    event HighestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(uint _biddingTime, address payable _receiver){
        receiver = _receiver;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() public payable{
        if (block.timestamp > auctionEndTime){
            revert("The auction has already ended");
        }
        
        if (msg.value <= highestBid){
            revert("There is already a higher or equal bid");
        }

        if (highestBid !=0){
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncrease(msg.sender, msg.value);
    }
    function withdraw() public returns(bool){
          uint amount = pendingReturns[msg.sender];
          if(amount > 0){
              pendingReturns[msg.sender] = 0;
              if(!payable(msg.sender).send(amount)){
                  return false;
              }
          }
          return true;
    }

    function auctionEnd() public{
         if (block.timestamp < auctionEndTime){
             revert ("The auction has not ended yet");
         }
         if(ended){
             revert("The function auctionEnded has already been called");
         }
         ended = true;
         emit AuctionEnded(highestBidder, highestBid);
         receiver.transfer(highestBid);
    }
}