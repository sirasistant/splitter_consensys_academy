var Splitter = artifacts.require("./Splitter.sol");

contract('Splitter', function (accounts) {
  var instance;

  beforeEach(function (done) {
    Splitter.deployed().then(function (_instance) { //deploy it
      instance = _instance;
      instance.register(accounts[1], accounts[2], { from: accounts[0] })//register a split
        .then(() => done());
    });
  })

  it("should register correctly the receivers", () => {
    var receivers = [accounts[2],accounts[3]];
    return instance.register(receivers[0],receivers[1],{from:accounts[1]}).then(()=>{
      return Promise.all(receivers.map((address,index)=>instance.splitters(accounts[1],index,{from:accounts[1]})))
      .then(receiversRead=>{
        assert.equal(receiversRead[0],receivers[0]);
        assert.equal(receiversRead[1],receivers[1]);
      })
    })
  });

  it("should split the balance sent", () => {
    var accountsToSplit = [accounts[1], accounts[2]];
    var balances = [];
    var amountToSend = 100;
    return Promise.all(accountsToSplit.map((account) => instance.balanceOf.call(account)))
      .then((_balances) => {
        balances = _balances;
        return instance.split({ from: accounts[0], value: amountToSend });
      }).then(() => Promise.all(accountsToSplit.map((account) => instance.balanceOf.call(account))))
      .then((newBalances) => {
        assert.equal(newBalances[0].toString(10), balances[0].add(amountToSend / 2).toString(10),"Did not split correctly to the first receiver");
        assert.equal(newBalances[1].toString(10), balances[1].add(amountToSend / 2).toString(10),"Did not split correctly to the second receiver");
      });
  });

  it("should kill itself", () => {
    var accountsToSplit = [accounts[1], accounts[2]];
    var balances = [];
    var amountToSend = 100;
    return instance.kill({ from: accounts[0] })
  });


});
