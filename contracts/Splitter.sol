pragma solidity ^0.4.6;

contract Splitter {
    address public owner;
    
    event LogRegister(address sender,address receiver1,address receiver2);
    event LogSplit(uint amount,address sender,address receiver1,address receiver2);
    event LogWithdraw(uint amount,address creator,address beneficiary);
    
    struct Split{
        address[2] accounts;
        uint[2] balances;
    }
    
    mapping(address=> Split) splitters;
    

    function Splitter() {
        owner = msg.sender;
    }
    
    function register(address receiver1,address receiver2)
    public
    returns(bool success){
        assert(msg.sender != receiver1&&msg.sender != receiver2);
        assert(receiver1!= address(0)&&receiver2!= address(0));
        assert(receiver1!=receiver2);
        assert(splitters[msg.sender].balances[0] ==0&&splitters[msg.sender].balances[1] ==0); //Avoid the owner of the split to overwrite balances of the receivers
        
        Split memory newSplit;
        
        newSplit.accounts[0] = receiver1;
        newSplit.accounts[1] = receiver2;
        
        splitters[msg.sender] = newSplit;
        
        LogRegister(msg.sender,receiver1,receiver2);
        return true;
    }
    
    function split()
    public 
    payable
    returns (bool success){
        assert(msg.value>1 && msg.value%2==0);
        assert(splitters[msg.sender].accounts[0]!= address(0)&&splitters[msg.sender].accounts[1]!= address(0));
        splitters[msg.sender].balances[0]+=(msg.value/2);
        splitters[msg.sender].balances[1]+=(msg.value/2);
        LogSplit(msg.value,msg.sender, splitters[msg.sender].accounts[0],splitters[msg.sender].accounts[1]);
        return true;
    }
    
    function balanceOf(address creator,address target)
    public
    constant
    returns (uint amount){
        uint balance;
        for(uint i=0;i<splitters[creator].balances.length;i++){
            if(splitters[creator].accounts[i]==target)
                balance = splitters[creator].balances[i];
        }
        return balance;
    }
    
    function withdraw(address creator)
    public 
    returns(bool success){
        uint amount = 0;
        uint index = 0;
         for(uint i=0;i<splitters[creator].balances.length;i++){
            if(splitters[creator].accounts[i]==msg.sender){
                amount = splitters[creator].balances[i];
                index = i;
            }
        }
        assert(amount>0);
        
        splitters[creator].balances[index] = 0;
        LogWithdraw(amount,creator,msg.sender);
        msg.sender.transfer(amount);
        return true;
    }
    
    function kill()
    public{
        assert(msg.sender==owner);
        suicide(owner);
    }
    
    function getSplit(address creator)
    public
    constant
    returns(address[2] accounts, uint[2] balances){
        return (splitters[creator].accounts,splitters[creator].balances);
    }
    
}




