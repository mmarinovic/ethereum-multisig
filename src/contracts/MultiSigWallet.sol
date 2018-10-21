pragma solidity ^0.4.23;

import { Forwarder }  from "./Forwarder.sol";

contract MultiSigWallet {

    address private owner;
    address[] private signers;
    address[] public forwarders; 
    uint16 private requiredSigns;

    Transaction[] private transactions;
    mapping(uint => mapping(address => bool)) private confirmations;

    struct Transaction{
        uint amount;
        address destination;
        string data;
        bool executed;
    }

    event Deposited(uint indexed amount, address indexed sender);
    event TransactionAdded(uint indexed id);
    event TransactionConfirmation(uint indexed id, address indexed signer);
    event TransactionExecuted(uint indexed id);
    event TransactionExecutionFailed(uint indexed id);

    constructor(address[] _signers, uint16 _requiredSigns) public{

        require(_signers.length >= 3);
        require(_requiredSigns >=2);

        signers = _signers;
        requiredSigns = _requiredSigns;
    }

    function() public payable{
        if(msg.value > 0){
            emit Deposited(msg.value, msg.sender);
        }
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    modifier onlySigner(){
        for(uint i = 0; i < signers.length; i++){
            if(signers[i] == msg.sender){
                _;
            }
        }
        require(false);
    }

    function transferOwner(address _newOwner) public onlyOwner{
        require(_newOwner != address(0));

        owner = _newOwner;
    }

    function addSigner(address _signer) public onlyOwner{
        require(_signer != address(0));
        require(_signer != msg.sender);

        signers.push(_signer);
    }

    function removeSigner(address _signer) public onlyOwner{
        require(_signer != address(0));
        require(_signer != msg.sender);

        for(uint i = 0; i < signers.length; i++){
            if(signers[i] == _signer){
                delete signers[i];
            }
        }
    }

    function addTransaction(uint _amount, address _destination, string _data) public onlyOwner returns (uint) {
        require(_amount > 0);
        require(address(this).balance >= _amount);
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
        Transaction storage transaction = transactions[_transactionId];
        require(!transaction.executed);
        require(!isTransactionConfirmed(_transactionId));
        require(!isTransactionConfirmedBySigner(_transactionId));

        confirmations[_transactionId][msg.sender] = true;

        emit TransactionConfirmation(_transactionId, msg.sender);

        if(isTransactionConfirmed(_transactionId)){
            executeTransaction(_transactionId);
        }
    }

    function deployNewForwarder() external onlyOwner {
        Forwarder f = new Forwarder();
        forwarders.push(address(f));
    }

    function executeTransaction(uint _transactionId) private onlySigner {
        Transaction storage transaction = transactions[_transactionId];
        require(transaction.amount <= address(this).balance);

        bool isConfirmed = isTransactionConfirmed(_transactionId);

        if(isConfirmed && !transaction.executed){

            transaction.executed = true;

            if (transaction.destination.call.value(transaction.amount)(transaction.data)){
                emit TransactionExecuted(_transactionId);
            }else {
                transaction.executed = false;
                emit TransactionExecutionFailed(_transactionId);
            }
        }
    }

    function isTransactionConfirmed(uint _transactionId) private view returns (bool){
        
        uint confirmCount = 0;
        for(uint i = 0; i < signers.length; i++){
            if(confirmations[_transactionId][signers[i]]){
                confirmCount++;
            }
        }

        return confirmCount >= requiredSigns;
    }

    function isTransactionConfirmedBySigner(uint _transactionId) private view returns (bool){
        return confirmations[_transactionId][msg.sender];
    }
}