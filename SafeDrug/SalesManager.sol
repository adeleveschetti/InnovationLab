pragma solidity ^0.5.14;

import "./Manufacturer.sol";
import "./DrugItem.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./Queue.sol";

/// @title Contratto che gestisce la vendita del medicinale (DrugItem)
/// @author Chiara Pavanati
/// @notice Uso della libreria SafeMath per prevenire errori di Overflow e Underflow 

contract SalesManager is Ownable {
 
    using SafeMath for uint256;
    
    event testFallbackFunction ();
    event PurchaseCompleted (address from, uint serial);
    event RefundCompleted (address buyer, uint priceToRefund);
    
    address payable public contractAddress = address(this);

    mapping (uint => DrugItem) public serialToDrugItem; // Mapping da seriale a contratto medicinale (DrugItem)
    mapping (string => Queue) public nameToSerialQueue; // Mapping da nome del medicinale a uno dei seriali

    /* Funzione di fallback (payable)  
    Intercetta in automatico gli ether trasferiti 
    e li deposita nel conto (Funziona sia per Manufacturer che per Pharmacy) */
    function () external payable { 
       emit testFallbackFunction ();
    }
    
    // Rimborso wei al buyer (Pharmacy) da parte del seller (Manufacturer)
    function refund (address payable _buyer, DrugItem _drug) external {
        serialToDrugItem[_drug.getSerial()] = DrugItem(0x0); // Azzero il mapping per eliminare il drug reso 
        uint priceToRefund = _drug.getPrice();
        address(_buyer).transfer(priceToRefund);
        emit RefundCompleted(_buyer, priceToRefund);
    }

    function getBalance () public view returns (uint) {
        return contractAddress.balance;
    }

    function getDrugInfoBySerial (uint _serial) public view returns (address, address, string memory, uint, uint, uint, uint, uint, uint, uint) {
        DrugItem drug = serialToDrugItem[_serial];
        return (drug.contractAddress(), drug.getFirstOwner(), drug.getName(), drug.getSerial(), drug.getIdealTemperature(), drug.getTemperatureTolerance(), drug.getProductionDate(), drug.getExpiryDate(), drug.getMaxDeliveryDays(), drug.getPrice());
    }

    function getDrugAddressBySerial (uint _serial) public view returns (DrugItem) {
        DrugItem drug = serialToDrugItem[_serial];
        return (drug);
    }
    
    function getSerialByName (string memory _name) public view returns (uint) {
        return nameToSerialQueue[_name].getFirstElement();
    }
}