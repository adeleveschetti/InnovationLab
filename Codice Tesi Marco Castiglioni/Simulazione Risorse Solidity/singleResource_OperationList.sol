pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

// Import SafeMath library from github (this import only works on Remix).
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Resource{
    
    using SafeMath for uint256;
    
    struct resource {
        uint256 value;
    }
    
    //dati per la lista che controlla le modifiche allo state
    struct data {
        //0 per get (withdraw), 1 per put (deposit)
        uint256 action; 
        uint256 value;
    }
    
    
    //mapping (address => resource) public globalState;
    mapping (uint256 => resource) globalState;
    mapping (uint256 => resource) copiaGlobalState;
    
    //dati per tracciare il controllo risorse senza utilizzare una copia dello state
    
    data[] check_state_list;
    
    // tiene traccia di quanta risorsa è stata ritirata dallo state
    // get aumenta il valore, put lo riduce (mai sotto 0, non si può fare put senza prima una get)
    // a fine esecuzione dovrà essere 0
    uint256 _borrowedfromglobalstate;
    
    uint256 valore_di_prova;
    
    uint256[] keys;
    bool safe_run_incorso;
    
    function init() internal {
        // numero indirizzi
        
        safe_run_incorso = true;
        //svuoto la lista
        delete check_state_list;
        
        _borrowedfromglobalstate = 0;
    }
    
    function end() internal {
        //check stati 
        data memory tmp;
        
        require (safe_run_incorso);
        
        for (uint256 j; j < check_state_list.length; j++){
            tmp = check_state_list[j];
            //withdraw
            if (tmp.action == 0) {
                _borrowedfromglobalstate = _borrowedfromglobalstate.add(tmp.value);
            }
            //deposit
            else if (tmp.action == 1){
                //partendo dall'inizio, ci saranno sempre withdraw prima del deposit
                //dobbiamo evitare riutilizzo di risorsa
                require (_borrowedfromglobalstate >= tmp.value);
                _borrowedfromglobalstate = _borrowedfromglobalstate.sub(tmp.value);
            }
        }
        
        //controllo che il bilanciamento sia 0, dobbiamo evitare perdita di risorsa
        require (_borrowedfromglobalstate == 0);
        
        delete check_state_list;
        
        safe_run_incorso = false;
    }
    
    
    function mint(uint256 indirizzo, uint256 valore_da_creare) internal {
        require (safe_run_incorso);
        if (globalState[indirizzo].value == 0){
            //nuovo address creato
            keys.push(indirizzo);
        }
        globalState[indirizzo].value = globalState[indirizzo].value.add(valore_da_creare);
    }
    
    function withdraw(uint256 address_from, uint256 value_to_withdraw) internal returns (resource memory) {
        require (safe_run_incorso);
        resource memory ret;
        data memory tmp;
        require(value_to_withdraw <= globalState[address_from].value);
        globalState[address_from].value = globalState[address_from].value.sub(value_to_withdraw);
        ret.value = value_to_withdraw;
        
        //push action sulla lista
        tmp.action = 0;
        tmp.value = value_to_withdraw;
        check_state_list.push(tmp);
        //check_state_list[check_state_list.length-1].value = value_to_withdraw;
        //check_state_list[check_state_list.length-1].action = 0;
        return ret;
    }
    
    // deposita il contenuto di una risorsa ad un altro indirizzo
    function transfer(uint256 sender, uint256 receiver, resource memory res) internal {
        require (safe_run_incorso);
        //sender si può prendere con msg.value?
        require(res.value < globalState[sender].value);
        globalState[sender].value = globalState[sender].value.sub(res.value);
        globalState[receiver].value = globalState[receiver].value.add(res.value);
    }
    
    function deposit(resource memory res, uint256 receiver) internal {
        require (safe_run_incorso);
        data memory tmp;
        if (globalState[receiver].value == 0){
            //nuovo address creato
            keys.push(receiver);
        }
        
        globalState[receiver].value = globalState[receiver].value.add(res.value);
        
        //push action sulla lista
        tmp.action = 1;
        tmp.value = res.value;
        check_state_list.push(tmp);
        
    }
    
    function split(resource memory res, uint256 valore_da_splittare) internal pure returns (resource memory, resource memory){
        require(res.value > valore_da_splittare);
        resource memory A = resource (0);
        A.value = valore_da_splittare;
        res.value = res.value.sub(valore_da_splittare);
        return (res, A);
    }
    
    function merge(resource memory A, resource memory B) internal pure returns (resource memory) {
        A.value = A.value.add(B.value);
        //non c'è perdita di risorsa, quando andrò a fare deposit di A si controllerà il valore intero
        return A;
    }
    
    function destroy(resource memory res) internal {
        require (safe_run_incorso);
        data memory tmp;
        
        // metto sulla lista come se fosse una put, ma senza aggiornare il global state
        tmp.action = 1;
        tmp.value = res.value;
        check_state_list.push(tmp);
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
    
    // funzioni di testing
    function get_value(uint256 indirizzo) public view returns (uint256){
        return globalState[indirizzo].value;
    }
    
    function get_copia_value(uint256 indirizzo) public view returns (uint256){
        return copiaGlobalState[indirizzo].value;
    }
    
    function get_balance() public view returns (uint256){
        return _borrowedfromglobalstate;
    }
    
    function get_length() public view returns (uint256){
        return check_state_list.length;
    }
    
    function get_first_value() public view returns (uint256,uint256){
        return (check_state_list[0].action,check_state_list[0].value);
    }
    
    function get_valore_di_prova() public view returns (uint256){
        return valore_di_prova;
    }

    function exec() public {
        init();
        resource memory A;
        resource memory B;
        resource memory C;
       
        mint(1,10);
        mint(2,4);
        A = withdraw(1,3);
        (B,C) = split(A,2);
        destroy(B);
        destroy(C);

        end();
    }
}