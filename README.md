# NFT-Wrapper-Contract
Solidity contracts to both create an NFT minter and Manager/Wrapper contract to facilitate a marketplace.

This repo contains two primary contracts, built using openzeppelin's ERC721 implementations (with some minor changes).

ERC721Token.sol defines the base erc721 token to be minted and managed by the wrapper contract, ERC721Wrapper.sol.

The wrapper contract is used as a layer of abstraction between the base token contract (minter) and the user. This can used be to create a managed marketplace for a specific erc721 token, or provide for extra security. A small flaw with openzeppelin's erc721 implementation is the lack of protection for the setApprovalForAll() function. I've made the base ERC721 contract Ownable, adding the onlyOwner identifier to the setApprovalForAll() function. setApprovalForAll is called upon mint and purchase, allowing the Wrapper contract to manage transfers - of course, one critique is that the Wrapper now acts as an intermediary, which may not be desirable.

A better solution would be to adjust the approve() function, as it acts on the token level, and rather than setting the Wrapper as an operator for an owner's entire erc721 balance, allow users to opt-in to using the Wrapper by providing an option to call the approve() function. The only problem with this approach is that, as approve() affects state, it does cost gas.


# Tests
To run tests, you must first locally fork the ETH mainnet. I prefer ganahce-cli (https://github.com/trufflesuite/ganache)

```
ganache-cli --fork <RPC_URL> --i 999  
```

A bash script is included in the test folder to make this process easier. it also saves all generated keys into a .json file for ease of access when running tests.

The <RPC_URL> should be a key to a, for example, infura project. See their docs for more information.

After forking a local mainnet node, run:

```
truffle test ./test/wrapper-test.js
```
The path argument can of course be a path to whichever .js file you're using for testing.

# TODO:
- Update documentation
