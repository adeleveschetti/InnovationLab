pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

// Import SafeMath library from github (this import only works on Remix).
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Resource{
    
    using SafeMath for uint256;
    
    struct resourceCoin {
        uint256 value;
    }
    
    // 0 blue, 1 red, 2 yellow
    struct resourceColoredCoin {
        uint256 color;
        uint256 value;
    }
    
    struct resourceEarmarkedColoredCoin {
        // colored coin tenuto da parte per un certo indirizzo
        uint256 indirizzo;
        resourceColoredCoin coloredcoin;
    }
    
    //dati per la lista che controlla le modifiche allo state
    struct coinData {
        //0 per get (withdraw), 1 per put (deposit)
        uint256 action; 
        uint256 value;
    }
    
    struct coloredCoinData {
        //0 per get (withdraw), 1 per put (deposit)
        uint256 action;
        // non si può usare enum perché non permette add/sub safe
        uint256 color;
        uint256 value;
    }
    
    // purtroppo non è possibile utilizzare un generics struct e perciò si è obbligati a dichiarare un diverso global
    // state per ogni risorsa
    mapping (uint256 => resourceCoin) coinGlobalState;
    mapping (uint256 => resourceColoredCoin) coloredCoinGlobalState;

    
    //dati per tracciare il controllo risorse senza utilizzare una copia dello state
    coinData[] checkCoinStateList;
    coloredCoinData[] checkColoredCoinStateList;

    // tiene traccia di quanta risorsa Coin è stata ritirata dallo state
    // get aumenta il valore, put lo riduce (mai sotto 0, non si può fare put senza prima una get)
    // a fine esecuzione dovrà essere 0
    uint256 _borrowedfromcoinglobalstate;

    // enum come key in mapping non supportato
    // 0 per red, 1 per blue, 2 per yellow
    // ogni colore ha il suo bilanciamento
    mapping (uint256 => uint256) _borrowedfromcoloredcoinglobalstate;
    
    // testing
    uint256 valore_di_prova;
    
    bool safe_run_incorso;
    
    function init() internal {
        
        // init Coin state
        _borrowedfromcoinglobalstate = 0;
        delete checkCoinStateList;
        
        //init Colored Coin state
        for (uint256 i; i < 3; i++) {
            _borrowedfromcoloredcoinglobalstate[i] = 0;
        }
        delete checkColoredCoinStateList;
        
        safe_run_incorso = true;
        
    }
    
    function end() internal {
        
        coinData memory tmp;
        coloredCoinData memory tmp2;
        
        require (safe_run_incorso);
        
        for (uint256 j; j < checkCoinStateList.length; j++){
            tmp = checkCoinStateList[j];
            // controllo get, Global State relativo alla risorsa Coin
            if (tmp.action == 0) {
                _borrowedfromcoinglobalstate = _borrowedfromcoinglobalstate.add(tmp.value);
            }
            // controllo put, Global State relativo alla risorsa Coin
            else if (tmp.action == 1){
                //partendo dall'inizio, ci saranno sempre withdraw prima del deposit
                //dobbiamo evitare riutilizzo di risorsa
                require (_borrowedfromcoinglobalstate >= tmp.value);
                _borrowedfromcoinglobalstate = _borrowedfromcoinglobalstate.sub(tmp.value);
            }
        }
        
        for (uint256 j; j < checkColoredCoinStateList.length; j++){
            tmp2 = checkColoredCoinStateList[j];
            // controllo get, Global State relativo alla risorsa Colored Coin
            if (tmp2.action == 0) {
                _borrowedfromcoloredcoinglobalstate[tmp2.color] = _borrowedfromcoloredcoinglobalstate[tmp2.color].add(tmp2.value);
            }
            // controllo put, Global State relativo alla risorsa Colored Coin
            else if (tmp2.action == 1){
                //partendo dall'inizio, ci saranno sempre withdraw prima del deposit
                //dobbiamo evitare riutilizzo di risorsa
                require (_borrowedfromcoloredcoinglobalstate[tmp2.color] >= tmp2.value);
                _borrowedfromcoloredcoinglobalstate[tmp2.color] = _borrowedfromcoloredcoinglobalstate[tmp2.color].sub(tmp2.value);
            }
        }
        
        //controllo che il bilanciamento sia 0, dobbiamo evitare perdita di risorsa
        require (_borrowedfromcoinglobalstate == 0);
        require (_borrowedfromcoloredcoinglobalstate[tmp2.color] == 0);
        
        delete checkCoinStateList;
        delete checkColoredCoinStateList;
        
        safe_run_incorso = false;
    }
    
    
    // siccome non è permesso l'utilizzo di struct generiche, bisogna dichiarare le funzioni per ciascuna
    function coin_mint(uint256 indirizzo, uint256 valore_da_creare) internal {
        require (safe_run_incorso);
        
        coinGlobalState[indirizzo].value = coinGlobalState[indirizzo].value.add(valore_da_creare);
        
    }
    
    function coloredcoin_mint(uint256 indirizzo, uint256 color, uint256 valore_da_creare) internal {
        require (safe_run_incorso);
        
        coloredCoinGlobalState[indirizzo].value = coloredCoinGlobalState[indirizzo].value.add(valore_da_creare);
        
        require (color < 3);
        coloredCoinGlobalState[indirizzo].color = color;
        
    }
    
    function coin_withdraw(uint256 address_from, uint256 value_to_withdraw) internal returns (resourceCoin memory) {
        require (safe_run_incorso);
        resourceCoin memory ret;
        coinData memory tmp;
        require(value_to_withdraw <= coinGlobalState[address_from].value);
        coinGlobalState[address_from].value = coinGlobalState[address_from].value.sub(value_to_withdraw);
        ret.value = value_to_withdraw;
        
        //push action sulla lista
        tmp.action = 0;
        tmp.value = value_to_withdraw;
        checkCoinStateList.push(tmp);

        return ret;
    }
    
    function coloredcoin_withdraw(uint256 address_from, uint256 color, uint256 value_to_withdraw) internal returns (resourceColoredCoin memory) {
        
        require (safe_run_incorso);
        
        resourceColoredCoin memory ret;
        coloredCoinData memory tmp;
        
        require(value_to_withdraw <= coloredCoinGlobalState[address_from].value);
        
        coloredCoinGlobalState[address_from].value = coloredCoinGlobalState[address_from].value.sub(value_to_withdraw);
        coloredCoinGlobalState[address_from].color = color;
        ret.value = value_to_withdraw;
        ret.color = color;
        
        //push action sulla lista
        tmp.action = 0;
        tmp.value = value_to_withdraw;
        tmp.color = color;
        checkColoredCoinStateList.push(tmp);

        return ret;
    }
    
    function coin_deposit(resourceCoin memory res, uint256 receiver) internal {
        require (safe_run_incorso);
        coinData memory tmp;
        
        coinGlobalState[receiver].value = coinGlobalState[receiver].value.add(res.value);
        
        //push action sulla lista
        tmp.action = 1;
        tmp.value = res.value;
        checkCoinStateList.push(tmp);
        
    }
    
    function coloredcoin_deposit(resourceColoredCoin memory res, uint256 receiver) internal {
        require (safe_run_incorso);
        
        coloredCoinData memory tmp;
        
        coloredCoinGlobalState[receiver].value = coloredCoinGlobalState[receiver].value.add(res.value);
        coloredCoinGlobalState[receiver].color = res.color;
        
        //push action sulla lista
        tmp.action = 1;
        tmp.value = res.value;
        tmp.color = res.color;
        checkColoredCoinStateList.push(tmp);
        
    }
    
    // prende in input risorsa Coin
    // ritorna risorsa Colored Coin
    function color_a_coin (resourceCoin memory res, uint256 color) internal returns (resourceColoredCoin memory) {
        resourceColoredCoin memory newColoredCoin;
        coloredCoinData memory tmp;
        require (safe_run_incorso);
        require (color < 3);
        
        newColoredCoin.value = res.value;
        newColoredCoin.color = color;
        
        // push action withdraw sulla lista per evitare si perda la coin colorata
        tmp.action = 0;
        tmp.value = res.value;
        tmp.color = color;
        checkColoredCoinStateList.push(tmp);
        
        // rimuovo la coin 
        coin_destroy(res);
        
        return newColoredCoin;
    }
    
    function coin_split(resourceCoin memory res, uint256 valore_da_splittare) internal pure returns (resourceCoin memory, resourceCoin memory){
        require(res.value > valore_da_splittare);
        resourceCoin memory A = resourceCoin (0);
        A.value = valore_da_splittare;
        res.value = res.value.sub(valore_da_splittare);
        return (res, A);
    }
    
    function coin_merge(resourceCoin memory A, resourceCoin memory B) internal pure returns (resourceCoin memory) {
        A.value = A.value.add(B.value);
        //non c'è perdita di risorsa, quando andrò a fare deposit di A si controllerà il valore intero
        return A;
    }
    
    function coin_destroy(resourceCoin memory res) internal {
        require (safe_run_incorso);
        coinData memory tmp;
        // metto sulla lista come se fosse una put, ma senza aggiornare il global state
        tmp.action = 1;
        tmp.value = res.value;
        checkCoinStateList.push(tmp);
    }
    
    // funzioni di testing
    
    function compareStrings (string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
    }
    
    function get_value_coinGlobalState(uint256 indirizzo) public view returns (uint256){
        return coinGlobalState[indirizzo].value;
    }
    
    function get_balance() public view returns (uint256){
        return _borrowedfromcoinglobalstate;
    }
    
    function get_length() public view returns (uint256){
        return checkCoinStateList.length;
    }
    
    function get_first_value() public view returns (uint256,uint256){
        return (checkCoinStateList[0].action,checkCoinStateList[0].value);
    }
    
    function get_valore_di_prova() public view returns (uint256){
        return valore_di_prova;
    }

    function exec() public {
        
        init();
        resourceCoin memory A;
        resourceColoredCoin memory BlueCoin;
       
        coin_mint(1,8);
        coin_mint(2,4);
        
        coloredcoin_mint(1,1,4);
        A = coin_withdraw(1,3);
        
        //coloro la Coin A di blue
        BlueCoin = color_a_coin(A,1);
        
        coloredcoin_deposit(BlueCoin,2);
        
        //coin_destroy(A);
       
        end();
    }
}