const chai = require('chai');
var expect = chai.expect;
var should = chai.should();
const { ethers, BigNumber, Contract, providers, Wallet } = require('ethers');

const keys = require('./keys_.json');
const contractABI = require("../build/contracts/ERC721Token.json");
const WrapperContract = artifacts.require("ERC721Wrapper");
// const MarsToken = artifacts.require("MarsToken");


contract("ERC721Wrapper", async (accounts)=> {
  let instance, provider, wallet, tokenContract;

  beforeEach( async ()=> {
    // marstoken = await MarsToken.deployed();
    instance = await WrapperContract.deployed()
    provider = new providers.JsonRpcProvider()
    const privateKeys = keys.private_keys
    const privateKey = privateKeys[accounts[0].toLowerCase()]
    wallet = new Wallet(privateKey)
    let tokenAddress = await instance.getTokenAddress()
    wallet = wallet.connect(provider)
    tokenContract = new Contract(tokenAddress, contractABI.abi, wallet)
    // console.log(wrapperContract)
  })


  it("Mint ERC721 token from wrapper", async() => {
    let overrides = {
      value: "500000000000000000"
    }
    const tx = await instance.sendFee(accounts[0], "testing", 333, ethers.utils.parseEther("0.06"), overrides);
    // console.log(tx.logs)
    expect(tx.logs[0].args.tokenID.toString()).to.equal('333')
  })


  it("Test mint requires", async () => {
    let overrides = {
      value: "500000000000000000"
    }
    try{

    const tx = await instance.sendFee(accounts[0], "testing", 333, ethers.utils.parseEther("0.06"), overrides);
  }catch(err){
    expect(err.reason).to.equal('Token already minted.')
  }

  })


  it("Check if tokenID exists", async() => {
    const exists = await instance.checkExist(333);
    expect(exists).to.be.true;
  })


  it("Check if wrapper is operator", async() => {

    //
    // const tx = await tokenContract.populateTransaction.setApprovalForAll(instance.address, true);
    // await wallet.sendTransaction(tx);

    const isOperator = await instance.checkOperator(accounts[0]);
    expect(isOperator).to.be.true;
  })


  it("Check require for setApprovalForAll", async () => {
    try{

    const tx = await tokenContract.setApprovalForAll(accounts[0],accounts[1], true);
    }catch(e){
      // console.log(e);
      should.exist(e)


    }
  })


  it("Check balance of wrapper contract", async() => {
    const wrapperBalance = await instance.getBalance();
    expect(wrapperBalance.toString()).to.equal("500000000000000000")
  })


  it("Withdraw funds from wrapper contract", async() => {
    const tx = await instance.withdrawFunds()

    const wrapperBal = await instance.getBalance();

    expect(wrapperBal.toString()).to.equal("0")
  })


  it("Purchase ERC721 Token from owner", async() => {
    const ownerBalance = await web3.eth.getBalance(accounts[0])
    let overrides = {
      from:accounts[1],
      value: "600000000000000000"
    }
    const tx = await instance.purchaseToken(accounts[0], accounts[1], 333, ethers.utils.parseEther("0.07"), overrides)
    const ownerBalance_post = await web3.eth.getBalance(accounts[0])

    const balanceDiff = ownerBalance_post - ownerBalance;

    expect(balanceDiff).to.equal(600000000000000000)
  })


  it("Check if wrapper is operator post purchase", async() => {
    const isOp = await instance.checkOperator(accounts[1]);
    expect(isOp).to.be.true;
  })


  it("Check price change", async() => {
    const tokenPrice = await instance.checkTokenPrice(333);
    expect(tokenPrice.toString()).to.equal("70000000000000000");
  })


  it("Check token balance of owner", async()=>{
    const tokenBalance = await instance.checkBalance(accounts[1]);
    expect(tokenBalance.toString()).to.equal("1");
  })

  it("Token of owner by index", async()=>{
  let overrides = {
    from:accounts[1],
    value: "500000000000000000"
  }
  await instance.sendFee(accounts[1], "testing", 334, ethers.utils.parseEther("0.06"), overrides);
  const tokenBalance = await instance.checkBalance(accounts[1]);
  var checkSum = 0;
  for(var i = 0;i<tokenBalance;i++){
    var ownedToken = await instance.byIndex(accounts[1],i);
    var id = parseInt(ownedToken.toString())
    checkSum+=id;
  }
  expect(checkSum).to.equal(667);
})


})
