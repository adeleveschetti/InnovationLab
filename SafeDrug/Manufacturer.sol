pragma solidity ^0.5.14;

import "./Pharmacy.sol";
import "./DrugItem.sol";
import "./SalesManager.sol";
import "./Distributor.sol";
import "./SafeMath.sol";
import "./Queue.sol";

/// @title Contratto dell'azienda farmaceutica che crea il medicinale (DrugItem)
/// @author Chiara Pavanati
/// @notice Uso della libreria SafeMath per prevenire errori di Overflow e Underflow 

contract Manufacturer is SalesManager {
    
    using SafeMath for uint256;
    
    event RemovalFromApprovedDistributors (address _distributor);
    event OrderReceived (string drugName, uint drugSerial, address drugBuyer);

    string private id;
    string private name;
    string private streetAddress;
    string private cap;
    string private city;
    string private province;
    string private country;
    uint private maxDeliveryFailures; // Numero massimo fallimenti di consegna del Distributor
    uint public drugsCounter;

    // Uso di mapping al posto di array per risparmiare gas
    mapping(uint => bool) private serialToUsed; // Registro che dato un seriale dice se è già stato usato oppure no
    mapping(address => bool) public approvedPharmacies; // Registro di Pharmacies autorizzate all'acquisto
    mapping(address => bool) public approvedDistributors; // Registro di Distributors autorizzati alla presa in carico 
    mapping(uint => address payable) public serialToBuyer; // Registro che dato il seriale del drug restituisce l'indirizzo del buyer

    // Modificatori per regolare le autorizzazioni
    modifier onlyApprovedPharmacies (address pharmacyAddress) {
        require(approvedPharmacies[pharmacyAddress], "You are not in approved Pharmacies whitelist!");
        _;
    }
    modifier onlyApprovedDistributors (address distributorAddress) {
        require(approvedDistributors[distributorAddress], "You are not in approved Distributors whitelist!");
        _;
    }

    // Inizializzazione attributi del Manufacturer
    constructor (string memory _id, string memory _name, string memory _streetAddress, string memory _cap, string memory _city, string memory _province, string memory _country, uint _maxDeliveryFailures) public payable {
        id = _id;
        name = _name;
        streetAddress = _streetAddress;
        cap = _cap;
        city = _city;
        province = _province;
        country = _country;
        maxDeliveryFailures = _maxDeliveryFailures;
        drugsCounter = 0;
    }

    // CREAZIONE MEDICINALE da parte del Manufacturer
    function createDrug (string memory _name, string memory _format, string memory _activeAgents, uint _dosage, uint _idealTemperature, uint _temperatureTolerance, uint _yearBeforeExpiration, uint _maxDeliveryDays, uint _price) public onlyOwner () returns (uint) {
        // Controlli validità campi medicinale (drug)
        require (bytes(_name).length != 0, "Name field is not valid!"); 
        require (bytes(_format).length !=0, "Format field is not valid!"); 
        require (bytes(_activeAgents).length !=0, "activeAgents field is not valid"); 
        require (_dosage > 0, "Dosage field must be greater than 0!");
        require (_yearBeforeExpiration > 0, "yearBeforeExpiration must be greater than 0!");
        require (_maxDeliveryDays > 0, "maxDeliveryDays must be greater than 0!");
        require (_price > 0, "price must be greater than 0!");
        uint serialCode = calcolateSerialCode(); // Calcolo seriale medicinale 
        require (isValidSerial(serialCode), "Serial is already in use!"); 
        // Deploy di un nuovo drug
        DrugItem drug = new DrugItem (_name, serialCode, _format, _activeAgents, _dosage, _idealTemperature, _temperatureTolerance, _yearBeforeExpiration, _maxDeliveryDays, _price); // Deploy di un nuovo contratto DrugItem
        drugsCounter = SafeMath.add(drugsCounter, 1);
        if (nameToSerialQueue[_name] == Queue(0x0)) { // Se è il 1° drug che sto creando con quel nome
            Queue serialQueue = new Queue (); // allora devo fare deploy della coda dei seriali corrispondenti
            nameToSerialQueue[_name] = serialQueue;
        }
        nameToSerialQueue[_name].enqueue(uint(serialCode)); // Aggiungo in coda il seriale del drug creato
        serialToDrugItem[drug.getSerial()] = drug; // Aggiorno il mapping inserendo il valore drug con chiave serial
        serialToUsed[drug.getSerial()] = true; // Aggiorno il mapping con true perché ho usato il seriale
        return (serialCode);
    }

    function processOrder (DrugItem _drug) public {
        _drug.setSold(true); // La Pharmacy "ordina" alla Manufacturer di settare il medicinale come "isSold"
        address drugBuyer = serialToBuyer[_drug.getSerial()] = msg.sender; // Si crea l'associazione tra prodotto (Drug) e acquirente (Pharmacy)
        uint drugSerial = nameToSerialQueue[_drug.getName()].dequeue();
        emit OrderReceived (_drug.getName(), drugSerial, drugBuyer);
    }
    
    // AVVIO SPEDIZIONE: Il Manufacturer affida il medicinale al Distributor
    function giveDrugToDistributor (uint _serial, address payable _distributor, uint _weight, uint _temperature) public onlyOwner () onlyApprovedDistributors (_distributor) { 
        require (getDistributorPermission(_distributor) == true, "This Distributor has not permission to take drugs from this Manufacturer!"); // Il corriere deve essere nella lista autorizzata
        DrugItem drug = serialToDrugItem[_serial];
        require (drug != DrugItem (0x0), "Serial does not match any drug!"); // Controllo che il medicinale con quel seriale esista
        require (msg.sender != _distributor, "Manufacturer and Distributor must have two different addresses!");
        Distributor distributorCourier = Distributor(_distributor);
        address payable to = serialToBuyer[_serial];
        distributorCourier.takenInCharge(contractAddress, to, drug, _weight, _temperature); // Il distributor prende in carico il medicinale
    }

    // TRASFERIMENTO MEDICINALE dal Manufacturer alla Pharmacy
    function transferDrug (DrugItem _drug, Pharmacy _to) public {
        require (msg.sender != _to.contractAddress(), "Pharmacy does not buy its own drugs!");
        require (_drug.getIsSold(), "Drug has not been sold!");
        require (serialToBuyer[_drug.getSerial()] == _to.contractAddress(), "This Pharmacy has not buy this drug!");
        _drug.transferOwnership(_to.contractAddress());
        serialToDrugItem[_drug.getSerial()] = DrugItem(0x0); // Aggiornamento magazzino del Manufacturer (Rimozione drug)
        _to.updateDrugInStorage(_drug.getSerial(), _drug); // Aggiornamento magazzino della Pharmacy (Inserimento drug)
    }

    function isValidSerial (uint _serial) public view returns (bool) {
        return (serialToUsed[_serial] == false); // Il seriale è valido se il controllo del registro dei seriali usati restituisce false
    }

    function checkDistributorFailures(address payable _distributor) public returns (bool) {
        Distributor distributorCourier = Distributor(_distributor);
        if(distributorCourier.getDeliveryFailuresCounter() > maxDeliveryFailures){
            approvedDistributors[_distributor] = false; 
            emit RemovalFromApprovedDistributors (_distributor);
        }
        return approvedDistributors[_distributor];
    }
    
    // Calcolo seriale da keccak dell'id del Manufacturer + now + counter medicinali creati
    function calcolateSerialCode () private view returns (uint) {
        uint hashManufacturerId = uint(keccak256(abi.encode(id)));
        uint serialCode = SafeMath.add(hashManufacturerId,now);
        serialCode = SafeMath.add(serialCode, drugsCounter);
        return serialCode;
    }

    function getPharmacyPermission(address _pharmacy) public view returns (bool) {
        return approvedPharmacies[_pharmacy];
    }
    
    function getDistributorPermission(address _distributor) public view returns (bool) {
        return approvedDistributors[_distributor];
    }

    function setMaxDeliveryFailures (uint _maxDeliveryFailures) public onlyOwner () {
        maxDeliveryFailures = _maxDeliveryFailures;
    }

    function setPharmacyPermission(address _pharmacy, bool isAllowed) public onlyOwner () {
        approvedPharmacies[_pharmacy] = isAllowed;
    }

    function setDistributorPermission (address _distributor, bool isAllowed) public onlyOwner () {
       approvedDistributors[_distributor] = isAllowed;
    }
}