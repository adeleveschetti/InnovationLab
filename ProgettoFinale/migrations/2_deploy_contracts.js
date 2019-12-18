var RequestToOrder = artifacts.require("./RequestToOrder.sol");

module.exports = function(deployer) {
  deployer.deploy(RequestToOrder);
};
