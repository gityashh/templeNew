// migrations/2_deploy_contracts.js
const TempleDonation = artifacts.require("TempleDonation");

module.exports = function (deployer) {
    deployer.deploy(TempleDonation);
};