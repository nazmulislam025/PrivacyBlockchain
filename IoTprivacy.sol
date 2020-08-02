pragma solidity ^0.5.2;

contract ownershipContract {

    //This declares a new complex type which will be used for variables later. It will represent a single voter.
    struct info {
        address payable owner;
        bool isRented;
        uint deposit;
        uint payment;
        uint rentPrice;
        address payable renter;
        uint rentStart;
        uint rentPeriod;
    }
    
    //The type maps addresses to unsigned integers. Mappings can be seen as hash tables which are virtually initialized such that
    //every possible key exists and is mapped to a value whose byte-representation is all zeros.
    mapping (uint => info) public idInfo;
    
    
    uint deviceIdentifier;

    function rentDevice(uint _identifier, uint _rentPeriod) public payable returns (bool) {
        require (
            idInfo[_identifier].isRented == true,
            "the device is already rented."
            );
        require (    
            msg.value < idInfo[_identifier].deposit,
            "not sufficient deposit money"
            );
        // or you can implement it like: if (msg.value < idInfo[_identifier].deposit) {revert()}
            
        //add renter for the device
        idInfo[_identifier].renter = msg.sender;
        idInfo[_identifier].rentStart = now;
        idInfo[_identifier].rentPeriod = _rentPeriod;
        idInfo[_identifier].payment = msg.value;
        //send ether to the owner of the device
        idInfo[_identifier].owner.transfer(msg.value);
        
        return true;
    }
    
    function terminateRent(uint _identifier) public {
        require (
            msg.sender == idInfo[_identifier].owner,
            "not allowed to perform this function"
            );
        require (
            now - idInfo[_identifier].rentStart > idInfo[_identifier].rentPeriod,
            "tenancy period is not over yet"
            );
        idInfo[_identifier].renter.transfer(idInfo[_identifier].payment - idInfo[_identifier].rentPrice);
    }
    
    function registerDevice(uint _identifier, address payable _owner) public {
        idInfo[_identifier].owner = _owner;
        idInfo[_identifier].isRented = false;
    }
    
    function checkOwnership(uint _identifier) public view returns (address _ownerName) {
        _ownerName = idInfo[_identifier].owner;
    }
    
    function transferOwnership(uint _identifier, address payable buyer) public {
        //If the first argument of `require` evaluates to `false`, execution terminates and all changes to the state 
		//and to Ether balances are reverted.
		//Use assert(x) if you never ever want x to be false, not in any circumstance (apart from a bug in your code). 
		//Use require(x) if x can be false, due to e.g. invalid input or a failing external component.
		// Use revert() to cancel a transaction
		require(
            msg.sender == idInfo[_identifier].owner,
            "Only device owner can transfer the ownership."
        );
        idInfo[_identifier].owner = buyer;
    }
}
