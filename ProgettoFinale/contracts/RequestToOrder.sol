pragma solidity ^0.5.6;

contract RequestToOrder {

    struct Offerta{
        uint idRichiesta;
        address payable offerente;
        uint prezzo;
        uint quality;
        bool vincente;
        bool terminata;
        string name;
        uint coordinate;
    }

    struct Richiesta{
        uint id;
        string name;
        uint quality;
        uint timestamp;
        bool attiva;
        uint quantity;
    }

    struct Ordine{
      uint idRichiesta;
      string name;
      uint quality;
      address fornitore;
      uint timestamp;
      bool spedito;
      bool checkCir;
    }

    struct Ingrediente{
      uint id;
      string name;
      uint cordinate;
      address fornitore;
      uint quantity;
    }

    //creatore del contratto, Cir in questo caso, sarà l'unico autorizzato ad accedere a determinate funzioni
    address public owner;
    address public contractAddress;


    //mapping delle offerte, uint indici delle offerte; bidder[uint]
    mapping(uint => Offerta) public bidder;
    uint public bidderCount;


    mapping(address => bool) public alreadyBidder;

    //mapping delle offerte vincitrici per ogni richiesta, indici delle richieste corrispondono idici offerte vincenti
    mapping(uint => uint) public winnerOf;


    //ad ogni intero corrisponde una richiesta, mappa delle richieste, request[uint]
    mapping(uint => Richiesta) public request;
    uint public requestCount;


    mapping(uint => bool) public activeRequest;
    uint public activeRequestCount;


    //almeno un'offerta per ogni Richiesta, stesso array di request che torna bool(superfluo)
    mapping(uint => bool) public existRequest;

    //mapping degli indici degli ordini, order[uint]
    mapping(uint => Ordine) public order;
    uint public orderCount;

    //mapping indici offerte e relativi value
    mapping(uint => uint) public valueOfBid;


    //da id richiesta e id ordine, indice richiesta corrisponde indice ordine, request[uint1]->order[uint2]
    mapping(uint => uint) public requestToOrder;

    mapping(uint => Ingrediente) public listOfIngredients;
    uint public ingredienteCount;
  

    constructor() public {
      owner= msg.sender;

      contractAddress = address(this);
      /////new try
      //addRequest("sale", 1);
   }


    //  event
        /*event offertEvent (
            uint indexed _requestId
        );*/

    //variabili locali con _
    function addRequest (string memory _name, uint _quality, uint _quantity) public              {
        require(msg.sender == owner, "message error: non sei owner");
        //require(_quality >=1 && _quality <=5, "message error: _idRichiesta > 0");

        requestCount++;
        activeRequestCount++;
        activeRequest[requestCount] = true;
        request[requestCount] = Richiesta(requestCount, _name, _quality, block.timestamp, true, _quantity);
    }


    function addOffer(uint _idRichiesta, uint _offerta, uint _quality, uint _coordinate) public{

      require(_idRichiesta > 0 && _idRichiesta <= requestCount);
      require(request[_idRichiesta].attiva);
      require(request[requestCount].attiva);

      bidderCount++;
      bidder[bidderCount] = Offerta(_idRichiesta, msg.sender, _offerta, _quality, false, false, request[_idRichiesta].name, _coordinate);
      existRequest[_idRichiesta] = true;

      //emit offertEvent(_idRichiesta);

}




// function addOfferPay(uint _idRichiesta, uint _offerta, uint _quality) public payable{

//   require(_idRichiesta > 0, "message error: _idRichiesta > 0");
//   require(_idRichiesta <= requestCount, "message error: _idRichiesta <= requestCount");
//   require(request[_idRichiesta].attiva, "message error: request[_idRichiesta].attiva");
//   require( _offerta >= request[_idRichiesta].quality, "message error: quality not enough");

//   bidderCount++;

//   valueOfBid[bidderCount]= msg.value;

//   bidder[bidderCount] = Offerta(_idRichiesta, msg.sender, _offerta, _quality, false, false, request[_idRichiesta].name);
//   existRequest[_idRichiesta] = true;

//   //emit offertEvent(_idRichiesta);

// }



    //chiudi richiesta, al momneto manuale ma si può automatizzare
    function endRequest(uint _idRichiesta) public{
      require(msg.sender == owner);
      require(_idRichiesta > 0 && _idRichiesta <= requestCount);
      require(request[_idRichiesta].attiva = true);


      uint vincitore = selectWinner(_idRichiesta);
      bidder[vincitore].vincente = true;
      winnerOf[_idRichiesta] = vincitore;


      request[_idRichiesta].attiva = false;
      activeRequest[_idRichiesta] = false;
      emettiOrdine(_idRichiesta, vincitore);
    }



    function selectWinner(uint _idRichiesta) private returns (uint){
      uint vincitore;
      uint prezzoMinore;
      bool primogiro=true;
      //si elaborano tutte le offerte relative a quella richiesta.
      //totalmente inefficiente, momentaneo

      for(uint i=1; i <= bidderCount; i++ ){

              //patch momentanea

        uint tmp = bidder[i].idRichiesta;

        if (request[tmp].attiva) {
        //se offerta relativa alla richiesta in esame
        if (bidder[i].idRichiesta == _idRichiesta){
                    bidder[i].terminata = true;

          if (bidder[i].quality >= request[tmp].quality){
          //se offerta migliore della precedente
          if (bidder[i].prezzo < prezzoMinore || primogiro==true){
            prezzoMinore = bidder[i].prezzo;
            if (primogiro == false){
              //se non vincente restituisce caparra
              bidder[vincitore].offerente.send(valueOfBid[vincitore]);
              valueOfBid[vincitore] = 0;
            }
            vincitore = i;
            primogiro=false;
          }
          else {
          bidder[i].offerente.send(valueOfBid[i]);
          valueOfBid[i]=0;
          }
          }
          //aggiornato:
          bidder[i].terminata = true;
          
        }
        }
      }
      return vincitore;
    }

    //al momento della chiusura della richiesta vengono elaborati i dati del vincitore e viene emesso l'ordine
    function emettiOrdine(uint _idRichiesta, uint _idOfferta) private {
      orderCount++;
      order[orderCount] = Ordine(_idRichiesta, request[_idRichiesta].name, bidder[_idOfferta].quality, bidder[_idOfferta].offerente, block.timestamp, false, false );
      requestToOrder[_idRichiesta] = orderCount;
      }

    //il fornitore riceve l'ordine, lo elabora e lo spedisce, vi accede tramite l'id della richiesta iniziale
    function checkFornitore (uint _idRichiesta) public {
      require(msg.sender == bidder[winnerOf[_idRichiesta]].offerente);
      uint idOrder = requestToOrder[_idRichiesta];
      order[idOrder].spedito = true;
    }

    //magazziniere, che per il momento ha lo stesso address dell'ufficio acquisti riceve la merce e certifica che sia tutto corretto
    function checkCir (uint _idRichiesta, bool _check) public {
      require(msg.sender == owner);
      uint idOrder = requestToOrder[_idRichiesta];
        if (_check == true){
        order[idOrder].checkCir = true;
        bidder[idOrder].offerente.send(valueOfBid[idOrder]);
        setStorage(order[idOrder].name, bidder[winnerOf[_idRichiesta]].coordinate , order[idOrder].fornitore, request[_idRichiesta].quantity);
      }
        else{
          //scatena evento reclamo..
        }
    }


    function setStorage (string  memory _nome, uint  _coordinate, address _fornitore, uint _quantity) public  {
      ingredienteCount++;
      listOfIngredients[ingredienteCount]=Ingrediente(ingredienteCount, _nome, _coordinate, _fornitore, _quantity);
      }



}
