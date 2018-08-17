pragma solidity ^0.4.23;

contract MultiSigWallet {

    address[] private signers;
    uint16 private requiredSigns;
    Transaction[] private transactions;

    struct Transaction{
        uint amount;
        address destination;
        string data;
        bool executed;
    }

    event TransactionAdded(uint indexed id);

    constructor(address[] _signers, uint16 _requiredSigns) public{

        require(_signers.length > 0);
        require(_requiredSigns > 0);

        signers = _signers;
        requiredSigns = _requiredSigns;
    }

    modifier onlySigner(){
        for(uint i = 0; i <= signers.length; i++){
            if(signers[i] == msg.sender){
                _;
            }
        }
        require(false);
    }

    function addSigned(address signer) public onlySigner{

    }

    function removeSigner(address signer) public onlySigner{

    }

    function addTransaction(uint _amount, address _destination, string _data) public returns (uint){
        require(_amount > 0);
        require(this.balance >= _amount);
        require(_destination != address(0));

        Transaction memory newTx = Transaction({
            amount: _amount,
            destination: _destination,
            data: _data,
            executed: false
        });

        uint newTxId = transactions.push(newTx);
        emit TransactionAdded(newTxId);
        return newTxId;
    }

    function confirmTransaction(uint _transactionId) public onlySigner{
        
    }

    function executeTransaction(uint _transactionId) internal onlySigner {

    }
}