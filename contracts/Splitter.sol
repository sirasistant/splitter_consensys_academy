pragma solidity ^0.4.6;

contract Wallet{
    event LogMoneyAdded(address account, uint amount);
    event LogWithdraw(address account, uint amount);
    
    mapping(address=>uint) public balances;
    
    function withdraw()
    public
    returns(bool success){
        require(balances[msg.sender]>0);
        uint amount =  balances[msg.sender];
        balances[msg.sender]=0;
        msg.sender.transfer(amount);
        LogWithdraw(msg.sender, amount);
        return true;
    }
    
    function addMoney(address account, uint amount)
    internal{
        balances[account] += amount;
        LogMoneyAdded(account,amount);
    }
}

contract Splitter is Wallet{
    address public owner;
    
    event LogRegister(address sender,address receiver1,address receiver2);
    event LogSplit(uint amount,address sender,address receiver1,address receiver2);
    
    struct Split{
        address[2] accounts;
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
        addMoney(splitters[msg.sender].accounts[0],msg.value/2);
        addMoney(splitters[msg.sender].accounts[1],msg.value/2);
        LogSplit(msg.value,msg.sender, splitters[msg.sender].accounts[0],splitters[msg.sender].accounts[1]);
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
    returns(address[2] accounts){
        return (splitters[creator].accounts);
    }
    
}




