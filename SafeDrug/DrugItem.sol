pragma solidity ^0.5.14;

import "./Ownable.sol";
import "./SafeMath.sol";

/// @title Contratto che contiene le informazioni di un oggetto DrugItem
/// @author Chiara Pavanati
/// @notice Uso della libreria SafeMath per prevenire errori di Overflow e Underflow 

contract DrugItem is Ownable {

    using SafeMath for uint256;
    
    event NewDrugItem (address contractAddress, address firstOwner, string name, uint serial);
    
    address public contractAddress;
    address private firstOwner; // Indirizzo dell'azienda che ha creato il medicinale
    string private name;
    string private format; // Formato medicinale (Es. Compresse, soluzione orale...)
    string private activeAgents; // Principi attivi contenuti
    uint private serial; // ID univoco del medicinale
    uint private dosage; // Dosaggio medicinale in grammi
    uint private idealTemperature;
    uint private temperatureTolerance;
    uint private productionDate;
    uint private expiryDate;
    uint private maxDeliveryDays; // Giorni massimi medicinale in viaggio
    uint private price; // In wei
    bool private isSold;

    modifier onlyFirstOwner () {
        require (isFirstOwner());
        _;
    }
    
    // Costruttore chiamato da Manufacturer che è il creatore del farmaco
    constructor (string memory _name, uint _serial, string memory _format, string memory _activeAgents, uint _dosage, uint _idealTemperature, uint _temperatureTolerance, uint _yearBeforeExpiration, uint _maxDeliveryDays, uint _price) public { 
        uint _productionDate = now; 
        _yearBeforeExpiration = SafeMath.mul(_yearBeforeExpiration, 365 days); // years è stato deprecato nelle nuove versioni di Solidity, perciò converto il numero di anni in giorni
        uint _expiryDate = SafeMath.add(_productionDate, _yearBeforeExpiration); // La data di scadenza è di tot anni dalla data di produzione
        // Inizializzazione proprietà oggetto DrugItem
        contractAddress = address(this);
        firstOwner = msg.sender;
        name = _name;
        serial = _serial;
        format = _format;
        activeAgents = _activeAgents;
        dosage = _dosage;
        idealTemperature = _idealTemperature;
        temperatureTolerance = _temperatureTolerance;
        productionDate = _productionDate;
        expiryDate = _expiryDate;
        maxDeliveryDays = SafeMath.mul(_maxDeliveryDays, 1 days);
        /* wei è la più piccola unità di ether, 1 Ether = 1,000,000,000,000,000,000 Wei (10^18) 
        Nella creazione del medicinale il prezzo è inserito in Gwei, qui sotto verrà convertito in wei per comodità */
        price = SafeMath.mul(_price, 1000000000 wei); 
        isSold = false;
        emit NewDrugItem (contractAddress, firstOwner, name, serial);
    }
    
    function isFirstOwner () private view returns (bool) {
        return (msg.sender == firstOwner);
    }

    function isValidTemperature (uint _actualTemperature) public view returns (bool) {
        uint upperTemperatureBound = SafeMath.add(idealTemperature, temperatureTolerance); // Limite superiore dell'intervallo di tolleranza della temperatura
        uint lowerTemperatureBound = SafeMath.sub(idealTemperature, temperatureTolerance); // Limite inferiore dell'intervallo di tolleranza della temperatura
        return (_actualTemperature <= upperTemperatureBound && _actualTemperature >= lowerTemperatureBound);
    }
    
    function isExpired () public view returns (bool) {
        return (expiryDate <= now);
    }
    
    // *** Funzioni che restituiscono gli attributi del medicinale ***

    function getFirstOwner () public view returns (address) {
        return firstOwner;
    }
    
    function getName () public view returns (string memory) {
        return name;
    }
    
    function getSerial () public view returns (uint) {
        return serial;
    }

    function getFormat () public view returns (string memory) {
        return format;
    }
    
    function getActiveAgents () public view returns (string memory) {
        return activeAgents;
    }

    function getDosage () public view returns (uint) {
        return dosage;
    }
    
    function getIdealTemperature () public view returns (uint) {
        return idealTemperature;
    }
    
    function getTemperatureTolerance () public view returns (uint) {
        return temperatureTolerance;
    }
    
    function getProductionDate () public view returns (uint) {
        return productionDate;
    }
    
    function getExpiryDate () public view returns (uint) {
        return expiryDate;
    }
    
    function getMaxDeliveryDays () public view returns (uint) {
        return maxDeliveryDays;
    }

    function getPrice () public view returns (uint) {
        return price;
    }
    
    function getIsSold () public view returns (bool) {
        return (isSold);
    }
    
    // *** Modifiche al medicinale consentite solo al produttore (Manufacturer) quindi onlyFirstOwner ***

    function setName (string memory newName) public onlyFirstOwner () {
        name = newName;
    }

    function setFormat (string memory newFormat) public onlyFirstOwner () {
        format = newFormat;
    }
    
    function setActiveAgents (string memory newActiveAgents) public onlyFirstOwner () {
        activeAgents = newActiveAgents;
    }
    
    function setDosage (uint newDosage) public onlyFirstOwner () {
        dosage = newDosage;
    }

    function setIdealTemperature (uint newIdealTemperature) public onlyFirstOwner () {
        idealTemperature = newIdealTemperature;
    }

    function setTemperatureTolerance (uint newTemperatureTolerance) public onlyFirstOwner () {
        temperatureTolerance = newTemperatureTolerance;
    }

    function setMaxDeliveryDays (uint newMaxDeliveryDays) public onlyFirstOwner () {
        maxDeliveryDays = newMaxDeliveryDays;
    }
    
    function setSold(bool _isSold) public onlyFirstOwner () {
        isSold = _isSold;
    }
}