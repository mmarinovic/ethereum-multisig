pragma solidity ^0.4.23;

import { MultiSigWallet } from "./MultiSigWallet.sol";

contract MultiSigWalletWithDailyLimit is MultiSigWallet {

    uint public dailyLimit;
    uint public spentToday;
    uint public yesterday;

    constructor(address[] _signers, uint16 _requiredSigns, uint _dailyLimit) public MultiSigWallet(_signers, _requiredSigns) {
        require(_dailyLimit > 0);
        dailyLimit = _dailyLimit;
    }

    function executeTransaction(uint _transactionId) internal onlySigner {
        Transaction storage transaction = transactions[_transactionId];
        require(transaction.amount <= address(this).balance);

        bool isConfirmed = isTransactionConfirmed(_transactionId);
        bool isUnderLimit = isUnderDailyLimit(transaction.amount);

        if(isConfirmed && isUnderLimit && !transaction.executed){

            transaction.executed = true;
            spentToday += transaction.amount;

            if (transaction.destination.call.value(transaction.amount)(transaction.data)){
                emit TransactionExecuted(_transactionId);
            }else {
                transaction.executed = false;
                spentToday -= transaction.amount;
                emit TransactionExecutionFailed(_transactionId);
            }
        }
    }

    function isUnderDailyLimit(uint amount) internal returns (bool) {

        if(block.timestamp > yesterday + 24 hours){
            yesterday = block.timestamp;
            spentToday = 0;
        }

        if(spentToday + amount > dailyLimit){
            return false;
        }

        return true;
    }
}