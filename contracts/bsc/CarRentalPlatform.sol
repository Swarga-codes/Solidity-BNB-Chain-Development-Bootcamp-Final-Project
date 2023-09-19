// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../../node_modules/@openzeppelin/contracts/utils/Counters.sol";
contract CarRentalPlatform {
//Data


//Counter
using Counters for Counters.Counter;
Counters.Counter private _counter;

//Owner
address private owner;
//totalPayments
uint public totalPayments;
//User struct
struct User{
    address walletAddress;
    string name;
    string lastName;
    uint rentedCarsId;
    uint debt;
    uint balance;
    uint start;
}

//Car struct
struct Cars{
    uint carsId;
    string name;
    string imgUrl;
    Status status;
    uint rentFee;
    uint saleFee;
}

//enum to indicate the status of car
enum Status{
    Available,InUse,Retired
}

//events
event carsAdded(uint indexed carsId,string name,string imgUrl,uint rentFee,uint saleFee);
event updateCarMetaData(uint indexed carsId,string name,string imgUrl,uint rentFee,uint saleFee);
event updateStatus(uint indexed carsId,Status status);
event addUser(address indexed walletAddress,string name,string lastName);
event deposit(address indexed walletAddress,uint amount);
event checkOut(address indexed walletAddress,uint carsId);
event checkIn(address indexed walletAddress,uint carsId);
event paymentMade(address indexed walletAddress,uint amount);
event withdrawWalletBalance(address indexed walletAddress,uint amount);

//User mapping
mapping(address=>User) private user;


//Car mapping

mapping(uint=>Cars) private cars;

//Constructor
constructor(){
    owner=msg.sender;
    totalPayments=0;
}

//Modifiers
//Only owner can access
modifier onlyOwner(){
    require(owner==msg.sender,"Only the owner can call this function");
    _;
}


}
