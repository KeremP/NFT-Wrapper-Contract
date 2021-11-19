const Migrations = artifacts.require("Migrations");
const BaseToken = artifacts.require("ERC721Token");
const TokenWrapper = artifacts.require("ERC721Wrapper");
module.exports = async function (deployer) {
  await deployer.deploy(Migrations);
  await deployer.deploy(BaseToken,4898);
  const b = await BaseToken.deployed();
  await deployer.deploy(TokenWrapper , b.address);
  const a = await TokenWrapper.deployed();
  b.transferOwnership(a.address);
};
