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
    function deposit() public isEnrolled returns (uint) {
      require(msg.value > 0, "Amount to deposit must be > 0");
      // TODO emit event
      balances[msg.sender] += msg.value;
    }

    /// @notice Withdraw ether from bank
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    // Emit the appropriate event
    function withdraw(uint _withdrawAmount)
      external
      isEnrolled
      hasAmountForWidthdraw(_withdrawAmount)
      returns (uint)
    {
      //TODO emit event
      bool result = _widthdraw(_withdrawAmount)
      require(result, "Failed withdraw amount");

      return balances[msg.sender];
    }

    /// @notice Withdraw remaining ether from bank
    /// @return bool transaction success
    // Emit the appropriate event
    function withdrawAll()
      external
      isEnrolled
      returns (bool)
    {
      //emit event
      bool result = _withdraw(balances[msg.sender]);
      require(result, "Failed withdraw all amount");
      return result;
    }

    function _widthdraw(uint _widthdrawAmount)
      private
      isEnrolled
      hasAmountForWidthdraw(_widthdrawAmount)
      returns(bool)
    {
      balances[msg.sender] -= _withdrawAmount;
      (bool result,) = msg.sender.call{value: _withdrawAmount}("");
      require(result, "Failed withdraw amount");
      return result;

    }

    modifier isEnrolled() {
      require(enrolled[msg.sender], 'need enrollment');
      _;
    }

    modifier hasAmountForWidthdraw(uint _widthdrawAmount) {
      require(_withdrawAmount > 0, "Amount must be > 0");
      require(balances[msg.sender] >= _withdrawAmount, "Insufficient balance");
      _;
    }

}
