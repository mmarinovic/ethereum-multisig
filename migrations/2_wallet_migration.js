var MultiSigWallet = artifacts.require("./MultiSigWallet.sol");
var MultiSigWalletWithDailyLimit = artifacts.require("./MultiSigWalletWithDailyLimit.sol");

module.exports = function(deployer) {
  deployer.deploy(MultiSigWallet);
  deployer.deploy(MultiSigWalletWithDailyLimit);
};
