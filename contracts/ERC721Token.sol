pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ERC721Token is ERC721URIStorage, ERC721Enumerable {
  using Counters for Counters.Counter;
  using SafeMath for uint256;
  Counters.Counter private _tokenIds;
  uint256 private _cap;

  event Minted(address indexed recipient, uint256 tokenID);

  constructor(uint256 cap) ERC721("MarsToken", "MARS"){
    require(cap > 0, "MarsToken: cap must be non-zero");
    _cap = cap;
  }

  function mintNFT(address recipient, string memory uri, uint256 tokenID)
    public onlyOwner
    returns (uint256)
  {
    require(_exists(tokenID) != true, "Token cannot be minted, plot already owned");
    require(tokenID > 0 && tokenID <= _cap, "Token cannot be minted. Out of bounds for plotID.");
    require(_tokenIds.current() <= _cap, "Cannot mint token, cap reached");

    _tokenIds.increment();
    _safeMint(recipient, tokenID);
    _setTokenURI(tokenID, uri);
    setApprovalForAll(recipient, owner(), true);
    return tokenID;
  }

  function exists(uint256 plotID) public onlyOwner view returns(bool)
  {
    return(_exists(plotID));
  }

  function checkCap()
  public onlyOwner view
  returns (uint256)
  {
    return _cap;
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721, ERC721Enumerable)
  {
      super._beforeTokenTransfer(from, to, tokenId);
  }

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
      super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId)
      public
      view
      override(ERC721, ERC721URIStorage)
      returns (string memory)
  {
      return super.tokenURI(tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
      public
      view
      override(ERC721, ERC721Enumerable)
      returns (bool)
  {
      return super.supportsInterface(interfaceId);
  }

  function enumerateTokens(address owner) public view returns(uint256[] memory)
  {
      uint256[] memory tokenIds;
      uint256 tokenIndex = balanceOf(owner);
      for(uint256 index=0; index<tokenIndex; index++){
          tokenIds[index] = tokenOfOwnerByIndex(owner, index);
      }
      return tokenIds;
  }


}
