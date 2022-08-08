// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

contract SimpleBank {
    //
    // State variables
    //

    /* We want to protect our users balance from other contracts */
    mapping(address => uint) balances;

    /* We want to create a getter function and allow
    contracts to be able to see if a user is enrolled.  */
    mapping(address => bool) enrolled;

    /* Let's make sure everyone knows who owns the bank. */
    address owner;

    //
    // Events
    //

    /* Add an argument for this event, an accountAddress */
    event LogEnrolled(address indexed newCustomer);

    /* Add 2 arguments for this event, an accountAddress and an amount */
    event LogDepositMade(address indexed customer, uint indexed amount);

    /* Create an event that logs Withdrawals
    It should log 3 arguments:
    the account address, the amount withdrawn, and the new balance. */
    // event



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
    function getBalance() external isEnrolled returns(uint){
      return balances[msg.sender];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    // Emit the appropriate event
    function enroll() public returns (bool) {
        require(!enrolled[msg.sender], "User already enrolled");
        emit LogEnrolled(msg.sender);
        enrolled[msg.sender] = true;
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    // This function can receive ether
    // Users should be enrolled before they can make deposits
    function deposit() public returns (uint) {
        // ...
        //
        //
    }

    /// @notice Withdraw ether from bank
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    // Emit the appropriate event
    function withdraw(uint withdrawAmount)  isEnrolled external returns (uint) {
      require(balances[msg.sender] >= withdrawAmount, "Insufficient balance");
      //TODO emit event
      balances[msg.sender] -= withdrawAmount;
      (bool result,) = msg.sender.call{value: withdrawAmount}("");
      require(result, "Failed withdraw amount");
    }

    /// @notice Withdraw remaining ether from bank
    /// @return bool transaction success
    // Emit the appropriate event
    function withdrawAll() returns (bool) {
        // ...
        //
        //
        //
    }

    modifier isEnrolled() {
      require(enrolled[msg.sender], 'need enrollment');
    }



}
