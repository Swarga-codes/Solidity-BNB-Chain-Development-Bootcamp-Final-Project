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

//Functions

//Set Owner
function setOwner(address _newOwner) external onlyOwner{
    owner=_newOwner;
}

//addUser #non existing
function addUsers(string calldata name,string calldata lastName) external {
require(!isExistingUser(msg.sender),"The user already exists!");
user[msg.sender]=User(msg.sender,name,lastName,0,0,0,0);
emit addUser(msg.sender, user[msg.sender].name, user[msg.sender].lastName);
}

//add car #onlyOwner #nonExistingCar
function addCars(string calldata name,string calldata imgurl, uint rentFee,uint saleFee) external onlyOwner{
    _counter.increment();
    uint count=_counter.current();
    cars[count]=Cars(count,name,imgurl,Status.Available,rentFee,saleFee);
    emit carsAdded(count, cars[count].name, cars[count].imgUrl, cars[count].rentFee, cars[count].saleFee);
}

// edit car data #onlyOwner #existingCar
function editCarData(uint id,string calldata name,string calldata imgUrl,uint rentFee,uint saleFee) external onlyOwner{
require(cars[id].id!=0,"Car with the given Id does not exist!");
Cars storage currCar=cars[id];
if(bytes(name).length!=0){
    currCar.name=name;
}
if(bytes(imgUrl).length!=0){
    currCar.imgUrl=imgUrl;
}
if(rentFee>0){
    currCar.rentFee=rentFee;
}
if(saleFee>0){
    currCar.saleFee=saleFee;
}
emit updateCarMetaData(id, currCar.name, currCar.imgUrl, currCar.rentFee, currCar.saleFee);
}

//edit car status #existing car #onlyowner
function editCarStatus(uint id, Status status) external onlyOwner{
require(cars[id].id!=0,"Car with the given Id does not exist!");
Cars storage currCar=cars[id];
currCar.status=status;
emit updateStatus(id,currCar.status);
}
// checkout car #existing user
function checkOutCar(uint carsId) external{
    require(isExistingUser(msg.sender),"User not found!");
    require(cars[carsId].status==Status.Available,"Car is already rented and in use");
    require(user[msg.sender].rentedCarsId==0,"User has already rented a car");
    require(user[msg.sender].debt==0,"User has uncleared debt");
    cars[carsId].status=Status.InUse;
    user[msg.sender].start=block.timestamp;
    user[msg.sender].rentedCarsId=carsId;
    emit checkOut(msg.sender, carsId);
}

//Check In car #rented car #existing user
function checkInCar() external{
require(isExistingUser(msg.sender),"User does not exist!");
require(user[msg.sender].rentedCarsId!=0,"User has not rented any car");
uint timeUsed=block.timestamp-user[msg.sender].start;
uint rentedId=user[msg.sender].rentedCarsId;
user[msg.sender].debt+=calculateDebt(timeUsed,cars[rentedId].rentFee);
cars[rentedId].status=Status.Available;
user[msg.sender].rentedCarsId=0;
user[msg.sender].start=0;

emit checkIn(msg.sender, rentedId);
}

//Deposit #existinguser
function depositAmt() external payable{
require(isExistingUser(msg.sender),"User does not exist!");
user[msg.sender].balance+=msg.value;
emit deposit(msg.sender, msg.value);
}

//makePayment #existinguser #sufficient balance
function makePayment() external{
    require(isExistingUser(msg.sender),"User does not exist");
    uint debt=user[msg.sender].debt;
    uint balance=user[msg.sender].balance;
    require(debt>0,"User has no debt!");
    require(balance>=debt,"User has insufficient balance!");
    unchecked {
      user[msg.sender].balance-=debt;  
    }
    totalPayments+=debt;
    user[msg.sender].debt=0;
    emit paymentMade(msg.sender, debt);
}
}
