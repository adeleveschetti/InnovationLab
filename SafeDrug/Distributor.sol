pragma solidity ^0.5.14;

import "./Manufacturer.sol";
import "./Pharmacy.sol";
import "./DrugItem.sol";
import "./Parcel.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

/// @title Contratto del distributore che prende in carico e consegna il medicinale (DrugItem)
/// @author Chiara Pavanati
/// @notice Uso della libreria SafeMath per prevenire errori di Overflow e Underflow 

contract Distributor is Ownable {

	using SafeMath for uint256;

    event TakenInChargeCompleted (uint _trackingCode, address payable _from, address payable _to);
    event DeliveryCompleted (uint _trackingCode, address payable manufacturerSeller, address payable pharmacyBuyer);
    event DistributorRefundCompleted (address _seller, uint _serial, uint _price);
    event testFallbackFunction ();

    address payable public contractAddress;
	string private id;
	string private name;
	uint private deliveryFailuresCounter; // Numero fallimenti di consegna del corriere

	mapping (uint => Parcel) public trackingCodeToParcel; // Mapping che a partire dal codice di tracking del drug, resistuisce un oggetto parcel
    
    function () external payable {
        emit testFallbackFunction ();
    }
    
	constructor (string memory _id, string memory _name) public {
		contractAddress = address (this);
		id = _id;
		name = _name;
		deliveryFailuresCounter = 0;
	}

	// PRESA IN CARICO del medicinale da parte del Distributor
	function takenInCharge (address payable _from, address payable _to, DrugItem _drug, uint _weight, uint _temperature) external {
	    Manufacturer manufacturerSeller = Manufacturer (_from); // Prende il mittente (from) del parcel
	    uint trackingCode = uint(keccak256(abi.encode(_drug.getSerial()))); // Calcolo codice di tracking a partire dal seriale del drug
		require (_drug.getIsSold() == true, "Drug must be bought!"); // Il pacco deve già essere stato pagato
		require (isTakenInCharge(trackingCode) == false, "Parcel has already taken in charge!"); // Il pacco non deve essere già stato preso in carico
		require (_weight > 0, "Weight must be greater than 0!"); // Il pacco deve pesare più di 0
		if ( !(_drug.isValidTemperature(_temperature)) || (_drug.isExpired() )) { // Se la temperatura non è valida e il medicinale è scaduto
			manufacturerSeller.refund( _to, _drug); // rimborsa il buyer
		}
		else { // Avvia la spedizione del drug al buyer
			Parcel parcel = new Parcel (_from, _to, trackingCode, _weight, _drug); // Deploy di un nuovo contratto parcel
			trackingCodeToParcel[trackingCode] = parcel; // Salvo il parcel nel mapping
			emit TakenInChargeCompleted (trackingCode, _from, _to);
		}
	}

	// CONSEGNA MEDICINALE alla farmacia (buyer) da parte del Distributor
	function delivery (uint _trackingCode, uint _weight, uint _temperature) public onlyOwner () {
	    require (isTakenInCharge(_trackingCode) == true, "Parcel has not been taken in charge!");
		require (isDelivered(_trackingCode) == false, "Parcel has already delivered!");
		Parcel parcel = trackingCodeToParcel[_trackingCode]; // Pacco che deve essere consegnato al buyer
		Manufacturer manufacturerSeller = Manufacturer (parcel.getFrom()); // Prende il mittente (from) del parcel
		uint deliveryDate = now;
		uint daysInDistributor = SafeMath.sub(deliveryDate, parcel.getTakenInChargeDate());
		DrugItem drug = parcel.getParcelContent();
		// Se condizioni non rispettate il manufacturer AVVIA IL RIMBORSO alla Pharmacy
		if ( (parcel.getWeight() != _weight) || !(drug.isValidTemperature(_temperature)) || (drug.isExpired()) || (daysInDistributor > drug.getMaxDeliveryDays()) ) { 
			deliveryFailuresCounter = SafeMath.add(deliveryFailuresCounter, 1); // Incremento contatore fallimenti consegna
			trackingCodeToParcel[_trackingCode] = Parcel (0x0); // Eliminazione del pacco
			parcel.getFrom().transfer(drug.getPrice()); // parcel.getFrom() prende l'indirizzo del Manufacturer, che viene rimborsato del costo del medicinale dal Distributor
			manufacturerSeller.checkDistributorFailures(contractAddress);
			emit DistributorRefundCompleted (manufacturerSeller.contractAddress(), drug.getSerial(), drug.getPrice());
			manufacturerSeller.refund(parcel.getTo(), drug);
		}
		// altrimenti il manufacturer AVVIA LA CONSEGNA e trasferisce il medicinale
		else { 
		    Pharmacy pharmacyBuyer = Pharmacy (parcel.getTo());
			parcel.setDeliveryDate(deliveryDate);
			manufacturerSeller.transferDrug(drug, pharmacyBuyer); 
		    emit DeliveryCompleted (_trackingCode, parcel.getFrom(), parcel.getTo());	
		}
	}
	
	function isTakenInCharge (uint _trackingCode) public view returns (bool) {
	    Parcel parcel = trackingCodeToParcel[_trackingCode];
	    return (parcel != Parcel(0x0)); // Se il mapping trackingCodeToParcel !=0 allora il pacco è stato preso in carico, altrimenti no
	}
	
	function isDelivered (uint _trackingCode) public view returns (bool) {
	    Parcel parcel = trackingCodeToParcel[_trackingCode];
	    return (parcel.getDeliveryDate() != 0); // Se data di consegna !=0 allora il pacco è stato consegnato, altrimenti no 
	}

	function getDeliveryFailuresCounter () public view returns (uint) {
		return deliveryFailuresCounter;
	}
	
	function DEMOsetDeliveryFailuresCounter(uint _number) public {
	    deliveryFailuresCounter = _number;
	}
}	