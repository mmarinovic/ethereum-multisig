pragma solidity ^0.4.23;

import "../ethereum-misc/src/contracts/Ownable.sol";

contract Forwarder is Ownable {

    function() public payable{
        if(msg.value > 0) {
            forwardToOwner(msg.value);
        }
    }

    function forwardToOwner(uint value) internal{
        require(value > 0);
        owner.transfer(value);
    }
}