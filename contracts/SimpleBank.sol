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

    event LogEnrolled(address indexed newCustomer);

    event LogDepositMade(address indexed customer, uint indexed amount);

    event LogWidthdraw(address indexed customer, uint indexed amount, uint indexed balance);



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
      LogDepositMade(msg.sender, msg.value);
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
      bool result = _withdraw(_withdrawAmount);
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
      bool result = _withdraw(balances[msg.sender]);
      require(result, "Failed withdraw all amount");
      return result;
    }

    function _withdraw(uint _withdrawAmount)
      private
      isEnrolled
      hasAmountForWidthdraw(_withdrawAmount)
      returns(bool)
    {
      uint newBalance = balances[msg.sender] - _withdrawAmount;
      emit LogWidthdraw(msg.sender, _withdrawAmount, newBalance);
      balances[msg.sender] = newBalance;
      (bool result,) = msg.sender.call{value: _withdrawAmount}("");
      require(result, "Failed withdraw amount");
      return result;
    }

    modifier isEnrolled() {
      require(enrolled[msg.sender], 'need enrollment');
      _;
    }

    modifier hasAmountForWidthdraw(uint _withdrawAmount) {
      require(_withdrawAmount > 0, "Amount must be > 0");
      require(balances[msg.sender] >= _withdrawAmount, "Insufficient balance");
      _;
    }

}
