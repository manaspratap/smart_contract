const Investment = artifacts.require("Investment");

module.exports = function (deployer) {
  deployer.deploy(Investment);
};
