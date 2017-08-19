pragma solidity ^0.4.6;

contract Splitter {
    address public owner;
    
    event LogRegister(address sender,address receiver1,address receiver2);
    event LogSplit(uint amount,address sender,address receiver1,address receiver2);
    
    mapping(address=> address[2]) public splitters;
    

    function Splitter() {
        owner = msg.sender;
    }
    
    function register(address receiver1,address receiver2)
    public
    returns(bool success){
        assert(msg.sender != receiver1&&msg.sender != receiver2);
        assert(receiver1!= address(0)&&receiver2!= address(0));
        assert(receiver1!=receiver2);
        
        splitters[msg.sender][0] = receiver1;
        splitters[msg.sender][1] = receiver2;
        
        LogRegister(msg.sender,receiver1,receiver2);
        return true;
    }
    
    function split()
    public 
    payable
    returns (bool success){
        assert(msg.value>1 && msg.value%2==0);
        assert(splitters[msg.sender][0]!= address(0)&&splitters[msg.sender][1]!= address(0));
        splitters[msg.sender][0].transfer(msg.value/2);
        splitters[msg.sender][1].transfer(msg.value/2);
        LogSplit(msg.value,msg.sender, splitters[msg.sender][0],splitters[msg.sender][1]);
        return true;
    }
    
    function balanceOf(address target)
    public
    constant
    returns (uint amount){
        return target.balance;
    }
    
    function kill()
    public{
        assert(msg.sender==owner);
        suicide(owner);
    }
    
}












