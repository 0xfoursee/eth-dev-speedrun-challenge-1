pragma solidity ^0.8.3;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
  address public owner;
  ExampleExternalContract public exampleExternalContract;
  uint public deadline_timestamp;
  mapping(address => uint) public balances;
  uint public threshold = 200;

  event Stake(address who, uint amount);

  modifier expired() {
    require(block.timestamp > deadline_timestamp, "Staking period is still active!");
    _;
  }

  modifier active() {
    require(block.timestamp < deadline_timestamp, "Staking period has expired!");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;
  }

  // modifier notCompleted() {
  //   require(exampleExternalContract.completed, "Execution has not been completed!");
  //   _;
  // }

  constructor(address exampleExternalContractAddress) public {
      owner = msg.sender;
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      deadline_timestamp = block.timestamp + 60; // 10 mins from deploy
  }

  function getBalance() view public returns (uint){
    return address(this).balance;
  }

  function setDeadline(uint new_deadline) public onlyOwner {
    deadline_timestamp = new_deadline;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake() public payable active {
    emit Stake(msg.sender, msg.value);
    balances[msg.sender] += msg.value;
  }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  function execute() public expired {
    require(address(this).balance >= threshold, "Threshold was not met.");
    require(exampleExternalContract.completed() == false, "Completion already triggered!");

    exampleExternalContract.complete{value: address(this).balance}();
  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() public expired returns(bool){
    uint amount = balances[msg.sender];
    require(address(this).balance <= threshold, "Threshold was met within deadline, withdrawing disabled.");
    require(amount > 0, "No personal funds to withdraw");

    balances[msg.sender] -= amount;
    payable(msg.sender).transfer(amount);

    return true;
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() view public active returns (uint) {
    uint diff = deadline_timestamp - block.timestamp;
    if (diff > 0) {
      return diff;
    } else {
      return 0;
    }
  }


  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable active {
    stake();
  }


}
