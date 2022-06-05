// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract SimpleAuction{
    address payable public vendor;
    uint public auctionEndTime;
    address public highestBidder;
    uint public highestBid;

    mapping(address=>uint) public pendingReturns;
    bool public started;
    bool public ended;
    
    modifier notVendor(){
        require(msg.sender!=vendor, "Access Denied");
        _;
    }
    
    modifier onlyVendor(){
        require(msg.sender==vendor, "Access Denied!");
        _;
    }
      event HighestBidIncrease(address bidder, uint amount);
      event AuctionEnded(address winner, uint amount);

    constructor(address payable _vendor){
        vendor = _vendor;

    }

    function start() public onlyVendor{
        require(!started, "started");
        started = true;
        ended = false;
        auctionEndTime = block.timestamp + 240;

    }

    function bid() public payable notVendor{
        require(started, "not started");
        if(block.timestamp > auctionEndTime){
            revert("The auction had already ended");
        }

        if(msg.value <= highestBid){
            revert("There is a higher or equal bid");
        }

        if(highestBid != 0){
            pendingReturns[highestBidder] +=highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncrease(msg.sender, msg.value);

    }
    
    function withdraw() public returns(bool){
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;
        }

        if(!payable(msg.sender).send(amount)){
            pendingReturns[msg.sender] = amount;
            return false;

        }
             return true;
    }
    
    function auctionEnd() public{
        if(block.timestamp < auctionEndTime){
            revert("The auction has not ended yet");
        }
        if(ended){
            revert("The auctionEnded has already been called");
        }
        ended = true;
        
        emit AuctionEnded(highestBidder, highestBid);

        vendor.transfer(highestBid);
        highestBid=0;
    }
}
