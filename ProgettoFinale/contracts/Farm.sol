pragma solidity ^0.5.6;

import "./nf-token-metadata.sol";
import "./ownable.sol";
import "./RequestToOrder.sol";

/**
 * @dev This is an example contract implementation of NFToken with metadata extension.
 */
contract Farm is
  NFTokenMetadata,
  Ownable
{

  /**
   * @dev Contract constructor. Sets metadata extension `name` and `symbol`.
   */
   uint public tokenCount;
       address public contractAddress;

  constructor()
    public
  {
    nftName = "Lot of Dishes";
    nftSymbol = "DSH";
    contractAddress = address(this);
  }
  
  /**
   * @dev Mints a new NFT.
   * @param _to The address that will own the minted NFT.
   * @param _tokenId of the NFT to be minted by the msg.sender.
   * @param _uri String representing RFC 3986 URI.
   */
  function mint(
    address _to,
    uint256 _tokenId,
    string calldata _uri,
    string calldata _name

  )
    external
    onlyOwner
  {
      tokenCount++;
    super._mint(_to, tokenCount);
    super._setTokenUri(tokenCount, _uri);
    super._setTokenProva(tokenCount, _name);

  }
 

    function set_ingrediente(
    uint256 _tokenId,
    uint256 _ingrediente
  )
    external
    onlyOwner
  {
    super._setIngrediente(_tokenId, _ingrediente);
  }

 


}
