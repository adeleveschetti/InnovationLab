pragma solidity ^0.5.6;


import "./nf-token-metadata.sol";
import "./ownable.sol";
import "./RequestToOrder.sol";
import "./Farm.sol";


contract ClientSide { 
    

    mapping (uint => uint) public cos;
    mapping (uint => uint) public angle;

    uint256 lowerBound = 59341;
    uint256 upperBound = 82379;
    address public rtoAddress;
address public farmAddress;

function setAddress(address _contractRTO, address _contractFarm) public {
    rtoAddress = _contractRTO;
    farmAddress = _contractFarm;

}

constructor() public {
    
    
cos[    59341   ]    =  82903   ;
cos[	59690	]	 = 	82708	;
cos[	60039	]	 = 	82511	;
cos[	60388	]	 = 	82313	;
cos[	60737	]	 = 	82114	;
cos[	61086	]	 = 	81915	;
cos[	61435	]	 = 	81714	;
cos[	61784	]	 = 	81512	;
cos[	62133	]	 = 	81310	;
cos[	62482	]	 = 	81106	;
cos[	62831	]	 = 	80901	;
cos[	63180	]	 = 	80696	;
cos[	63529	]	 = 	80489	;
cos[	63879	]	 = 	80281	;
cos[	64228	]	 = 	80073	;
cos[	64577	]	 = 	79863	;
cos[	64926	]	 = 	79652	;
cos[	65275	]	 = 	79441	;
cos[	65624	]	 = 	79228	;
cos[	65973	]	 = 	79015	;
cos[	66322	]	 = 	78801	;
cos[	66671	]	 = 	78585	;
cos[	67020	]	 = 	78369	;
cos[	67369	]	 = 	78152	;
cos[	67718	]	 = 	77933	;
cos[	68067	]	 = 	77714	;
cos[	68416	]	 = 	77494	;
cos[	68765	]	 = 	77273	;
cos[	69115	]	 = 	77051	;
cos[	69464	]	 = 	76828	;
cos[	69813	]	 = 	76604	;
cos[	70162	]	 = 	76379	;
cos[	70511	]	 = 	76153	;
cos[	70860	]	 = 	75927	;
cos[	71209	]	 = 	75699	;
cos[	71558	]	 = 	75470	;
cos[	71907	]	 = 	75241	;
cos[	72256	]	 = 	75011	;
cos[	72605	]	 = 	74779	;
cos[	72954	]	 = 	74547	;
cos[	73303	]	 = 	74314	;
cos[	73652	]	 = 	74080	;
cos[	74001	]	 = 	73845	;
cos[	74351	]	 = 	73609	;
cos[	74700	]	 = 	73372	;
cos[	75049	]	 = 	73135	;
cos[	75398	]	 = 	72896	;
cos[	75747	]	 = 	72657	;
cos[	76096	]	 = 	72417	;
cos[	76445	]	 = 	72176	;
cos[	76794	]	 = 	71933	;
cos[	77143	]	 = 	71691	;
cos[	77492	]	 = 	71447	;
cos[	77841	]	 = 	71202	;
cos[	78190	]	 = 	70957	;
cos[	78539	]	 = 	70710	;
cos[	78888	]	 = 	70463	;
cos[	79237	]	 = 	70215	;
cos[	79587	]	 = 	69966	;
cos[	79936	]	 = 	69716	;
cos[	80285	]	 = 	69465	;
cos[	80634	]	 = 	69214	;
cos[	80983	]	 = 	68961	;
cos[	81332	]	 = 	68708	;
cos[	81681	]	 = 	68454	;
cos[	82030	]	 = 	68199	;
cos[	82379	]	 = 	67944	;



angle[	1	] =	59341	;
angle[	2	] =	59690	;
angle[	3	] =	60039	;
angle[	4	] =	60388	;
angle[	5	] =	60737	;
angle[	6	] =	61086	;
angle[	7	] =	61435	;
angle[	8	] =	61784	;
angle[	9	] =	62133	;
angle[	10	] =	62482	;
angle[	11	] =	62831	;
angle[	12	] =	63180	;
angle[	13	] =	63529	;
angle[	14	] =	63879	;
angle[	15	] =	64228	;
angle[	16	] =	64577	;
angle[	17	] =	64926	;
angle[	18	] =	65275	;
angle[	19	] =	65624	;
angle[	20	] =	65973	;
angle[	21	] =	66322	;
angle[	22	] =	66671	;
angle[	23	] =	67020	;
angle[	24	] =	67369	;
angle[	25	] =	67718	;
angle[	26	] =	68067	;
angle[	27	] =	68416	;
angle[	28	] =	68765	;
angle[	29	] =	69115	;
angle[	30	] =	69464	;
angle[	31	] =	69813	;
angle[	32	] =	70162	;
angle[	33	] =	70511	;
angle[	34	] =	70860	;
angle[	35	] =	71209	;
angle[	36	] =	71558	;
angle[	37	] =	71907	;
angle[	38	] =	72256	;
angle[	39	] =	72605	;
angle[	40	] =	72954	;
angle[	41	] =	73303	;
angle[	42	] =	73652	;
angle[	43	] =	74001	;
angle[	44	] =	74351	;
angle[	45	] =	74700	;
angle[	46	] =	75049	;
angle[	47	] =	75398	;
angle[	48	] =	75747	;
angle[	49	] =	76096	;
angle[	50	] =	76445	;
angle[	51	] =	76794	;
angle[	52	] =	77143	;
angle[	53	] =	77492	;
angle[	54	] =	77841	;
angle[	55	] =	78190	;
angle[	56	] =	78539	;
angle[	57	] =	78888	;
angle[	58	] =	79237	;
angle[	59	] =	79587	;
angle[	60	] =	79936	;
angle[	61	] =	80285	;
angle[	62	] =	80634	;
angle[	63	] =	80983	;
angle[	64	] =	81332	;
angle[	65	] =	81681	;
angle[	66	] =	82030	;
angle[	67	] =	82379	;

}



uint256 public resul;
int public resul2;


//up e low funzioni di ricerca indici tabella coseno
function up(uint256 _input) public returns(uint256) {
    uint256 res = _input;
    while(cos[res] == 0){
        res++;
    }
    return res;
}

function low(uint256 _input) public returns(uint256) {
    uint256 res = _input;
    while(cos[res] ==0){
        res--;
    }
    
    return res;
}


//funzione sorting array
function sort(uint256 _input, uint256 _low, uint256 _high) public returns(uint256) {
    uint256 res = _input;
    if (_low == _high+1){
        uint256 z = angle[_low] - _input;
        uint256 h = angle[_high] - _input;
        if(z < h){
                res = angle[_low];
        }
        else{
            res = angle[_high];
        }
    }
    
    uint256 mid = (_low + _high)/2;
    if (angle[mid] == _input){
        res = angle[mid];
    }
    else{
        if (angle[mid] > _input){
            res = sort(_input, _low, mid);
        }
        else {
            res = sort(_input, mid, _high);
        }
    }
    resul = res;
    return res;
}


function sort2(uint256 _input) public returns(uint256) {
    uint256 res = _input;
    uint256 low = 1;
    uint256 high = 67;
    bool check = true;
    while (check){
    
        if (low == high+1){
            uint256 z = angle[low] - _input;
            uint256 h = angle[high] - _input;
            if(z < h){
                    res = angle[low];
            }
            else{
                res = angle[high];
            }
            check = false;
        }
        
        uint256 mid = (low + high)/2;
        if (angle[mid] == _input){
            res = angle[mid];
            check = false;
        }
        else{
            if (angle[mid] > _input){
                high =  mid;
            }
            else {
                low =  mid;
            }
        }
    }
    resul = res;
    return res;
}


    
    


function findCos(uint256 _input) public returns(uint256) {
    uint256 lower;
    uint256 upper;
    uint res;
    
    lower=low(_input);
    upper=up(_input);
    
    uint256 temp = (upper + lower)/2;
    if( _input >= temp ){
        res = upper;
    }
    else{
        res = lower;
    }
   // resul = cos[res];
    return cos[res];
}


    
    function test(uint256 _initial) public pure returns (uint256, uint256, uint256) {
        // as we are returning integers without decimal places it's always rounded down automatically
        return (_initial % 1000000 / 10000, _initial % 10000 / 100, _initial % 100);
    }
    

    
    function splitCoordinates(uint256 _cordinates) public pure returns (uint256, uint256) {
        // as we are returning integers without decimal places it's always rounded down automatically
        return (_cordinates % 1000000000000/1000000, _cordinates % 1000000);
    }
    

    function exstactionLat() public pure returns (uint256) {
        uint256 initial = 111111222222;
        // as we are returning integers without decimal places it's always rounded down automatically
        return (initial % 1000000000000/1000000);
    }
    
    function exstactionLon() public pure returns (uint256) {
        uint256 initial = 111111222222;
        // as we are returning integers without decimal places it's always rounded down automatically
        return (initial % 1000000);
    }
    


     function toRadians(uint256 _cordinates) public pure returns (uint256, uint256) {
        uint256 initial = 443027112150;
        uint256 initial2 = 444234103713;

        // as we are returning integers without decimal places it's always rounded down automatically
        (uint256 lat, uint256 lon) = splitCoordinates(_cordinates);
        (uint256 latDeg, uint256 latFist, uint256 latSecond) = test(lat);
        (uint256 lonDeg, uint256 lonFist, uint256 lonSecond) = test(lon);
        latDeg = (latDeg*1000000) + (latFist*1000000)/60+ (latSecond*1000000)/3600;
        lonDeg = (lonDeg*1000000) + (lonFist*1000000)/60+ (lonSecond*1000000)/3600;
        
        latDeg = (latDeg * 31416)/18000000;
        lonDeg = (lonDeg * 31416)/18000000;

        
        //uint256 RadLat = (a * 3.14);
        
        
        
        return (latDeg, lonDeg);
    }
    
   
    
    
    function test2 (uint256 a) public pure returns(uint256, uint256, int){
        uint256 const = 16384;
        uint256 b = a * const;
        int d = int(b/360);
        uint16 par = uint16(d);
        int c =0;
        uint256 conver = uint256(c);
        uint256 uno =100;
        uint256 out = conver * uno;
        uint256 out2 = out/32767;
        return(out2, par, c);
    }
    
    
     function distance(uint256 _cordinates1, uint256 _cordinates2) public returns (int) {
        (uint256 lat1, uint256 lon1) = toRadians(_cordinates1);
        (uint256 lat2, uint256 lon2) = toRadians(_cordinates2);
        int x = int(lon2) - int(lon1);
        uint256 arg = (lat2 +lat1)/2;
        arg = findCos(arg);
        x = x * int(arg); 
        int y = int(lat2) - int(lat1);
        int dis = (x*x)+(y*y);
        dis = sqrt(dis);
        dis = 6371 * dis;
        
       //dis = dis % 1000000000000/10000000000;

        resul2 = dis;
        
        return(dis);
    }
    
    
        function sqrt(int x) public pure returns (int y) {
    int z = (x + 1) / 2;
    y = x;
    while (z < y) {
        y = z;
        z = (x / z + z) / 2;
    }
        }
        
        
        mapping (uint => int) public controll;
            mapping (uint => int) public controll2;

      function Delivery1(uint _tokenId) public  payable{
          
    Farm farm = Farm(farmAddress);
    RequestToOrder monte = RequestToOrder(rtoAddress);
    farm.transferFromInternal(0xA4767B3a3a8D23912045E551c41c4C559572Fb85, msg.sender, _tokenId);
            uint256 initial = 443027112150;

    bool km0 = true;
    for(uint i = 1; i <= 10; i++){
      uint alfa = farm.readIngrediente(_tokenId, i);
      (uint256 a, string memory b, uint256 c, address d, uint256 e) = monte.listOfIngredients(alfa);
      if (c != 0){
          int dist = distance(initial,c);
          controll[i] = dist;
          if (dist >= 150){
            ///do notthing..
controll2[i] = 100;    
          }

        }
    }
}
    
    
}