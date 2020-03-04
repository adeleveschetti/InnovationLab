pragma solidity ^0.5.14;

import "./DrugItem.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

/// @title Contratto del parcel creato dal Distributor quando prende in carico il drug per consegnarlo al buyer (Pharmacy)
/// @author Chiara Pavanati
/// @notice Uso della libreria SafeMath per prevenire errori di Overflow e Underflow

contract Parcel is Ownable {
	
	using SafeMath for uint256;

    event NewParcel (address payable from, address payable to, uint trackingCode, uint weight, uint takenInChargeDate, uint deliveryDate, DrugItem drug);

	address payable private from; // Mittente
	address payable private to; // Destinatario
	uint private trackingCode; // Codice pacco
	uint private weight; // Peso pacco
	uint private takenInChargeDate; // Data di presa in carico
	uint private deliveryDate; // Data di consegna
	DrugItem private drug; // Contenuto pacco (parcel) cioé il medicinale (drug)

	constructor (address payable _from, address payable _to, uint _trackingCode, uint _weight, DrugItem _drug) public {
		from = _from;
		to = _to;
		trackingCode = _trackingCode;
		weight = _weight;
		takenInChargeDate = now;
		deliveryDate = 0;
		drug = _drug;
		emit NewParcel (from, to, trackingCode, weight, takenInChargeDate, deliveryDate, drug);
	}

	function setDeliveryDate (uint newDeliveryDate) public onlyOwner () {
		deliveryDate = newDeliveryDate;
	}

	function getFrom () public view returns (address payable) {
		return from;
	}

	function getTo () public view returns (address payable) {
		return to;
	}

	function getTrackingCode () public view returns (uint) {
		return trackingCode;
	}
	
	function getWeight () public view returns (uint) {
	    return weight;
	}

	function getTakenInChargeDate () public view returns (uint) {
		return takenInChargeDate;
	}

	function getDeliveryDate () public view returns (uint) {
		return deliveryDate;
	}

	function getParcelContent () public view returns (DrugItem) {
		return drug;
	}
}