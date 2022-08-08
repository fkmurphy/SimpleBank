// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SimpleBank is ReentrancyGuard {
    //
    // State variables
    //

    struct User {
      uint userId;
      uint balance;
      bool enrolled;
    }

    /* We want to protect our users balance from other contracts */
    mapping(address => User) users;

    uint private countUsersEnrolled;


    /* Let's make sure everyone knows who owns the bank. */
    address immutable public owner;

    //
    // Events
    //

    event LogEnrolled(address indexed newCustomer);

    event LogDepositMade(address indexed customer, uint indexed amount);

    event LogWithdraw(address indexed customer, uint indexed amount, uint indexed balance);


    //
    // Functions
    //

    constructor() {
        owner = msg.sender;
    }


    // Function to receive Ether
    receive() external payable {}


    /// @notice Get balance
    /// @return The balance of the user
    function getBalance() external view isEnrolled returns(uint){
      return users[msg.sender].balance;
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    // Emit the appropriate event
    function enroll() public returns (bool) {
        require(!users[msg.sender].enrolled, "User already enrolled");
        emit LogEnrolled(msg.sender);
        countUsersEnrolled++;
        users[msg.sender].enrolled = true;
        users[msg.sender].userId = countUsersEnrolled;

        return true;
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    // This function can receive ether
    // Users should be enrolled before they can make deposits
    function deposit()
      external
      payable
      isEnrolled
      amountIsGreaterZero(msg.value)
      returns (uint)
    {
      emit LogDepositMade(msg.sender, msg.value);
      users[msg.sender].balance += msg.value;

      return users[msg.sender].balance;
    }

    /// @notice Withdraw ether from bank
    /// @param _withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    // Emit the appropriate event
    function withdraw(uint _withdrawAmount)
      external
      isEnrolled
      returns (uint)
    {
      bool result = _withdraw(_withdrawAmount);
      require(result, "Failed withdraw amount");

      return users[msg.sender].balance;
    }

    /// @notice Withdraw remaining ether from bank
    /// @return bool transaction success
    // Emit the appropriate event
    function withdrawAll()
      external
      isEnrolled
      returns (bool)
    {
      bool result = _withdraw(users[msg.sender].balance);
      require(result, "Failed withdraw all amount");
      return result;
    }

    function _withdraw(uint _withdrawAmount)
      private
      nonReentrant
      isEnrolled
      amountIsGreaterZero(_withdrawAmount)
      hasAmountForWithdraw(_withdrawAmount)
      returns(bool)
    {
      uint newBalance = users[msg.sender].balance - _withdrawAmount;
      emit LogWithdraw(msg.sender, _withdrawAmount, newBalance);
      users[msg.sender].balance = newBalance;
      (bool result,) = msg.sender.call{value: _withdrawAmount}("");
      require(result, "Failed withdraw amount");
      return result;
    }

    modifier isEnrolled() {
      require(users[msg.sender].enrolled, 'need enrollment');
      _;
    }

    modifier hasAmountForWithdraw(uint _withdrawAmount) {
      require(users[msg.sender].balance >= _withdrawAmount, "Insufficient balance");
      _;
    }
    
    modifier amountIsGreaterZero(uint _amount) {
      require(_amount > 0, "Amount must be > 0");
      _;
    }

}
