// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract TempleDonation {
    address public constant templeAccount = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;  // Address of the temple account
    address public owner;          // Address of the contract owner
    uint public totalDonation;     // Total amount donated to the temple

    // Structure to represent a transaction
    struct Transaction {
        address sender;
        uint amount;
        bool isIncome;  // true if income, false if expense
    }

    // Structure to represent a cause
    struct Cause {
        string name;
        uint balance;               // Balance for this cause
        mapping(uint => Transaction) transactions; // Transactions for this cause
        uint transactionCount;      // Transaction count for this cause
    }

    mapping(uint => Cause) public causes; // Mapping of cause ID to Cause
    uint public causeCount;                // Total count of causes

    constructor() {
        owner = msg.sender;
    }

    // Modifier to check if the caller is the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    // Function to add a new cause
    function addCause(string memory _name) public onlyOwner {
        causeCount++;
        Cause storage newCause = causes[causeCount];
        newCause.name = _name;
    }

    // Function to delete a cause
    function deleteCause(uint _causeId) public onlyOwner {
        require(_causeId > 0 && _causeId <= causeCount, "Invalid cause ID");
        delete causes[_causeId];
    }

    // Function to donate to a specific cause
    function donate(uint _causeId) public payable {
        require(_causeId > 0 && _causeId <= causeCount, "Invalid cause ID");
        causes[_causeId].balance += msg.value;
        totalDonation += msg.value;
        // Adding the transaction
        causes[_causeId].transactionCount++;
        uint transactionId = causes[_causeId].transactionCount;
        causes[_causeId].transactions[transactionId] = Transaction(msg.sender, msg.value, true);
    }

    // Function to spend money from a cause to a specified address
    function spend(uint _causeId, uint _amount, address payable _to) public onlyOwner {
        require(_causeId > 0 && _causeId <= causeCount, "Invalid cause ID");
        require(_amount <= causes[_causeId].balance, "Insufficient funds for this cause");
        causes[_causeId].balance -= _amount;
        totalDonation -= _amount;
        _to.transfer(_amount);  // Transfer the amount to the specified address
        // Adding the transaction
        causes[_causeId].transactionCount++;
        uint transactionId = causes[_causeId].transactionCount;
        causes[_causeId].transactions[transactionId] = Transaction(_to, _amount, false);
    }

    // Function to get the balance of a specific cause
    function getBalance(uint _causeId) public view returns (uint) {
        require(_causeId > 0 && _causeId <= causeCount, "Invalid cause ID");
        return causes[_causeId].balance;
    }

    // Function to get the total balance of the temple account
    function getTotalBalance() public view returns (uint) {
        return templeAccount.balance;
    }

    // Function to get the transaction count of a specific cause
    function getTransactionCount(uint _causeId) public view returns (uint) {
        require(_causeId > 0 && _causeId <= causeCount, "Invalid cause ID");
        return causes[_causeId].transactionCount;
    }

    // Function to get a specific transaction of a cause
    function getTransaction(uint _causeId, uint _transactionId) public view returns (address, uint, bool) {
        require(_causeId > 0 && _causeId <= causeCount, "Invalid cause ID");
        require(_transactionId > 0 && _transactionId <= causes[_causeId].transactionCount, "Invalid transaction ID");
        Transaction storage transaction = causes[_causeId].transactions[_transactionId];
        return (transaction.sender, transaction.amount, transaction.isIncome);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}