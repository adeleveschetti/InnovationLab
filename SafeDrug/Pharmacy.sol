pragma solidity ^0.5.14;

import "./SalesManager.sol";
import "./SafeMath.sol";

/// @title Contratto della farmacia che acquista il medicinale (DrugItem)
/// @author Chiara Pavanati
/// @notice Uso della libreria SafeMath per prevenire errori di Overflow e Underflow 

contract Pharmacy is SalesManager {

    using SafeMath for uint256;
    
    event UpdateDrugInStorageCompleted (string drugName, uint drugSerial);
    
    string private id;
    string private name;
    string private streetAddress;
    string private cap;
    string private city;
    string private province;
    string private country;

    constructor (string memory _id, string memory _name, string memory _streetAddress, string memory _cap, string memory _city, string memory _province, string memory _country) public payable{
        // Inizializzazione proprietà oggetto DrugItem
        id = _id;
        name = _name;
        streetAddress = _streetAddress;
        cap = _cap;
        city = _city;
        province = _province;
        country = _country;
    }
    
    // Funzione chiamata dal buyer (Pharmacy) per acquistare un drug dal seller (Manufacturer)
    function buyDrug (address payable _seller, string memory _name) public onlyOwner () {
        require (msg.sender != _seller, "Pharmacy does not buy its own drugs!");
        Manufacturer manufacturerSeller = Manufacturer(_seller); // Prende il _seller
        require (manufacturerSeller.getPharmacyPermission(contractAddress) == true, "This Pharmacy has not permission to buy drugs from this Manufacturer!"); // La farmacia deve essere nella lista autorizzata di farmacie
        // Rimuovo il seriale dalla coda per evitare doppia vendita drug
        uint serialCode = manufacturerSeller.getSerialByName(_name);
        DrugItem drug = manufacturerSeller.getDrugAddressBySerial(serialCode); // Risale al drug del _seller partendo dal _serial
        require (drug != DrugItem(0x0), "Drug does not exist!");
        require (!(drug.getIsSold()), "Drug has already been sold!");
        uint priceToPay = drug.getPrice();
        address(_seller).transfer(priceToPay); // Viene trasferito l'importo del medicinale al Manufacturer (Seller) - * transfer è fornita da Solidity
        manufacturerSeller.processOrder(drug);
        emit PurchaseCompleted (_seller, serialCode);
    }

    function updateDrugInStorage (uint _serial, DrugItem _drug) external { // Funzione chiamata dal Manufacturer
        require (_drug.isOwner(), "Permission denied!");
        serialToDrugItem[_serial] = _drug;
        emit UpdateDrugInStorageCompleted (_drug.getName(), _drug.getSerial());
    }
}