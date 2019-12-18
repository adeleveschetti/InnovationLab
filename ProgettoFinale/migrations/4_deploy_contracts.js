var ClientSide = artifacts.require("./ClientSide.sol");

module.exports = function(deployer) {
  deployer.deploy(ClientSide);
};
