pragma solidity ^0.6.0;

// Import SafeMath library from github (this import only works on Remix).
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Pane{
    
    using SafeMath for uint256;
    
    mapping (address => uint256) private quantita;

    mapping (address => mapping (address => uint256)) private permesso;

    uint256 private _MaxPaneMercato;
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    
    // quantità disponibile
    function totalSupply() public view returns (uint256) {
        return _MaxPaneMercato;
    }
    
    // getter balance
    function balanceOf(address owner) public view returns (uint256) {
        return quantita[owner];
    }
    

    // ritorna l'ammontare che l'owner di pane permette allo spender di poter ritirare 
    function allowance(address owner, address spender) public view returns (uint256){
        return permesso[owner][spender];
    }
    
    // trasferisce token dal sender all'address to
    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= quantita[msg.sender]);
        require(to != address(0));
        quantita[msg.sender] = quantita[msg.sender].sub(value);
        quantita[to] = quantita[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    // trasferisce token da from a to 
    function transferFrom(address from, address to, uint256 value) public returns (bool){
        require(value <= quantita[from]);
        //controlla che il sender abbia il permesso di spostare tali token
        require(value <= permesso[from][msg.sender]);
        require(to != address(0));
        
        quantita[from] = quantita[from].sub(value);
        quantita[to] = quantita[to].add(value);
        permesso[from][msg.sender] = permesso[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }
  
  // aumenta il permesso di ritirare  una certa quantità di pane di un owner ad un spender
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool){
    require(spender != address(0));

    permesso[msg.sender][spender] = (permesso[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, permesso[msg.sender][spender]);
    return true;
  }

  // diminuisci il permesso di ritirare una certa quantità di pane di un owner ad un spender
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool){
    require(spender != address(0));

    permesso[msg.sender][spender] = (
      permesso[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, permesso[msg.sender][spender]);
    return true;
  }

  // sforna nuovo pane
  function _mint(address account, uint256 amount) internal{
    require(account != address(0));
    _MaxPaneMercato = _MaxPaneMercato.add(amount);
    quantita[account] = quantita[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  // brucia tot pane da un certo account
  function _burn(address account, uint256 amount) internal {
    require(account != address(0));
    require(amount <= quantita[account]);

    _MaxPaneMercato = _MaxPaneMercato.sub(amount);
    quantita[account] = quantita[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  // brucia tot pane solo con permesso e riduce permesso
  function _burnFrom(address account, uint256 amount) internal {
    require(amount <= permesso[account][msg.sender]);
    permesso[account][msg.sender] = permesso[account][msg.sender].sub(amount);
    _burn(account, amount);
  }
}