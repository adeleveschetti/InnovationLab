pragma solidity ^0.6.0;
// ABIEncoderV2 da utilizzare per poter ritornare strutture 
pragma experimental ABIEncoderV2;

// Import SafeMath library from github (this import only works on Remix).
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";


contract Resource{
    
    using SafeMath for uint256;
    
    struct resource {
        // campo address per tenere traccia di una risorsa persa
        // denominato come uint256 per una maggiore semplicità nel testing
        // address last_owner
        uint256 last_owner;
        uint256 value;
    }
    
    // anche in questo caso si utilizza un uint256 anziché address, solo per una maggiore semplicità nel testing
    // in fase di deployment, sostituire con address

    // mapping (address => resource) public globalState;
    mapping (uint256 => resource) globalState;
    mapping (uint256 => resource) copiaGlobalState;
    
    uint256[] keys;
    
    bool safe_run_incorso;
    
    // loop della mapping, operazione costosa se il numero di account nel sistema è elevato
    function duplicate() internal {
        for(uint256 i; i < keys.length; i++) {
            copiaGlobalState[keys[i]] = globalState[keys[i]];
        }
    }
    
    function init() internal {
        // salviamo una copia del GlobalState
        duplicate();
        safe_run_incorso = true;
        
    }
    
    function end() internal {
        //check stati 
        require (safe_run_incorso);
        for(uint256 i; i < keys.length; i++) {
            require(copiaGlobalState[keys[i]].value == globalState[keys[i]].value);
        }
        safe_run_incorso = false;
    }
    
    
    function mint(uint256 indirizzo, uint256 valore_da_creare) internal {
        require (safe_run_incorso);
        if (globalState[indirizzo].value == 0){
            //nuovo address creato
            keys.push(indirizzo);
        }
        globalState[indirizzo].value = globalState[indirizzo].value.add(valore_da_creare);
        
        if (safe_run_incorso){
            copiaGlobalState[indirizzo].value = copiaGlobalState[indirizzo].value.add(valore_da_creare);
        }
    }
    
    function withdraw(uint256 address_from, uint256 value_to_withdraw) internal returns (resource memory) {
        require (safe_run_incorso);
        resource memory ret;
        require(value_to_withdraw <= globalState[address_from].value);
        globalState[address_from].value = globalState[address_from].value.sub(value_to_withdraw);
        ret.value = value_to_withdraw;
        ret.last_owner = address_from;
        return ret;
    }
    
    // deposita il contenuto di una risorsa ad un altro indirizzo
    function transfer(uint256 sender, uint256 receiver, resource memory res) internal {
        require (safe_run_incorso);
        require(res.value < globalState[sender].value);
        globalState[sender].value = globalState[sender].value.sub(res.value);
        globalState[receiver].value = globalState[receiver].value.add(res.value);
    }
    function deposit(resource memory res, uint256 receiver) internal {
        require (safe_run_incorso);
        if (globalState[receiver].value == 0){
            //nuovo address creato
            keys.push(receiver);
        }
        if (res.last_owner != 0) {
            copiaGlobalState[res.last_owner].value = copiaGlobalState[res.last_owner].value.sub(res.value);
            copiaGlobalState[receiver].value = copiaGlobalState[receiver].value.add(res.value);
            res.last_owner = 0;
        }
        globalState[receiver].value = globalState[receiver].value.add(res.value);
    }
    
    function split(resource memory res, uint256 valore_da_splittare) internal pure returns (resource memory, resource memory){
        require(res.value > valore_da_splittare);
        resource memory A = resource (0,0);
        A.value = valore_da_splittare;
        res.value = res.value.sub(valore_da_splittare);
        A.last_owner = res.last_owner;
        return (res, A);
    }
    
    function merge(resource memory A, resource memory B) internal returns (resource memory) {
        A.value = A.value.add(B.value);
        // siccome sto distruggendo B, modifico la copia del globalState
        if (B.last_owner != 0 && A.last_owner != 0){
            copiaGlobalState[A.last_owner].value = copiaGlobalState[A.last_owner].value.add(B.value);
            destroy(B);
        }
        return A;
    }
    
    function destroy(resource memory res) internal {
        require (safe_run_incorso);
        if (res.last_owner != 0){
            // significa che è stata ritirata, ora a questo punto la voglio distruggere ma senza violare la safety
            // quindi modifico copiaGlobalState
            copiaGlobalState[res.last_owner].value = copiaGlobalState[res.last_owner].value.sub(res.value);
            }
    }
    
    function destroy_from_state(uint256 indirizzo, uint256 valore_da_distruggere) internal {
        require (safe_run_incorso);
        globalState[indirizzo].value = globalState[indirizzo].value.sub(valore_da_distruggere);
        if (safe_run_incorso){
            copiaGlobalState[indirizzo].value = copiaGlobalState[indirizzo].value.sub(valore_da_distruggere);
        }
    }
    
    function mint_non_safe(uint256 indirizzo, uint256 valore_da_creare) internal {
        keys.push(indirizzo);
        globalState[indirizzo].value = globalState[indirizzo].value.add(valore_da_creare);
    }
    
    //funzioni di testing
    function get_value(uint256 indirizzo) public view returns (uint256){
        return globalState[indirizzo].value;
    }
    
    function get_copia_value(uint256 indirizzo) public view returns (uint256){
        return copiaGlobalState[indirizzo].value;
    }
    
    
    function exec() public {
        init();
        
        resource memory A;
        resource memory B;
        resource memory C;
        mint(1,10);
        mint(2,5);
        A = withdraw(1,3);
        B = withdraw(2,3);
        C = merge(A,B);
        deposit(C,2);
        
        end();
    }
}