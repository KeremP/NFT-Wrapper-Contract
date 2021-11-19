pragma solidity ^0.8.0;

import "./ERC721Token.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ERC721Wrapper is Ownable {
  using SafeMath for uint256;
  uint256 private initPrice = 50000000000000000; // 0.05 ETH


  ERC721Token public baseToken;
  address private baseTokenAddress;

  mapping(address => bool) private paidForToken;
  mapping(uint256 => uint256) private tokenPrices;

  event Minted(address indexed recipient, uint256 tokenID);

  constructor(
    address payable TokenAddress
    )
    public
    {
      baseToken = ERC721Token(TokenAddress);
      baseTokenAddress = TokenAddress;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function checkExist(uint256 tokenID) public view returns(bool)
    {
      return baseToken.exists(tokenID);
    }

    function getTokenAddress() public onlyOwner view returns(address)
    {
      return(baseTokenAddress);
    }

    function getBalance() public onlyOwner view returns(uint256) {
      return address(this).balance;
    }

    function withdrawFunds() public onlyOwner {
      uint256 balance = getBalance();
      address owner = owner();
      payable(owner).transfer(balance);
    }

    function checkTokenPrice(uint256 tokenID) public view returns(uint256){
      return tokenPrices[tokenID];
    }

    function sendFee(address minter, string memory uri, uint256 id, uint256 newPrice) public payable{
      require(checkExist(id) != true, "Token already minted.");
      require(msg.value >=  initPrice, "Must send 0.05 ETH minting fee.");
      (bool sent, bytes memory data) = address(this).call{value:msg.value}("");
      require(sent, "Could not send ETH");
      paidForToken[msg.sender] = true;
      mintNewPlot(minter, uri, id, newPrice);
    }

    function mintNewPlot(address recipient, string memory tokenURI, uint256 tokenID, uint256 newPrice) private returns(uint256)
    {
      require(paidForToken[recipient], "Must pay minting fee.");
      require(checkExist(tokenID) != true, "Token already minted, please purchase from current owner.");
      //must pay fee for each mint
      paidForToken[recipient] = false;
      tokenPrices[tokenID] = newPrice;
      uint256 _newTokenID = baseToken.mintNFT(recipient, address(this), tokenURI, tokenID, newPrice);
      emit Minted(recipient, _newTokenID);
      return _newTokenID;

    }

    function checkOwner(uint256 tokenID) public view returns(address){
      address owner = baseToken.ownerOf(tokenID);
      return owner;
    }


    function checkOperator(address owner) public onlyOwner view returns(bool)
    {
      return(baseToken.isApprovedForAll(owner, address(this)));
    }

    function purchaseToken(address payable from, address to, uint256 tokenID, uint256 newPrice) public payable
    {
      require(msg.sender != checkOwner(tokenID), "You already own this plot.");
      require(msg.value >= tokenPrices[tokenID], "Must send more ETH.");
      tokenPrices[tokenID] = newPrice;
      (bool sent, bytes memory data) = from.call{value:msg.value}("");
      require(sent, "Could not send ETH");
      baseToken.setApprovalForAll(to, address(this), true);
      baseToken.safeTransferFrom(from, to, tokenID);
    }

    function checkBalance(address owner) public view returns(uint256)
    {
      return baseToken.balanceOf(owner);
    }





}
