pragma solidity ^0.5.14;

import "./Manufacturer.sol";
import "./Pharmacy.sol";
import "./Distributor.sol";

/// @title Contratto DEMO per testing veloce dell'applicazione
/// @author Chiara Pavanati
/// @notice Per testare la DEMO è necessario impostare la versione di Solidity 0.5.14,
/// il gas limit di REMIX a 90000000 e passare 20 ether alla fallback necessari per acquisti e rimborsi
/// (Ne verranno dati 10 al Distributor e 10 alla Pharmacy)

contract DEMO {
    
    Manufacturer public manufacturer;
    Pharmacy public pharmacy;
    Distributor public distributor;
    
    event ActualBalances (string M, uint Mbalance, string P, uint Pbalance, string D, uint Dbalance);
    
    function () external payable {
        pharmacy.contractAddress().transfer(10 * 1 ether);
        distributor.contractAddress().transfer(10 * 1 ether);
        getBalances();
    }
    
    constructor () public {
        manufacturer = new Manufacturer ("idManufacturer", "nameManufacturer", "", "", "", "", "", 1);
        pharmacy = new Pharmacy ("idPharmacy", "namePharmacy", "", "", "", "", "");
        distributor = new Distributor ("idDistributor", "nameDistributor");
        manufacturer.setPharmacyPermission(pharmacy.contractAddress(), true);
        manufacturer.setDistributorPermission(distributor.contractAddress(), true);
    }
    
    function getBalances () public {
        emit ActualBalances ("MAN: ", address(manufacturer).balance, "PHA: ", address(pharmacy).balance, "DIS: ", address(distributor).balance);
    }

    // Caso 1: Flusso normale di acquisto, presa in carico e consegna medicinale
    function DEMOnormalCase () public {
        distributor.DEMOsetDeliveryFailuresCounter(0);
        // Parametri: nome, seriale, formato, principi attivi, dosaggio, temperatura ideale, tolleranza, scadenza, giorni in viaggio e prezzo
        uint drugSerial = manufacturer.createDrug("Tachipirina", "Granulato", "Paracetamolo", 500, 20, 5, 3, 10, 20000000);
        // ACQUISTO (Tachipirina)
        pharmacy.buyDrug(manufacturer.contractAddress(), "Tachipirina"); 
        // PRESA IN CARICO OK
        manufacturer.giveDrugToDistributor(drugSerial, distributor.contractAddress(), 1, 20); // Parametri: seriale, corriere, peso, temperatura
        // DELIVERY OK
        uint trackingCode = uint(keccak256(abi.encode(drugSerial)));
        distributor.delivery(trackingCode, 1, 20); // Parametri: seriale, peso, temperatura
    }
    
    // Caso 2: Creazione di 2 medicinali dello stesso tipo ma con seriale diverso
    function DEMOtestSerialCodes () public {
        distributor.DEMOsetDeliveryFailuresCounter(0);
        // Parametri: nome, seriale, formato, principi attivi, dosaggio, temperatura ideale, tolleranza, scadenza, giorni in viaggio e prezzo
        uint drugSerial1 = manufacturer.createDrug("Benagol", "Compresse", "Diclorobenzil", 2, 20, 5, 2, 12, 30000000);
        uint drugSerial2 = manufacturer.createDrug("Benagol", "Compresse", "Diclorobenzil", 2, 20, 5, 2, 12, 30000000);
        // ACQUISTO 1° Benagol 
        pharmacy.buyDrug(manufacturer.contractAddress(), "Benagol"); 
        // PRESA IN CARICO 1° Benagol a buon fine 
         manufacturer.giveDrugToDistributor(drugSerial1, distributor.contractAddress(), 4, 20); // Parametri: seriale, corriere, peso, temperatura
        // DELIVERY 1° Benagol a buon fine 
        uint trackingCode1 = uint(keccak256(abi.encode(drugSerial1)));
        distributor.delivery(trackingCode1, 4, 22);
        // ACQUISTO 2° Benagol
        pharmacy.buyDrug(manufacturer.contractAddress(), "Benagol"); 
        // PRESA IN CARICO 2° Benagol a buon fine
        manufacturer.giveDrugToDistributor(drugSerial2, distributor.contractAddress(), 4, 20); // Parametri: seriale, corriere, peso, temperatura
        // DELIVERY 2° Benagol fallita per furto di medicinale
        uint trackingCode2 = uint(keccak256(abi.encode(drugSerial2)));
        distributor.delivery(trackingCode2, 1, 20);
    }
    
    // Caso 3: Fallimento presa in carico medicinale
    function DEMOfailureTakenInCharge () public {
        distributor.DEMOsetDeliveryFailuresCounter(0);
        // Parametri: nome, seriale, formato, principi attivi, dosaggio, temperatura ideale, tolleranza, scadenza, giorni in viaggio e prezzo
        uint drugSerial = manufacturer.createDrug("Moment", "Gocce", "Ibuprofene", 20, 20, 5, 2, 10, 40000000); 
        // ACQUISTO (Moment)
        pharmacy.buyDrug(manufacturer.contractAddress(), "Moment");
        // PRESA IN CARICO FALLITA per medicinale non idoneo (Temperatura a 50° non consentita)
        manufacturer.giveDrugToDistributor(drugSerial, distributor.contractAddress(), 2, 50); // Parametri: seriale, corriere, peso, temperatura
    }
    
    // Caso 4: Fallimento consegna medicinale
    function DEMOfailureDelivery () public {
        distributor.DEMOsetDeliveryFailuresCounter(0);
        // Parametri: nome, seriale, formato, principi attivi, dosaggio, temperatura ideale, tolleranza, scadenza, giorni in viaggio e prezzo
        uint drugSerial = manufacturer.createDrug("Lexotan", "Gocce", "Bromazepam", 2, 20, 5, 3, 4, 50000000);
        // ACQUISTO (Lexotan)
        pharmacy.buyDrug(manufacturer.contractAddress(), "Lexotan");
        // PRESA IN CARICO OK
        manufacturer.giveDrugToDistributor(drugSerial, distributor.contractAddress(), 3, 20); // Parametri: seriale, corriere, peso, temperatura
        // DELIVERY FALLITA per furto medicinale (Peso minore all'arrivo)
        uint trackingCode = uint(keccak256(abi.encode(drugSerial)));
        distributor.delivery(trackingCode, 1, 20); // Parametri: seriale, peso, temperatura
    }
    
    // Caso 5: Fallimento consegna medicinale per distributor non autorizzato (a seguito di troppe consegne fallite)
    function DEMOfailureDeliveryForBannedDistributor () public {
        distributor.DEMOsetDeliveryFailuresCounter(0);
        // Parametri: nome, seriale, formato, principi attivi, dosaggio, temperatura ideale, tolleranza, scadenza, giorni in viaggio e prezzo
        uint drugSerial1 = manufacturer.createDrug("Benagol", "Compresse", "Diclorobenzil", 2, 20, 5, 2, 12, 30000000); 
        uint drugSerial2 = manufacturer.createDrug("Okitask", "Granulato", "Chetoprofene", 40, 20, 5, 3, 11, 70000000);
        // ACQUISTO Benagol 
        pharmacy.buyDrug(manufacturer.contractAddress(), "Benagol");
         // PRESA IN CARICO Benagol a buon fine 
        manufacturer.giveDrugToDistributor(drugSerial1, distributor.contractAddress(), 4, 20); // Parametri: seriale, corriere, peso, temperatura
        // 1° DELIVERY FALLITA per Benagol non idoneo (Temperatura a 45° non consentita)
        uint trackingCode1 = uint(keccak256(abi.encode(drugSerial1)));
        distributor.delivery(trackingCode1, 4, 45);
        // ACQUISTO Okitask
        pharmacy.buyDrug(manufacturer.contractAddress(), "Okitask");
        // PRESA IN CARICO Okitask 
        manufacturer.giveDrugToDistributor(drugSerial2, distributor.contractAddress(), 3, 20); // Parametri: seriale, corriere, peso, temperatura
        // 2° DELIVERY FALLITA per Okitask non idoneo (Temperatura a 45° non consentita)
        uint trackingCode2 = uint(keccak256(abi.encode(drugSerial2)));
        distributor.delivery(trackingCode2, 4, 45);
        // A questo punto il distributor non è più nella lista dei distributor autorizzati
    }
}