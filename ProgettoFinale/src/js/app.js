const accounts = [
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
//var Tx = require('ethereumjs-tx');
//var privateKey = new Buffer('62b5c795399015044fd459d96c4fe99b1188243c9e3dd6adfe4c64eb98a2d6b6', 'hex')

App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
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

  initContract: function() {
    $.getJSON("Punto0.json", function(punto0) {
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
    listenForEvents: function() {
  /*
      App.contracts.Punto0.deployed().then(function(instance) {
        // Restart Chrome if you are unable to receive this event
        // This is a known issue with Metamask
        // https://github.com/MetaMask/metamask-extension/issues/2393
        instance.offertEvent({}, {
          fromBlock: 0,
          toBlock: 'latest'
        }).watch(function(error, event) {
          console.log("event triggered"/*,event*/ //)
  // Reload when a new vote is recorded
  /*App.render();
      });
    });
  },
*/
  render: function() {
    var punto0Instance;
    //var loader = $("#loader");
    var content = $("#content");
    //loader.show();
    //content.hide();

    // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);

        var index = addressToIndex(account)


        $("#indexFornitoreRequest").html("Portale Fornitore N."+index);
        $("#indexFornitoreOffer").html("Riepilogo Offerte Fornitore N."+index);
        $("#indexFornitoreOrder").html("Riepilogo Ordini Fornitore N."+index);

      }
    });

    // Load contract data richieste aggiornato!!!!!
    App.contracts.Punto0.deployed().then(function(instance) {
      punto0Instance = instance;
      return punto0Instance.requestCount();
    }).then(function(requestCount) {
      var requestResults = $("#requestResults");
      requestResults.empty();
      var requestXofferte = $("#requestXofferte");
      requestXofferte.empty();

      $("#requestRecap").html(" "+requestCount);

  
      for (var i = 1; i <= requestCount; i++) {
        punto0Instance.request(i).then(function(request) {
          var id = request[0];
          var name = request[1];
          var quality = request[2];
          var star = stampaStelle(quality);
          var attiva = request[4];
          var colore;
          var bottone;

          if (attiva){
            colore = '<td style="color:rgb(0, 104, 0)">Attiva</td>';
            bottone = '<button type="button" id="btmOfferta'+id+'" onclick="App.endRequest(' + id + '); return false;" class="btn-del ">Close Request</button>'
            var form1 = '<td><input type="number" min="0" class="form-destination2" id="prezzoOffer'+id+'" ></td>'
            var form2 = printForm(id);
            var bottoneOfferta = '<td><button type="submit" onclick="App.offer2(' + id + ');" class="btn-del ">MakeOffer</button></td>'
            requestXofferteTemplate = '<tr><th>'+id+'</th><td>'+name+'</td><td>'+star+'</td>'+form1+form2+bottoneOfferta+'</tr>'
            requestXofferte.append(requestXofferteTemplate);

          }
          else {
            colore = '<td style="color:rgb(189, 0, 0)">Terminata</td>';
            bottone = '<button type="button" id="btmOfferta'+id+'" onclick="App.endRequest(' + id + '); return false;" class="btn-del" disabled>Close Request</button>'
          }
          // Render candidate Result

          // var candidateTemplate = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + star + "</td><td>" + bottone + "</td><td>" + myForm1 + "</td><td>" + myForm2 + "</td></td>"

          var rowTemplate = '<tr><th>'+id+'</th><td>'+name+'</td><td>'+star+'</td>'+colore+'<td>'+bottone+'</td></tr>';

          //var candidateTemplate = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + quality + "</td></tr>"
          requestResults.append(rowTemplate);
          if (attiva == false){
            //document.getElementById("btmOfferta" + id).disabled = true;
          }
          // Render candidate ballot option
          //var candidateOption = "<option value='" + id + "' >" + name + "</ option>"
          //candidatesSelect.append(candidateOption);
        });
      }





      //return punto0Instance.voters(App.account);
    }).catch(function(error) {
      console.warn(error);
    });



/////////orderrrrrrr



// Load contract data ORDER
App.contracts.Punto0.deployed().then(function(instance) {
  punto0Instance = instance;
  return punto0Instance.orderCount();
}).then(function(orderCount) {
  var orderResults = $("#orderResults");
  orderResults.empty();
  var orderResultsPersonal = $("#orderResultsPersonal");
  orderResultsPersonal.empty();
  
  $("#orderRecap").html(" "+orderCount);


  for (var i = 1; i <= orderCount; i++) {
    punto0Instance.order(i).then(function(order) {
      var id = order[0];
      //console.log("  order  id:",id.toNumber())

      var nome = order[1];
      var quality = order[2];
      var star = stampaStelle(quality);

      var fornitore = order[3];
      var index = addressToIndex(fornitore);
      var fornitoreId = 'Fornitore N.' + index;

      var check1 = order[5];
      var check2 = order[6];

      var colore;
      var bottone;
      var bottone2;
      if (check1){
        bottone2 = '<td><button type="button" id="btmOfferta'+id+'" onclick="App.check1(' + id + '); return false;" class="btn-del" disabled>Check</button></td>'

        if (check2){
          bottone = '<td style="color:rgb(0, 104, 0)">Positivo</td>'
        }
        else {
          var bottone = '<td><button type="button" id="btmOfferta'+id+'" onclick="App.check2(' + id + '); return false;" class="btn-del ">Check</button></td>'

        }
        colore = '<td style="color:rgb(0, 104, 0)">Effettuata</td>';
      }
      else {
        bottone2 = '<td><button type="button" id="btmOfferta'+id+'" onclick="App.check1(' + id + '); return false;" class="btn-del ">Check</button></td>'
        colore = '<td style="color:rgb(189, 0, 0)">Non effettuata</td>';
        bottone = '<td><button type="button" id="btmOfferta'+id+'" onclick="App.check2(' + id + '); return false;" class="btn-del " disabled>Check</button></td>'
        //bottone = '<td style="color:rgb(0, 104, 0)">scemo</td>'

      }
      var rowTemplate2 = '<tr><th>'+id+'</th><td>'+nome+'</td><td>'+star+'</td><td>'+fornitoreId+'</td>'+colore+bottone+'</tr>';
      var rowTemplate3 = '<tr><th>'+id+'</th><td>'+nome+'</td><td>'+star+'</td><td>'+fornitoreId+'</td>'+colore+bottone2+'</tr>';

      var accountCorr = App.account;
      if (accountCorr == fornitore){

        orderResultsPersonal.append(rowTemplate3);
      }


    //  var star = stampaStelle(quality);

      // Render candidate Result






      //var candidateTemplate = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + quality + "</td></tr>"
      orderResults.append(rowTemplate2);

      // Render candidate ballot option
      //var candidateOption = "<option value='" + id + "' >" + name + "</ option>"
      //candidatesSelect.append(candidateOption);
    });
  }
  //return punto0Instance.voters(App.account);
}).catch(function(error) {
  console.warn(error);
});



// Load contract data offerte2!!!!!!
App.contracts.Punto0.deployed().then(function(instance) {
  punto0Instance = instance;
  return punto0Instance.bidderCount();
}).then(function(bidderCount) {
   var offerResults = $("#offerResults");
   offerResults.empty();
   var offerResultsPersonal = $("#offerResultsPersonal");
   offerResultsPersonal.empty();

   var winResults = $("#winResults");
   winResults.empty();

   var winResults = $("#winResults");
   $("#offerteRecap").html("  "+bidderCount);

   for (var i = 1; i <= bidderCount; i++) {
     punto0Instance.bidder(i).then(function(bidder) {

       var id = bidder[0];

       var nome = bidder[6];
      
       var fornitore = bidder[1];

       var prezzo = bidder[2];
       var quality = bidder[3];
       var star = stampaStelle(quality);

       var index = addressToIndex(fornitore);
       var fornitoreId = 'Fornitore N.' + index;
       var terminata = bidder[5];
       var vincente = bidder[4];

       var colore1;
       var colore2;

       var bottone;
       if (terminata){
        colore1 = '<td>Valutata</td>'
        if (vincente){
          colore2 = '<td style="color:rgb(0, 104, 0)">Vincente</td>'
          var rowTemplateWinner = '<tr><th>'+id+'</th><td>'+nome+'</td><td>'+star+'</td><td>'+prezzo+'</td><td>'+fornitoreId+'</td>'+colore2+'</tr>';
          winResults.append(rowTemplateWinner);
        }
        else {
         colore2 = '<td style="color:rgb(189, 0, 0)">Perdente</td>';
        }
      }
      else{
        colore1 = '<td style="color: rgb(224, 123, 8)">In attesa</td>'
        colore2 = '<td style="color: rgb(224, 123, 8)">In attesa</td>'

      }
  //     if (terminata){
  //       if (check2){
  //         bottone = '<td style="color:rgb(0, 104, 0)">Positivo</td>'
  //       }
  //       else {
  //         var bottone = '<td><button type="button" id="btmOfferta'+id+'" onclick="App.check2(' + id + '); return false;" class="btn-del ">Check</button></td>'

  //       }
  //       colore = '<td style="color:rgb(0, 104, 0)">Effettuata</td>';
  //     }
  //     else {
  //       colore = '<td style="color:rgb(189, 0, 0)">Non effettuato</td>';
  //       bottone = '<td><button type="button" id="btmOfferta'+id+'" onclick="App.check2(' + id + '); return false;" class="btn-del " disabled>Check</button></td>'
  //       //bottone = '<td style="color:rgb(0, 104, 0)">scemo</td>'

  //     }

         var rowTemplate3 = '<tr><th>'+id+'</th><td>'+nome+'</td><td>'+star+'</td><td>'+prezzo+'</td><td>'+fornitoreId+'</td>'+colore1+colore2+'</tr>';


         var accountCorr = App.account;
         if (accountCorr == fornitore){

         offerResultsPersonal.append(rowTemplate3);
       }


  //   //  var star = stampaStelle(quality);

  //     // Render candidate Result






  //     //var candidateTemplate = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + quality + "</td></tr>"
         offerResults.append(rowTemplate3);

  //     // Render candidate ballot option
  //     //var candidateOption = "<option value='" + id + "' >" + name + "</ option>"
  //     //candidatesSelect.append(candidateOption);
     });
   }
  // //return punto0Instance.voters(App.account);
}).catch(function(error) {
  console.warn(error);
});


    App.contracts.Punto0.deployed().then(function(instance) {
      punto0Instance = instance;
      var owner = punto0Instance.owner();

      var promise1 = Promise.resolve(owner);
          promise1.then(function(value) {
          //console.log('owner = ', value);
          $("#owner").html("Contract Owner: " + value);
          });

      return punto0Instance.contractAddress();
    }).then(function(contractAddress) {
      var contractAddress = punto0Instance.contractAddress();
      var promise1 = Promise.resolve(contractAddress);
      promise1.then(function(value) {
        //console.log('contractAddress = ', value);
        $("#contractAddress").html("Contract Address: " + value);
        document.getElementById("contractAddress").href="https://ropsten.etherscan.io/address/"+value; 

        // expected output: 123
      });
      //return punto0Instance.voters(App.account);
    }).catch(function(error) {
      console.warn(error);
    });



    // App.contracts.Punto0.deployed().then(function(instance) {
    //   punto0Instance = instance;
    //   return punto0Instance.owner();
    // }).then(function(owner) {
    //   var promise1 = Promise.resolve(owner);
    //   promise1.then(function(value) {
    //     console.log('owner = ', value);
    //     $("#owner").html("owner: " + value);
    //
    //     // expected output: 123
    //   });
    //
    // }).catch(function(error) {
    //   console.warn(error);
    // });


    //////////// Load contract data offerte
    // App.contracts.Punto0.deployed().then(function(instance) {
    //   punto0Instance = instance;
    //   console.log("dentro bidder");
    //   return punto0Instance.bidderCount();
    // }).then(function(bidderCount) {
    //   var offerResults = $("#offerResults");
    //   offerResults.empty();
    //   var offerResults = $("#offerResultsPersonal");
    //   offerResultsPersonal.empty();

    //   //var winResults = $("#winResults");
    //   //winResults.empty();
    //   console.log("dentro bidder, bidderCount");

    //   for (var i = 1; i <= bidderCount; i++) {
    //     punto0Instance.bidder(i).then(function(bidder) {
    //       var id = bidder[0];
    //       var fornitore = bidder[1];

    //       var index = addressToIndex(fornitore);
    //       var offerente = 'Fornitore N.' + index;


    //       var price = bidder[2];
    //       var quality = bidder[3];

    //       ///////////////////////////////////////////////////////
    //       var star = stampaStelle(quality);

    //       var vincente = bidder[4];
    //       if (vincente == true) {

    //         var winTemplate = "<tr><th>" + "Articolo"+id + "</th><td>" + offerente + "</td><td>" + price + "</td><td>" + star + "</td></tr>"
    //         winResults.append(winTemplate);

    //         document.getElementById("btmOfferta" + id).disabled = true;
    //       }
    //       console.log("bidderCount: ", bidderCount.toNumber());

    //       var bidTemplate = "<tr><th>" + "Articolo"+ id + "</th><td>" + offerente + "</td><td>" + price + "</td><td>" + star + "</td><td>" + vincente + "</td></tr>"
    //       offertResults.append(bidTemplate);



    //       ///////////////////////////////////////////////////////

    //       //  console.log("bidderCount: ", bidderCount.toNumber());



    //       //       var bidTemplate = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + price + "</td><td>" + quality + "</td></tr>"
    //       //       offertResults.append(bidTemplate);

    //       // Render candidate ballot option
    //       //var candidateOption = "<option value='" + id + "' >" + name + "</ option>"
    //       //requestSelect.append(candidateOption);
    //     });
    //   }
    //   //return punto0Instance.voters(App.account);
    // }).catch(function(error) {
    //   console.warn(error);
    // });


  },
  /*
    castVote: function() {
      var candidateId = $('#candidatesSelect').val();
      App.contracts.Punto0.deployed().then(function(instance) {
        return instance.vote(candidateId, { from: App.account });
      }).then(function(result) {
        // Wait for votes to update
        $("#content").hide();
        $("#loader").show();
      }).catch(function(err) {
        console.error(err);
      });
    }
  */
  check1: function(idRichiesta) {

    console.log("dentro check1");
    //check:...
    App.contracts.Punto0.deployed().then(function(instance) {

      console.log("App.account: ", App.account);
      return instance.checkFornitore(idRichiesta);
    }).then(function(result) {
      console.log("dentro check conferma");
      // Wait for update
    }).catch(function(err) {
      console.error(err);
    });


  },

  check2: function(idRichiesta) {

    console.log("dentro check1");
    //check:...
    App.contracts.Punto0.deployed().then(function(instance) {

      console.log("App.account: ", App.account);
      return instance.checkCir(idRichiesta,true);
    }).then(function(result) {
      console.log("dentro check conferma");
      // Wait for update
    }).catch(function(err) {
      console.error(err);
    });


  },


  offer: function() {

    console.log("dentro offer");
    console.log("dentro while");
    //offerta:...
    App.contracts.Punto0.deployed().then(function(instance) {

      console.log("App.account: ", App.account);
      return instance.addOfferPay(1, 0, 0, {
        value: 10000000000000
      }, {
        from: 0xA4767B3a3a8D23912045E551c41c4C559572Fb85
      });
    }).then(function(result) {
      console.log(web3.eth.accounts[0]);
      /*App.contracts.Punto0.deployed().then(function(instance) {


        console.log("App.account: ", App.account);
        return instance.addOfferPay(1, 10, 1, { from:  "0xA4767B3a3a8D23912045E551c41c4C559572Fb85", value: 1000000000000000000 });
      })*/
      // Wait for update
    }).catch(function(err) {
      console.error(err);
    });


  },






  offer2: function(id) {

    console.log("dentro offer2");

    var prezzo = document.getElementById('prezzoOffer' + id).value;
    var quality = document.getElementById('qualityOffer' + id).value;

    console.log("prezzo" + id, prezzo);
    console.log("quality" + id, quality);


    //offerta:...
    App.contracts.Punto0.deployed().then(function(instance) {
      var idRichiesta = id;

      console.log("idRichiesta: ", idRichiesta);
      return instance.addOfferPay(idRichiesta, prezzo, quality);
    }).then(function(result) {
      console.log(web3.eth.accounts[0]);




      /*App.contracts.Punto0.deployed().then(function(instance) {

      logica proof of autority in smart contract se implementato in proof of work


        console.log("App.account: ", App.account);
        return instance.addOfferPay(1, 10, 1, { from:  "0xA4767B3a3a8D23912045E551c41c4C559572Fb85", value: 1000000000000000000 });
      })*/
      // Wait for update
    }).catch(function(err) {
      console.error(err);
    });


  },

  requestDefault: function() {

    console.log("dentro requestDefault");

    //richiesta:...
    App.contracts.Punto0.deployed().then(function(instance) {


      return instance.addRequest("Altra Derrata", 1);
    }).then(function(result) {
      console.log(web3.eth.accounts[0]);

      /*App.contracts.Punto0.deployed().then(function(instance) {


        console.log("App.account: ", App.account);
        return instance.addOfferPay(1, 10, 1, { from:  "0xA4767B3a3a8D23912045E551c41c4C559572Fb85", value: 1000000000000000000 });
      })*/
      // Wait for update
    }).catch(function(err) {
      console.error(err);
    });


  },





  endRequest: function(idRichiesta) {

    console.log("dentro enRequestDefault");

    //richiesta:...
    App.contracts.Punto0.deployed().then(function(instance) {


      return instance.endRequest(idRichiesta);
    }).then(function(result) {

      /*App.contracts.Punto0.deployed().then(function(instance) {


        console.log("App.account: ", App.account);
        return instance.addOfferPay(1, 10, 1, { from:  "0xA4767B3a3a8D23912045E551c41c4C559572Fb85", value: 1000000000000000000 });
      })*/
      // Wait for update
    }).catch(function(err) {
      console.error(err);
    });


  },

  //document.getElementById("myBtn").disabled = true;

  endRequestDefault: function() {

    console.log("dentro enRequestDefault");

    //richiesta:...
    App.contracts.Punto0.deployed().then(function(instance) {


      return instance.endRequest(4);
    }).then(function(result) {

      /*App.contracts.Punto0.deployed().then(function(instance) {


        console.log("App.account: ", App.account);
        return instance.addOfferPay(1, 10, 1, { from:  "0xA4767B3a3a8D23912045E551c41c4C559572Fb85", value: 1000000000000000000 });
      })*/
      // Wait for update
    }).catch(function(err) {
      console.error(err);
    });


  },







  request: function() {

    console.log("dentro request");
    var nomeInserito = $('#nome').val();
    console.log("nome:", nomeInserito);
    var qualityInserita = $('#quality').val();



    //offerta:...
    App.contracts.Punto0.deployed().then(function(instance) {


      return instance.addRequest(nomeInserito, qualityInserita);
    }).then(function(result) {
      console.log(web3.eth.accounts[0]);

      App.contracts.Punto0.deployed().then(function(instance) {


        console.log("App.account: ", App.account);

      })
      // Wait for update
    }).catch(function(err) {
      console.error(err);
    });


  }






};

$(function() {
  $(window).load(function() {
    App.init();
  });
});


function stampaStelle(num){
  var stella= '';
  for (i=1; i <=num;i++){
    stella = stella+''+'&#9733;'

  }
  return stella;
}


function colorAttiva(val){
  var colore;
  if (val){
    colore = '<td style="color:rgb(0, 104, 0)">Attiva</td>';

  }
  else {
    colore = '<td style="color:rgb(189, 0, 0)">Terminata</td>';
  }
  return colore;
}





function printForm(idInput){
  var id = idInput;
  var form2='<td> <select name="quality" id="qualityOffer'+id+'"><option value="1">&#9733;</option>  <option value="2">&#9733;&#9733;</option><option value="3">&#9733;&#9733;&#9733;</option><option value="4">&#9733;&#9733;&#9733;&#9733;</option><option value="5">&#9733;&#9733;&#9733;&#9733;&#9733;</option></select></td>'
  return form2;
}

function addressToIndex(indirizzo) {
  var str1 = indirizzo.toUpperCase();
  for (i = 0; i < accounts.length; i++) {
    var str2 = accounts[i].toUpperCase();
    var n = str1.localeCompare(str2);
    if (n == 0) {
      var res;

      res = i;

      return res;
    }
  }
}

//
//
//
// function () {
//         var newRow = $("<tr>");
//         var cols = "";
//
//         cols += '<td><input type="text" class="form-control" name="name' + counter + '"/></td>';
//         cols += '<td><input type="text" class="form-control" name="mail' + counter + '"/></td>';
//         cols += '<td><input type="text" class="form-control" name="phone' + counter + '"/></td>';
//
//         cols += '<td><input type="button" class="ibtnDel btn btn-md btn-danger "  value="Delete"></td>';
//         newRow.append(cols);
//         $("table.order-list").append(newRow);
//         counter++;
//     });
