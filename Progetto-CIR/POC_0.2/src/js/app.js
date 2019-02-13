

//array con gli indirizzi degli account utilizzati(locale, non esportabili su altre macchine)
/*const accounts = [
  "0x79928210343048247a2aEE54Bf23Ae35C85bb17e",
  "0xA4767B3a3a8D23912045E551c41c4C559572Fb85",
  "0xc7bB40860cC741b13F22F04ec951122a74eF4935",
  "0xEfD298e6cD78E1eB72c4BBeF9E7ed06a56B4fE70",
  "0x449b97c4090C995C57F2AE6BCc33618D15482eCb",
  "0xEEF53D81A5fF43826ad9B2bCf3B00C0BFCae52F6",
  "0xB30C7D9F8594FB50DF1686361a405C38a8e956FB",
  "0xC77ad0859ebAa4aaAA977e723E53d6c973c1efcb",
  "0xCD0AA167Bd154ca071C43330F0Db78715d373d8c",
  "0x5189045d0820b314235603153D403FD38C569F5e",
  "0x4a2b1f972927D6Ef03C1aC736EdB1a09Ca7653f2"
];
*/
App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',

  //init Web3
  //Ethereum JavaScript API. web3.js is a collection of libraries which allow you 
  //to interact with a local or remote ethereum node, using a HTTP or IPC connection.
  init: function () {
    return App.initWeb3();
  },

  //init Web Provider
  //Web3 provider is a website running geth or parity node which talks to Ethereum network. 
  initWeb3: function () {
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  //init contract with truffle
  initContract: function () {
    $.getJSON("Punto0.json", function (punto0) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Punto0 = TruffleContract(punto0);
      // Connect provider to interact with contract
      App.contracts.Punto0.setProvider(App.web3Provider);
      console.log("initcontract");

      //  App.listenForEvents();

      return App.render();
    });
  },


  /*
  // Listen for events emitted from the contract
  listenForEvents: function () {

    App.contracts.Punto0.deployed().then(function (instance) {
      // Restart Chrome if you are unable to receive this event
      // This is a known issue with Metamask
      // https://github.com/MetaMask/metamask-extension/issues/2393
      instance.offertEvent({}, {
        fromBlock: 0,
        toBlock: 'latest'
      }).watch(function (error, event) {
        console.log("event triggered", event);
        App.render();
      });
    });
  },
  */

  render: function () {
    var punto0Instance;
    var content = $("#content");
    // Load account data
    web3.eth.getCoinbase(function (err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });

    // Load contract data, request
    App.contracts.Punto0.deployed().then(function (instance) {
      punto0Instance = instance;
      return punto0Instance.requestCount();
    }).then(function (requestCount) {
      var requestResults = $("#requestResults");
      requestResults.empty();

      for (var i = 1; i <= requestCount; i++) {
        punto0Instance.request(i).then(function (request) {
          var id = request[0];
          var name = request[1];
          var quality = request[2];
          // Render request Result with table and relative button and form
          // codice estremamente brutto e non funzionale, a solo scopo di test
          console.log("requestCount: ", requestCount.toNumber());

          var myForm1 = '<input type="text" id="prezzo' + id + '" >'
          var bottone = '<button type="submit" id="btmOfferta' + id + '"  onclick="App.offer2(' + id + '); return false;" class="btn btn-primary">offer</button>'
          var myForm2 = '<input type="text" id="quality' + id + '" >'

          var candidateTemplate = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + quality + "</td><td>" + bottone + "</td><td>" + myForm1 + "</td><td>" + myForm2 + "</td></td>"
          requestResults.append(candidateTemplate);
        });
      }
      //return punto0Instance.voters(App.account);
    }).catch(function (error) {
      console.warn(error);
    });


    // Load contract data offerte
    App.contracts.Punto0.deployed().then(function (instance) {
      punto0Instance = instance;
      console.log("dentro bidder");
      return punto0Instance.bidderCount();
    }).then(function (bidderCount) {
      var offertResults = $("#offertResults");
      offertResults.empty();

      var winResults = $("#winResults");
      winResults.empty();
      for (var i = 1; i <= bidderCount; i++) {
        punto0Instance.bidder(i).then(function (bidder) {
          var id = bidder[0];
          var name = bidder[1];
          var price = bidder[2];
          var quality = bidder[3];
          var vincente = bidder[5];
          if (vincente == true) {
            console.log("dentro bidder if");
            var winTemplate = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + price + "</td><td>" + quality + "</td></tr>"
            winResults.append(winTemplate);
            //superfluo, il disabled perchè comunque genererebbe un'eccezione nel codice contratto
            document.getElementById("btmOfferta" + id).disabled = true;
          }
          console.log("bidderCount: ", bidderCount.toNumber());

          var bidTemplate = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + price + "</td><td>" + quality + "</td><td>" + vincente + "</td></tr>"
          offertResults.append(bidTemplate);
        });
      }
      //return punto0Instance.voters(App.account);
    }).catch(function (error) {
      console.warn(error);
    });


  },
  //funzione che inserisce un'offerta di default, a scopo di test
  offer: function () {
    console.log("dentro offer");
    //offerta
    App.contracts.Punto0.deployed().then(function (instance) {
      console.log("App.account: ", App.account);
      return instance.addOfferPay(1, 0, 0, { value: 1000000000000000000 });
      //value = 1 eth
    }).then(function (result) {
      console.log(web3.eth.accounts[0]);
      
      // Wait for update
    }).catch(function (err) {
      console.error(err);
    });


  },
  //funzione che inserisce offerta con i paramentri in input
  offer2: function (id) {
    //id della richiesta
    console.log("dentro offer2");

    var prezzo = document.getElementById('prezzo' + id).value;
    var quality = document.getElementById('quality' + id).value;

    console.log("prezzo" + id, prezzo);
    console.log("quality" + id, quality);

    //offerta:...
    App.contracts.Punto0.deployed().then(function (instance) {
      var idRichiesta = id;

      console.log("idRichiesta: ", idRichiesta);
      return instance.addOfferPay(idRichiesta, prezzo, quality, { value: 1000000000000000000 });
      //value = 1 eth
    }).then(function (result) {
      console.log(web3.eth.accounts[0]);

      // Wait for update
    }).catch(function (err) {
      console.error(err);
    });

  },

  //aggiunge richiesta default, scopo di test
  requestDefault: function () {

    console.log("dentro requestDefault");
    //richiesta:...
    App.contracts.Punto0.deployed().then(function (instance) {
      return instance.addRequest("Altra Derrata", 1);
    }).then(function (result) {
      console.log(web3.eth.accounts[0]);
    }).catch(function (err) {
      console.error(err);
    });
  },


  //chiude richiesta con id 1, non prende input, scopo di test
  endRequestDefault: function () {
    console.log("dentro enRequestDefault");

    App.contracts.Punto0.deployed().then(function (instance) {
      return instance.endRequest(1);
    }).then(function (result) {
      // Wait for update
    }).catch(function (err) {
      console.error(err);
    });

  },

  //aggunge richiesta con specifici paramentri in input
  request: function () {

    console.log("dentro request");
    var nomeInserito = $('#nome').val();
    console.log("nome:", nomeInserito);
    var qualityInserita = $('#quality').val();
    //richiesta:...
    App.contracts.Punto0.deployed().then(function (instance) {
      return instance.addRequest(nomeInserito, qualityInserita);
    }).then(function (result) {
      console.log(web3.eth.accounts[0]);

      // Wait for update
    }).catch(function (err) {
      console.error(err);
    });
  }
};

$(function () {
  $(window).load(function () {
    App.init();
  });
});
