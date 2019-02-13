/*var Punto0 = artifacts.require('./Punto0.sol')
Punto0.setProvider(web3.currentProvider);
/*
Punto0.deployed().then(function(instance) {
  var app = instance;
  console.log("primo log");
  return app.prova1;
}).then(function(app.prova1){
  console.log("secondo log");

  var l = prova1
  console.log(l);
}).catch(function(error) {
  console.error(error);
})


module.exports = function (callback) {
  var app;
  Punto0.deployed().then(function(deployed){
    app = deployed;
    // Here we are sure `ss` is initialized and it is safe to call `.GetHash()`
    console.log("primo");

    app.methods.prova().call().then(console.log)

    console.log("primo");
    });
  // This code 'might' be excuted before the code inside `.then()`
  // ss.GetHash.call("sal");
}



var Punto0 = artifacts.require("./Punto0.sol");
let contract = require('truffle-contract');

 contract("Punto0", function(accounts) {
   var Punto0Instance;
   console.log("0000000000");

   it("zeroStep", function() {
     console.log("1111111");

     return Punto0.deployed().then(function(instance) {
       console.log("2222222");

       return instance.requestCount();
     }).then(function(count) {
       console.log("valore di count:    ", count);
     });
   });
 /*
   it("it initializes the candidates with the correct values", function() {
     return Punto0.deployed().then(function(instance) {
       Punto0Instance = instance;
       return Punto0Instance.candidates(1);
     }).then(function(candidate) {
       assert.equal(candidate[0], 1, "contains the correct id");
       assert.equal(candidate[1], "Candidate 1", "contains the correct name");
       assert.equal(candidate[2], 0, "contains the correct votes count");
       return Punto0Instance.candidates(2);
     }).then(function(candidate) {
       assert.equal(candidate[0], 2, "contains the correct id");
       assert.equal(candidate[1], "Candidate 2", "contains the correct name");
       assert.equal(candidate[2], 0, "contains the correct votes count");
     });
   });

   it("allows a voter to cast a vote", function() {
     return Punto0.deployed().then(function(instance) {
       Punto0Instance = instance;
       candidateId = 1;
       return Punto0Instance.vote(candidateId, { from: accounts[0] });
     }).then(function(receipt) {
       assert.equal(receipt.logs.length, 1, "an event was triggered");
       assert.equal(receipt.logs[0].event, "votedEvent", "the event type is correct");
       assert.equal(receipt.logs[0].args._candidateId.toNumber(), candidateId, "the candidate id is correct");
       return Punto0Instance.voters(accounts[0]);
     }).then(function(voted) {
       assert(voted, "the voter was marked as voted");
       return Punto0Instance.candidates(candidateId);
     }).then(function(candidate) {
       var voteCount = candidate[2];
       assert.equal(voteCount, 1, "increments the candidate's vote count");
     })
   });

   it("throws an exception for invalid candiates", function() {
     return Punto0.deployed().then(function(instance) {
       Punto0Instance = instance;
       return Punto0Instance.vote(99, { from: accounts[1] })
     }).then(assert.fail).catch(function(error) {
       assert(error.message.indexOf('revert') >= 0, "error message must contain revert");
       return Punto0Instance.candidates(1);
     }).then(function(candidate1) {
       var voteCount = candidate1[2];
       assert.equal(voteCount, 1, "candidate 1 did not receive any votes");
       return Punto0Instance.candidates(2);
     }).then(function(candidate2) {
       var voteCount = candidate2[2];
       assert.equal(voteCount, 0, "candidate 2 did not receive any votes");
     });
   });

   it("throws an exception for double voting", function() {
     return Punto0.deployed().then(function(instance) {
       Punto0Instance = instance;
       candidateId = 2;
       Punto0Instance.vote(candidateId, { from: accounts[1] });
       return Punto0Instance.candidates(candidateId);
     }).then(function(candidate) {
       var voteCount = candidate[2];
       assert.equal(voteCount, 1, "accepts first vote");
       // Try to vote again
       return Punto0Instance.vote(candidateId, { from: accounts[1] });
     }).then(assert.fail).catch(function(error) {
       assert(error.message.indexOf('revert') >= 0, "error message must contain revert");
       return Punto0Instance.candidates(1);
     }).then(function(candidate1) {
       var voteCount = candidate1[2];
       assert.equal(voteCount, 1, "candidate 1 did not receive any votes");
       return Punto0Instance.candidates(2);
     }).then(function(candidate2) {
       var voteCount = candidate2[2];
       assert.equal(voteCount, 1, "candidate 2 did not receive any votes");
     });
   });
   
 });*/
